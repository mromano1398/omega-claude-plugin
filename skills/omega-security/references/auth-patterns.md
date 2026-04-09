# Auth Patterns — Pattern sicuro completo

## `withAuth()` — CORRETTO (con IDOR protection)

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

## Invalidazione sessione server-side

```typescript
// NextAuth: quando cambi ruolo/permessi → invalida sessione
// Con JWT: aggiungi version al token, incrementa in DB su cambio permessi
// Con DB sessions: DELETE FROM sessions WHERE user_id = $1
```

## Security headers (next.config.js)

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

### Secret scanning con secretlint

```bash
# Installa secretlint per rilevare segreti accidentalmente committati
npm install -D secretlint @secretlint/secretlint-rule-preset-recommend

# Configura .secretlintrc.json nella root:
cat > .secretlintrc.json << 'EOF'
{
  "rules": [
    { "id": "@secretlint/secretlint-rule-preset-recommend" }
  ]
}
EOF

# Aggiungi a package.json scripts:
"scripts": {
  "secretlint": "secretlint \"**/*\"",
  "secretlint:ci": "secretlint --format=github-actions \"**/*\""
}

# Hook pre-commit (con husky o lefthook):
# Esegui prima di ogni commit — blocca se trova segreti
```

**Cosa rileva secretlint:** AWS keys, GitHub tokens, Stripe keys, JWT secrets, private keys PEM, password hardcoded in codice.

**Non sostituisce:** `.gitignore` corretto, `.env` mai committato, variabili d'ambiente in produzione su piattaforma (Vercel/Railway).

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
