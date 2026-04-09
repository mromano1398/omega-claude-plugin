# Security Defaults — Fase 1 Automatica

Sicurezza Fase 1 è **sempre inclusa**, per ogni tipo di progetto. Non è opt-in.

---

## BASE — Tutti i Progetti

### Security Headers

```typescript
// next.config.ts
const securityHeaders = [
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'X-DNS-Prefetch-Control', value: 'on' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
]

headers: async () => [{ source: '/(.*)', headers: securityHeaders }]
```

Per CSP avanzato → `/omega:omega-security`.

### HTTPS + .env

```bash
# .gitignore — verificare sempre all'inizio
.env
.env.local
.env.*.local
*.pem
```

HTTPS: forza redirect 301 HTTP → HTTPS nel hosting (Vercel lo fa automaticamente; su VPS configura Nginx + Certbot).

### Rate Limiting Auth

```typescript
// lib/auth-rate-limit.ts — 5 tentativi / 15 minuti per IP
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

export const authRateLimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(5, '15 m'),
  prefix: 'auth',
})

// In /api/auth/[...nextauth]/route.ts o login action
const { success } = await authRateLimit.limit(ip)
if (!success) return { error: 'Troppi tentativi. Riprova tra 15 minuti.' }
```

Alternativa senza Redis: contatore in-memory con `Map` + TTL (solo single-instance).

### Validazione Zod — Ogni Input Server-Side

```typescript
// REGOLA: mai fidarsi di input dal client senza validazione
// Ogni Server Action e ogni Route Handler deve avere uno schema Zod

const Schema = z.object({ ... })
const parsed = Schema.safeParse(input)
if (!parsed.success) return { error: parsed.error.flatten() }
// Da qui in poi usa solo parsed.data
```

### IDOR Protection

```typescript
// SBAGLIATO — non verifica ownership
const doc = await query('SELECT * FROM documenti WHERE id = $1', [id])

// CORRETTO — WHERE user_id = session.user.id su ogni query
const session = await auth()
const doc = await query(
  'SELECT * FROM documenti WHERE id = $1 AND user_id = $2',
  [id, session.user.id]
)
if (!doc.rows[0]) return { error: 'Non trovato o accesso negato' }
```

---

## GESTIONALE

Oltre alle misure BASE:

```typescript
// RBAC — controlla permesso prima di ogni operazione sensibile
const canEdit = await checkPermission(session.user.id, 'documenti', 'edit')
if (!canEdit) return { error: 'Accesso negato' }

// Audit trail — loggato DENTRO la transazione (mai fuori)
await withTransaction(async (client) => {
  await client.query('INSERT INTO documenti ...', [...])
  await logAudit(client, {
    azione: 'CREATE',
    tabella: 'documenti',
    record_id: newId,
    user_id: session.user.id,
    ip: request.headers.get('x-forwarded-for'),
  })
})

// Advisory lock — per numerazione atomica documenti
await client.query('SELECT pg_advisory_xact_lock($1)', [hashCode(`ddt_${anno}`)])
```

---

## SAAS

Oltre alle misure BASE:

```typescript
// Tenant isolation — ogni query filtra per tenant
const doc = await query(
  'SELECT * FROM documenti WHERE id = $1 AND tenant_id = $2',
  [id, session.user.tenantId]
)

// Stripe webhook — verifica signature SEMPRE
const sig = request.headers.get('stripe-signature')!
let event: Stripe.Event
try {
  event = stripe.webhooks.constructEvent(rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET!)
} catch {
  return new Response('Webhook signature invalida', { status: 400 })
}

// Trial expiry — controllo server-side, non solo client
const subscription = await getSubscription(session.user.tenantId)
if (subscription.status === 'expired') redirect('/pricing')
```

---

## E-COMMERCE

Oltre alle misure BASE:

```typescript
// Inventory lock — previene overselling con concorrenza
await withTransaction(async (client) => {
  const { rows } = await client.query(
    'SELECT giacenza FROM prodotti WHERE id = $1 FOR UPDATE',  // row-level lock
    [prodottoId]
  )
  if (rows[0].giacenza < quantita) throw new Error('Scorte insufficienti')
  await client.query('UPDATE prodotti SET giacenza = giacenza - $1 WHERE id = $2', [quantita, prodottoId])
})

// Prezzi server-side — mai fidarsi del prezzo dal client
const prodotto = await getProdotto(id)
const totale = prodotto.prezzo * quantita  // calcolato server-side
// Passa totale a Stripe, non riceverlo dal form
```

---

## API PUBBLICA

Oltre alle misure BASE:

```typescript
// API key authentication
const apiKey = request.headers.get('x-api-key')
if (!apiKey) return err('UNAUTHORIZED', 'API key richiesta', 401)

const keyRecord = await query('SELECT * FROM api_keys WHERE key_hash = $1 AND attiva = true', [hash(apiKey)])
if (!keyRecord.rows[0]) return err('UNAUTHORIZED', 'API key non valida', 401)

// Rate limiting per API key (separato dal rate limiting per IP)
const { success } = await ratelimit.limit(`apikey:${keyRecord.rows[0].id}`)
if (!success) return err('RATE_LIMITED', 'Quota esaurita', 429)
```

---

## MOBILE (Expo / React Native)

```typescript
// SecureStore per dati sensibili — mai AsyncStorage per token
import * as SecureStore from 'expo-secure-store'
await SecureStore.setItemAsync('access_token', token)
const token = await SecureStore.getItemAsync('access_token')

// Token refresh automatico
// Intercetta 401 → chiama /api/auth/refresh → riprova request originale
// Implementa con axios interceptor o fetch wrapper

// Certificati — non disabilitare mai SSL verification in produzione
```

---

## Checklist Sicurezza Fase 1

- [ ] Security headers aggiunti in next.config.ts
- [ ] .env in .gitignore verificato
- [ ] Rate limiting auth configurato (5/15min)
- [ ] Schema Zod su ogni Server Action e Route Handler
- [ ] IDOR protection: WHERE user_id su ogni query dati utente
- [ ] Misure aggiuntive per tipo progetto (RBAC, tenant isolation, inventory lock...)

Per audit OWASP completo pre-lancio → `/omega:omega-security`
Riferimento: `skills/omega/references/api-patterns.md` per rate limiting avanzato
