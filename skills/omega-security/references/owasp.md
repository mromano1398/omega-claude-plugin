# OWASP — Audit Sicurezza Completo

Riferimenti ufficiali:
- OWASP Top 10:2025: https://owasp.org/Top10/2025
- OWASP Cheat Sheet: https://cheatsheetseries.owasp.org

## FORMATO AUDIT — `omega/audit.md`

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

## OWASP TOP 10:2025 — Checklist

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

## ASSI AUDIT AGGIUNTIVI

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
