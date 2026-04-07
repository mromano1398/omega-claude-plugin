---
name: omega-multitenant
description: Use when building a multi-tenant SaaS where multiple organizations share the same application but need data isolation. Covers schema-per-tenant vs row-level isolation strategies, tenant detection middleware, provisioning flow, and RLS policies. Triggered by mentions of "organizzazione", "tenant", "workspace", "multi-tenant".
user-invocable: false
---

# omega-multitenant — Isolamento Dati · Tenant Detection · Provisioning

**Lingua:** Sempre italiano.
**Principio:** La scelta tra schema-per-tenant e row-level isolation determina tutto il design. Prendila prima di scrivere una riga.

---

## STRATEGIA — Scegli prima di costruire

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

---

## ROW-LEVEL ISOLATION (consigliato)

### Schema DB

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
  -- ... altri campi
  creato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indici obbligatori per performance
CREATE INDEX ON clienti (organizzazione_id);
CREATE INDEX ON membri (utente_id);
CREATE INDEX ON membri (organizzazione_id);
```

### RLS Policies

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

---

## TENANT DETECTION — Middleware

### Opzione A — Subdomain (myorg.app.com)

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const hostname = request.headers.get('host') || ''
  const appDomain = process.env.NEXT_PUBLIC_APP_DOMAIN!  // 'app.com'

  // Estrai subdomain
  const subdomain = hostname.replace(`.${appDomain}`, '')
  const isRootDomain = subdomain === appDomain || !hostname.includes(appDomain)

  if (isRootDomain) {
    // Root domain → landing page
    return NextResponse.next()
  }

  // Aggiungi subdomain (slug tenant) all'header per uso in Server Components
  const response = NextResponse.next()
  response.headers.set('x-tenant-slug', subdomain)
  return response
}

export const config = {
  matcher: ['/((?!_next|api/public|favicon.ico).*)'],
}
```

```typescript
// lib/tenant.ts — recupera tenant in Server Component
import { headers } from 'next/headers'
import { cache } from 'react'
import { db } from './db'

export const getCurrentTenant = cache(async () => {
  const slug = headers().get('x-tenant-slug')
  if (!slug) return null

  const tenant = await db.organizzazioni.findUnique({ where: { slug } })
  return tenant
})
```

### Opzione B — Path-based (/org/[slug]/...)

```typescript
// app/org/[slug]/layout.tsx
import { db } from '@/lib/db'
import { notFound } from 'next/navigation'

export default async function TenantLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: { slug: string }
}) {
  const tenant = await db.organizzazioni.findUnique({
    where: { slug: params.slug }
  })

  if (!tenant) notFound()

  return (
    <TenantProvider tenant={tenant}>
      {children}
    </TenantProvider>
  )
}
```

---

## PROVISIONING — Onboarding nuovo tenant

```typescript
// app/actions/provisioning.ts
'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { generateSlug } from '@/lib/utils'

export async function creaOrganizzazione(nome: string) {
  const session = await auth()
  if (!session?.user?.id) throw new Error('Non autenticato')

  // Genera slug univoco
  const baseSlug = generateSlug(nome)
  let slug = baseSlug
  let count = 0
  while (await db.organizzazioni.findUnique({ where: { slug } })) {
    slug = `${baseSlug}-${++count}`
  }

  // Transazione: crea org + aggiungi utente come OWNER
  const result = await db.$transaction(async (tx) => {
    const org = await tx.organizzazioni.create({
      data: { nome, slug, piano: 'FREE' }
    })

    await tx.membri.create({
      data: {
        utente_id: session.user.id,
        organizzazione_id: org.id,
        ruolo: 'OWNER',
      }
    })

    // Provisioning iniziale: crea dati di default (es. categorie, template)
    await tx.categorie.createMany({
      data: CATEGORIE_DEFAULT.map(c => ({
        ...c,
        organizzazione_id: org.id
      }))
    })

    return org
  })

  return result
}
```

---

## INVITI TEAM

```typescript
// Schema
// CREATE TABLE inviti (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   organizzazione_id UUID NOT NULL REFERENCES organizzazioni(id),
//   email TEXT NOT NULL,
//   ruolo TEXT NOT NULL DEFAULT 'MEMBER',
//   token TEXT UNIQUE NOT NULL,  -- token sicuro per accettazione
//   scade_il TIMESTAMPTZ NOT NULL,
//   accettato_il TIMESTAMPTZ,
//   creato_da UUID REFERENCES auth.users(id)
// );

// app/actions/inviti.ts
export async function invitaMembro(email: string, organizzazioneId: string, ruolo: string) {
  const session = await auth()
  if (!session?.user) throw new Error('Non autenticato')

  // Verifica che l'utente sia OWNER o ADMIN
  const membro = await db.membri.findFirst({
    where: {
      utente_id: session.user.id,
      organizzazione_id: organizzazioneId,
      ruolo: { in: ['OWNER', 'ADMIN'] }
    }
  })
  if (!membro) throw new Error('Non autorizzato')

  const token = crypto.randomUUID()
  await db.inviti.create({
    data: {
      email,
      organizzazione_id: organizzazioneId,
      ruolo,
      token,
      scade_il: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),  // 7 giorni
      creato_da: session.user.id,
    }
  })

  // Invia email con link /inviti/accetta/[token]
  await sendEmail({
    to: email,
    subject: `Invito a ${org.nome}`,
    html: inviteEmailTemplate(token, org.nome),
  })
}
```

---

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

---

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

---

## CHECKLIST MULTI-TENANT

- [ ] Strategia scelta (row-level / schema-per-tenant / database separato)
- [ ] `organizzazione_id` su tutte le tabelle business
- [ ] RLS policy attive e testate su ogni tabella
- [ ] Funzione helper `mie_organizzazioni()` per RLS
- [ ] Middleware tenant detection (subdomain o path)
- [ ] Provisioning transazionale (org + owner + dati default)
- [ ] Sistema inviti con token sicuro e scadenza
- [ ] Feature gates per piano (FREE/PRO/ENTERPRISE)
- [ ] Test cross-tenant: utente A non può mai vedere dati utente B
- [ ] `adminClient` (service role) mai esposto al client
