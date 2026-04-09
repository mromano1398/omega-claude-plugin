---
name: omega-multitenant
description: Use when building a multi-tenant SaaS where multiple organizations share the same application but need data isolation. Covers schema-per-tenant vs row-level isolation strategies, tenant detection middleware, provisioning flow, and RLS policies. Triggered by mentions of "organizzazione", "tenant", "workspace", "multi-tenant".
user-invocable: false
---

# omega-multitenant — Isolamento Dati · Tenant Detection · Provisioning

**Lingua:** Sempre italiano.
**Principio:** La scelta tra schema-per-tenant e row-level isolation determina tutto il design. Prendila prima di scrivere una riga.

## QUANDO USARE

- SaaS con multiple organizzazioni/workspace che condividono la stessa app
- Dati di un tenant non devono mai essere visibili a un altro tenant
- Onboarding self-service di nuovi tenant
- Sistema di inviti per aggiungere membri a un'organizzazione
- Feature gates per piano (FREE/PRO/ENTERPRISE)

## FLUSSO DECISIONALE

```
Quanti tenant prevedi?
< 100 + dati sensibili → Schema-per-tenant (isolamento completo)
100-10.000            → Row-level con RLS (consigliato SaaS B2B)
> 10.000              → Database separato (solo se hai team infra dedicato)

Setup base:
1. Crea tabelle organizzazioni + membri con organizzazione_id su ogni tabella business
2. Attiva RLS su tutte le tabelle business
3. Crea funzione helper mie_organizzazioni()
4. Scegli tenant detection: subdomain vs path-based
5. Implementa provisioning transazionale (org + owner + dati default)
6. Aggiungi feature gates per piano
```

## REGOLE CHIAVE

1. **`organizzazione_id` su TUTTE le tabelle business** — senza eccezioni
2. **RLS policy attive e testate su ogni tabella** — non solo abilitare RLS
3. **Test cross-tenant obbligatorio** — utente A non può mai vedere dati utente B
4. **Provisioning in transazione** — org + owner + dati default in un'unica TX
5. **Inviti con token sicuro e scadenza** — mai inviare link senza scadenza
6. **Feature gates prima di creare risorse** — verifica limite piano prima di ogni INSERT
7. **`adminClient` mai esposto al client** — bypassa RLS
8. **Slug univoco per ogni tenant** — gestire collisioni nel provisioning
9. **Indici su `organizzazione_id`** obbligatori per performance
10. **Ruoli: OWNER, ADMIN, MEMBER** — solo OWNER/ADMIN possono cancellare

## CHECKLIST SINTETICA

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

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/isolation.md] — strategie isolamento, schema DB, RLS policies, schema-per-tenant, feature gates
- [references/provisioning.md] — tenant detection (subdomain/path), provisioning transazionale, sistema inviti team

## PATTERN AVANZATI B2B

### Migration zero-downtime (Expand/Contract pattern)

Su SaaS B2B con clienti in produzione, le migration devono essere non-bloccanti:

```sql
-- FASE 1 — EXPAND (aggiungi senza rompere):
-- Aggiungi colonna nullable, mantenendo retrocompatibilità
ALTER TABLE users ADD COLUMN organization_id INT REFERENCES organizations(id);

-- FASE 2 — MIGRATE (backfill graduale, non in una transazione sola):
-- Esegui in batch per non bloccare la tabella
UPDATE users SET organization_id = 1 WHERE organization_id IS NULL AND id BETWEEN 1 AND 1000;
-- ripeti per range successivi...

-- FASE 3 — CONTRACT (applica il vincolo finale dopo che tutti i dati sono migrati):
ALTER TABLE users ALTER COLUMN organization_id SET NOT NULL;
```

---

### Rate limiting per tenant
```typescript
// Con Upstash Redis — npm install @upstash/ratelimit @upstash/redis
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 m'), // 100 req/min per tenant
})

// Nel middleware o nella Server Action:
export async function withTenantRateLimit(tenantId: string) {
  const { success, remaining } = await ratelimit.limit(`tenant:${tenantId}`)
  if (!success) throw new Error(`Rate limit superato per il tenant ${tenantId}`)
  return remaining
}
```

---

### Error correlation con tenant_id
```typescript
// Middleware che inietta tenantId nel contesto di logging
// lib/logger.ts
import * as Sentry from '@sentry/nextjs'

export function setTenantContext(tenantId: string, userId: string) {
  Sentry.setTag('tenant_id', tenantId)
  Sentry.setUser({ id: userId, tenant: tenantId })
}

// Nel layout di ogni route tenant-specific:
// app/(dashboard)/layout.tsx
const session = await getServerSession()
setTenantContext(session.tenantId, session.userId)
```

---

### SSO/SAML — pattern di integrazione
```typescript
// Con Auth.js v5 custom provider per SAML (usando samlify o passport-saml)
// Prima valuta se il cliente usa già un IdP (Okta, Azure AD, Google Workspace)

// Configurazione per tenant con SSO:
// lib/auth-config.ts
export async function getSSOProviderForTenant(tenantId: string) {
  const config = await db.query(
    'SELECT sso_enabled, saml_idp_url, saml_cert FROM organizations WHERE id = $1',
    [tenantId]
  )
  if (!config.sso_enabled) return null
  return {
    type: 'saml',
    idpUrl: config.saml_idp_url,
    certificate: config.saml_cert,
  }
}
```
**Nota:** Per SSO enterprise completo considera Clerk o WorkOS — gestiscono SAML/OIDC out-of-the-box.
