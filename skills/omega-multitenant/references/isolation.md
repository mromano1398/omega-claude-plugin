# Isolation — Strategie di Isolamento Dati Multi-Tenant

## Strategia — Scegli prima di costruire

```
Quanti tenant prevedi?
├─ < 100 e con dati molto sensibili → Schema-per-tenant (PostgreSQL schema isolation)
│   Vantaggi: isolamento completo, backup per-tenant, nessun rischio cross-tenant
│   Svantaggi: migration complessa, N schema da mantenere
│
├─ 100-10.000 → Row-level con RLS (PostgreSQL Row Level Security)
│   Vantaggi: un solo schema, semplice da gestire, scalabile
│   Svantaggi: RLS deve essere perfetto — un bug = data leak cross-tenant
│
└─ > 10.000 → Database separato per tenant (sharding)
    Solo se hai team infrastruttura dedicato
```

**Nella maggior parte dei casi SaaS B2B: usa Row-Level con RLS.**

## ROW-LEVEL ISOLATION — Schema DB

```sql
-- Tabella organizzazioni
CREATE TABLE organizzazioni (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,  -- identificatore URL-friendly
  piano TEXT NOT NULL DEFAULT 'FREE',  -- FREE, PRO, ENTERPRISE
  creata_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabella membri (utente ↔ organizzazione)
CREATE TABLE membri (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  utente_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organizzazione_id UUID NOT NULL REFERENCES organizzazioni(id) ON DELETE CASCADE,
  ruolo TEXT NOT NULL DEFAULT 'MEMBER',  -- OWNER, ADMIN, MEMBER
  creato_il TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (utente_id, organizzazione_id)
);

-- Tutte le tabelle business includono organizzazione_id
CREATE TABLE clienti (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizzazione_id UUID NOT NULL REFERENCES organizzazioni(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  creato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indici obbligatori per performance
CREATE INDEX ON clienti (organizzazione_id);
CREATE INDEX ON membri (utente_id);
CREATE INDEX ON membri (organizzazione_id);
```

## RLS Policies

```sql
-- Attiva RLS su tutte le tabelle business
ALTER TABLE clienti ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordini ENABLE ROW LEVEL SECURITY;
-- (ripeti per ogni tabella)

-- Funzione helper: organizzazioni dell'utente corrente
CREATE OR REPLACE FUNCTION mie_organizzazioni()
RETURNS SETOF UUID AS $$
  SELECT organizzazione_id FROM membri WHERE utente_id = auth.uid()
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- Policy universale (applica a ogni tabella con organizzazione_id)
CREATE POLICY "tenant isolation"
  ON clienti FOR ALL
  USING (organizzazione_id IN (SELECT mie_organizzazioni()));

-- Policy OWNER/ADMIN per operazioni di cancellazione
CREATE POLICY "solo admin cancella"
  ON clienti FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM membri
      WHERE utente_id = auth.uid()
      AND organizzazione_id = clienti.organizzazione_id
      AND ruolo IN ('OWNER', 'ADMIN')
    )
  );
```

## SCHEMA-PER-TENANT (alternativa, per < 100 tenant premium)

```sql
-- Crea schema dedicato per ogni tenant
CREATE SCHEMA tenant_acmecorp;

-- Copia struttura tabelle nel nuovo schema
CREATE TABLE tenant_acmecorp.clienti (LIKE public.clienti INCLUDING ALL);
CREATE TABLE tenant_acmecorp.ordini (LIKE public.ordini INCLUDING ALL);

-- Funzione di provisioning (eseguita server-side con service role)
CREATE OR REPLACE FUNCTION crea_schema_tenant(slug TEXT)
RETURNS void AS $$
BEGIN
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS tenant_%I', slug);
  EXECUTE format('CREATE TABLE tenant_%I.clienti (LIKE public.clienti INCLUDING ALL)', slug);
  -- ... altre tabelle
END;
$$ LANGUAGE plpgsql;
```

```typescript
// Routing verso schema corretto
const db = new PrismaClient({
  datasources: {
    db: { url: process.env.DATABASE_URL }
  }
})

// Prima di ogni query, imposta search_path
await db.$executeRaw`SET search_path TO ${Prisma.raw(`tenant_${slug}`)}, public`
```

## PIANO / LIMITI (Feature Gates)

```typescript
// lib/limits.ts — definisce limiti per piano
export const LIMITI_PIANO = {
  FREE: { utenti: 3, clienti: 100, storage_gb: 1 },
  PRO: { utenti: 20, clienti: 10_000, storage_gb: 50 },
  ENTERPRISE: { utenti: Infinity, clienti: Infinity, storage_gb: 1000 },
} as const

// lib/gates.ts — verifica limite prima di creare
export async function verificaLimite(
  organizzazioneId: string,
  risorsa: 'utenti' | 'clienti'
) {
  const org = await db.organizzazioni.findUniqueOrThrow({
    where: { id: organizzazioneId },
    include: {
      _count: { select: { membri: true, clienti: true } }
    }
  })

  const limite = LIMITI_PIANO[org.piano as keyof typeof LIMITI_PIANO]
  const attuale = org._count[risorsa === 'utenti' ? 'membri' : 'clienti']

  if (attuale >= limite[risorsa]) {
    throw new Error(`LIMITE_RAGGIUNTO:${risorsa}:${org.piano}`)
  }
}
```
