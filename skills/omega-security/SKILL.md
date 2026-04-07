---
name: omega-security
description: Use when running a security audit, implementing auth patterns, handling file uploads, configuring GDPR compliance, reviewing OWASP Top 10, or setting up secrets management. Triggered by menu [8] Sicurezza OWASP, [SEC], or when building apps with sensitive data.
user-invocable: false
---

# omega-security — OWASP · GDPR · Auth · Secrets

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- OWASP Top 10:2025: https://owasp.org/Top10/2025
- OWASP Cheat Sheet: https://cheatsheetseries.owasp.org
- GDPR: https://gdpr.eu

---

## AUDIT SICUREZZA — 4 assi

Risultati in `omega/audit.md`:

```markdown
# Audit Sicurezza — [timestamp]
🔴 Critici: N  🟠 Alti: N  🟡 Medi: N  🔵 Bassi: N

## 🔴 CRITICI
### [CRIT-001] [titolo]
File: `path/file.ts:42`
Problema: [descrizione]
Fix: [soluzione concreta]
Stato: ⬜ aperto
```

### Asse 1 — OWASP Top 10:2025

- **A01 Broken Access Control** — IDOR (accesso a record altrui), endpoint senza session check, privilege escalation
- **A02 Cryptographic Failures** — dati sensibili in chiaro, no HTTPS, weak hashing (MD5, SHA1 per password)
- **A03 Injection** — SQL Injection (parametri non sanitizzati), NoSQL injection, LDAP injection
- **A04 Insecure Design** — logica business bypassabile lato client, rate limiting assente
- **A05 Security Misconfiguration** — debug in prod, stack trace esposto, directory listing
- **A06 Vulnerable Components** — `npm audit --json` · `npx better-npm-audit`
- **A07 Auth Failures** — session fixation, no logout server-side, JWT alg:none
- **A08 Software/Data Integrity** — no SRI su CDN esterni, supply chain deps non verificate
- **A09 Logging Failures** — PII nei log, log insufficienti su operazioni critiche
- **A10 SSRF** — fetch di URL forniti dall'utente senza whitelist

### Asse 2 — Correttezza codice
- TypeScript `any` impliciti, cast `as` pericolosi
- N+1 queries (loop con query dentro)
- Race conditions su numerazione (usa advisory lock)
- Promise non gestite, errori inghiottiti (catch vuoto)

### Asse 3 — Design system (verifica coerenza)
- Colori/font/spacing fuori dai token definiti in `omega/design-system.md`

### Asse 4 — Database
- FK mancanti su relazioni
- Indici mancanti su colonne in WHERE/JOIN frequenti
- Aggregazioni live su tabelle grandi (→ proponi summary table + trigger)

---

## AUTH — Pattern sicuro

### `withAuth()` — CORRETTO (con IDOR protection)

```typescript
// lib/action-utils.ts
export async function withAuth(minRuolo?: string) {
  const session = await getServerSession(authOptions)
  if (!session?.user?.id) redirect('/login')

  // Ruolo minimo richiesto (non opzionale se specificato)
  if (minRuolo && !hasRole(session.user.ruolo, minRuolo)) {
    // Non esporre dettagli — risposta generica 403
    throw new Error('FORBIDDEN')  // gestita globalmente → return 403
  }
  return session
}

// Ownership check — OBBLIGATORIO per ogni record fetch
export async function assertOwnership(userId: number, recordOwnerId: number) {
  if (userId !== recordOwnerId) throw new Error('FORBIDDEN')
}

// RBAC granulare (due livelli: ruolo + override utente)
export async function checkPermission(
  userId: number, sezione: string, tipo: 'view' | 'edit'
): Promise<boolean> {
  // 1. Admin → sempre true
  // 2. Cerca in permessi_utente (override individuale)
  // 3. Fallback a permessi_ruolo
  const { rows } = await query(`
    SELECT COALESCE(pu.can_${tipo}, pr.can_${tipo}, false) AS ok
    FROM utenti u
    LEFT JOIN permessi_utente pu ON pu.utente_id = u.id AND pu.sezione = $2
    LEFT JOIN permessi_ruolo pr ON pr.ruolo = u.ruolo AND pr.sezione = $2
    WHERE u.id = $1
  `, [userId, sezione])
  return rows[0]?.ok ?? false
}
```

### Invalidazione sessione server-side

```typescript
// NextAuth: quando cambi ruolo/permessi → invalida sessione
// Con JWT: aggiungi version al token, incrementa in DB su cambio permessi
// Con DB sessions: DELETE FROM sessions WHERE user_id = $1
```

### Security headers (next.config.js)

```javascript
const securityHeaders = [
  { key: 'X-DNS-Prefetch-Control', value: 'on' },
  { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
  { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
  // CSP — personalizzare per il progetto
  { key: 'Content-Security-Policy', value: "default-src 'self'; script-src 'self' 'nonce-{nonce}'" },
]
```

---

## FILE UPLOAD — Pattern sicuro

### ❌ MAI fare questo

```typescript
// ❌ SBAGLIATO — public/ serve file senza autenticazione
path.join(process.cwd(), 'public/uploads', filename)
```

### ✅ Pattern corretto (fuori da public/)

```typescript
// app/api/uploads/route.ts
import { writeFile } from 'fs/promises'
import path from 'path'
import { magic } from 'file-type'  // rilevamento magic bytes (non mime header)

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf']
const MAX_SIZE = 10 * 1024 * 1024  // 10MB
const UPLOAD_DIR = path.join(process.cwd(), 'private/uploads')  // ← FUORI da public/

export async function POST(req: Request) {
  const session = await getServerSession(authOptions)
  if (!session) return new Response('Unauthorized', { status: 401 })

  const formData = await req.formData()
  const file = formData.get('file') as File
  if (!file) return new Response('No file', { status: 400 })
  if (file.size > MAX_SIZE) return new Response('File too large', { status: 413 })

  // ✅ Rilevamento tipo dal contenuto (magic bytes), non dall'header HTTP
  const buffer = Buffer.from(await file.arrayBuffer())
  const detected = await magic.fromBuffer(buffer)
  if (!detected || !ALLOWED_TYPES.includes(detected.mime)) {
    return new Response('File type not allowed', { status: 415 })
  }

  const uuid = crypto.randomUUID()
  const ext = detected.ext
  const relativePath = `${session.user.id}/${uuid}.${ext}`
  await writeFile(path.join(UPLOAD_DIR, relativePath), buffer)

  // Registra in DB con ownership
  await query(
    'INSERT INTO allegati (utente_id, percorso, nome, mime, dimensione) VALUES ($1,$2,$3,$4,$5)',
    [session.user.id, relativePath, file.name, detected.mime, file.size]
  )

  return Response.json({ id: uuid, path: relativePath })
}
```

### Route di download (con auth e ownership check)

```typescript
// app/api/uploads/[id]/route.ts
export async function GET(req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions)
  if (!session) return new Response('Unauthorized', { status: 401 })

  const { rows } = await query(
    'SELECT percorso, nome, mime, utente_id FROM allegati WHERE id = $1',
    [params.id]
  )
  if (!rows[0]) return new Response('Not found', { status: 404 })

  // ✅ Ownership check — solo il proprietario (o admin) può scaricare
  if (rows[0].utente_id !== session.user.id && session.user.ruolo !== 'ADMIN') {
    return new Response('Forbidden', { status: 403 })
  }

  const filePath = path.join(process.cwd(), 'private/uploads', rows[0].percorso)
  const buffer = await readFile(filePath)

  return new Response(buffer, {
    headers: {
      'Content-Type': rows[0].mime,
      'Content-Disposition': `attachment; filename="${rows[0].nome}"`,
      'Cache-Control': 'no-store',  // ← mai cachare documenti privati
    }
  })
}
```

---

## AUDIT LOG — Pattern sicuro (senza PII in chiaro)

```typescript
// lib/audit.ts — chiamare DENTRO la transazione, non fuori
export async function logAudit(client: PoolClient, data: {
  utente_id: number, azione: 'CREATE' | 'UPDATE' | 'DELETE',
  tabella: string, record_id: string,
  dati_prima?: object, dati_dopo?: object,
  ip_address?: string
}) {
  // ⚠️ Maschera i campi PII prima di salvare nel log
  const mascheraPII = (obj?: object) => {
    if (!obj) return obj
    const CAMPI_SENSIBILI = ['password', 'token', 'cf', 'iban', 'carta', 'pan', 'email']
    return JSON.parse(JSON.stringify(obj, (key, val) =>
      CAMPI_SENSIBILI.some(f => key.toLowerCase().includes(f)) ? '[REDACTED]' : val
    ))
  }

  await client.query(
    `INSERT INTO registro_audit (utente_id, azione, tabella, record_id, dati_prima, dati_dopo, ip_address, creato_il)
     VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())`,
    [data.utente_id, data.azione, data.tabella, data.record_id,
     mascheraPII(data.dati_prima), mascheraPII(data.dati_dopo), data.ip_address]
  )
}
```

**Schema audit con TTL:**
```sql
CREATE TABLE registro_audit (
  id BIGSERIAL PRIMARY KEY,
  creato_il TIMESTAMP NOT NULL DEFAULT NOW(),
  utente_id INT,
  azione TEXT,
  tabella TEXT,
  record_id TEXT,
  dati_prima JSONB,  -- campi PII mascherati prima dell'inserimento
  dati_dopo JSONB,
  ip_address TEXT
);
-- Retention policy: cancella log > 2 anni (GDPR storage limitation)
CREATE INDEX ON registro_audit (creato_il);
-- Cronjob: DELETE FROM registro_audit WHERE creato_il < NOW() - INTERVAL '2 years';
```

---

## GDPR — Checklist operativa

### Art. 5 — Principi
- [ ] **Minimizzazione dati**: raccogli solo ciò che serve
- [ ] **Storage limitation**: definita retention policy per ogni tipo di dato
- [ ] **Integrità/Riservatezza**: cifratura at-rest per dati sanitari/finanziari

### Art. 13/14 — Trasparenza
- [ ] Privacy policy aggiornata e accessibile
- [ ] Cookie banner se analytics (consenso opt-in)

### Art. 17 — Diritto alla cancellazione
- [ ] Implementato `DELETE /api/account` con hard delete (non solo soft delete)
- [ ] I log audit vengono anonimizzati, non cancellati

### Art. 30 — Registro trattamenti
- [ ] Documento interno che elenca: dati trattati, base legale, retention, terze parti

### Art. 32 — Sicurezza del trattamento
- [ ] Cifratura at-rest per dati sanitari/finanziari (column encryption o TDE)
- [ ] TLS su tutte le connessioni DB (`sslmode=require` in DATABASE_URL)
- [ ] Backup cifrati

### Art. 33 — Notifica breach entro 72h
- [ ] Runbook documentato: chi notificare, come, entro quando
- [ ] Contatto DPO o responsabile privacy definito

### Vendor GDPR
- [ ] Sentry: configurare `beforeSend` per filtrare PII prima dell'invio
- [ ] Email provider: DPA firmato
- [ ] Log aggregation: in UE o con garanzie adeguate

---

## SECRETS MANAGEMENT

### Sviluppo → Produzione

| Ambiente | Come gestire secrets |
|---|---|
| Sviluppo | `.env.local` (mai in git) |
| CI/CD | GitHub Secrets (encrypted at rest) |
| Produzione | Vercel env vars · Railway vars · `.env.production` su VPS (permessi 600) |

### Rotation automatica (raccomandato)
```bash
# Genera nuovo NEXTAUTH_SECRET
openssl rand -base64 32

# Aggiorna in produzione senza downtime
vercel env rm NEXTAUTH_SECRET production
vercel env add NEXTAUTH_SECRET production
vercel --prod   # rideploy
```

### Secret scanning nei commit

```bash
# Installa pre-commit hook
npm install --save-dev @secretlint/secretlint-rule-preset-recommend
# Blocca commit con secrets (API keys, password hardcoded, ecc.)
```

### Credenziali DB — Principio di minimo privilegio

```sql
-- Crea utente applicazione con solo i permessi necessari
CREATE USER app_user WITH PASSWORD 'strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- NON concedere: DROP, TRUNCATE, CREATE, ALTER

-- Utente read-only per analytics/monitoring
CREATE USER readonly_user WITH PASSWORD 'another_strong_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;
```

---

## CSRF PROTECTION

```typescript
// Con Next.js App Router + Server Actions: CSRF è gestito automaticamente
// Per API Routes custom: verifica Origin header

export async function POST(req: Request) {
  const origin = req.headers.get('origin')
  const allowed = process.env.NEXTAUTH_URL

  if (!origin || !origin.startsWith(allowed!)) {
    return new Response('Forbidden', { status: 403 })
  }
  // ...
}
```

---

## CHECKLIST SICUREZZA COMPLETA (pre-lancio)

- [ ] OWASP Top 10: tutti i punti verificati
- [ ] `npm audit` zero vulnerabilità critiche/alte
- [ ] Nessun secret hardcoded (verificato con secretlint)
- [ ] File upload fuori da public/ con auth e ownership check
- [ ] Audit log con PII mascherata e retention policy
- [ ] withAuth() con ownership check su ogni operazione
- [ ] Security headers configurati (HSTS, CSP, X-Frame-Options, ecc.)
- [ ] Rate limiting su auth + upload + API pubbliche
- [ ] TLS su connessione DB (`?sslmode=require`)
- [ ] Backup cifrati
- [ ] GDPR: privacy policy, cookie banner, diritto cancellazione
- [ ] `security.txt` in public/ con contatto responsabile
