# API Patterns — Guida Operativa

## Formato Risposta Standardizzato

Ogni endpoint risponde con questa struttura:

```typescript
// Successo con dati
{ data: T, error: null, meta?: { page: number, total: number, per_page: number } }

// Errore
{ data: null, error: { code: string, message: string, details?: unknown } }
```

```typescript
// lib/api-response.ts
export function ok<T>(data: T, meta?: object) {
  return Response.json({ data, error: null, ...(meta ? { meta } : {}) })
}

export function err(code: string, message: string, status: number, details?: unknown) {
  return Response.json({ data: null, error: { code, message, details } }, { status })
}
```

## Versioning

Tutti gli endpoint sotto `/api/v1/`. Quando introduci breaking changes → `/api/v2/` (mantieni v1 per 6 mesi).

```
/api/v1/prodotti
/api/v1/prodotti/[id]
/api/v1/ordini
/api/health         ← senza versione
```

## Paginazione

**Offset-based** (UI con pagine numerate):
```typescript
// Request: GET /api/v1/prodotti?page=2&per_page=20
const page = parseInt(searchParams.get('page') ?? '1')
const per_page = Math.min(parseInt(searchParams.get('per_page') ?? '20'), 100)
const offset = (page - 1) * per_page
const [rows, countResult] = await Promise.all([
  query('SELECT * FROM prodotti LIMIT $1 OFFSET $2', [per_page, offset]),
  query('SELECT COUNT(*) FROM prodotti'),
])
return ok(rows.rows, { page, per_page, total: parseInt(countResult.rows[0].count) })
```

**Cursor-based** (tabelle grandi, feed infiniti):
```typescript
// Request: GET /api/v1/eventi?cursor=abc123&limit=50
const cursor = searchParams.get('cursor')
const whereClause = cursor ? 'WHERE id > $1' : ''
const params = cursor ? [cursor, limit] : [limit]
// Risposta include next_cursor per la pagina successiva
return ok(rows, { next_cursor: lastRow?.id ?? null })
```

Usa cursor-based per tabelle > 100k righe o feed real-time.

## Rate Limiting (Upstash Redis)

```typescript
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

export const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 m'),  // 100 req/min per IP
})

// In ogni route API pubblica
const ip = request.headers.get('x-forwarded-for') ?? 'unknown'
const { success, limit, remaining } = await ratelimit.limit(ip)
if (!success) return err('RATE_LIMITED', 'Troppi tentativi', 429)
```

**Rate limiting per API key:**
```typescript
const apiKey = request.headers.get('x-api-key')
if (!apiKey) return err('UNAUTHORIZED', 'API key mancante', 401)
const { success } = await ratelimit.limit(`apikey:${apiKey}`)
```

## Error Codes Standardizzati

| HTTP | Code | Uso |
|---|---|---|
| 400 | `INVALID_INPUT` | Validazione fallita (Zod) |
| 401 | `UNAUTHORIZED` | Nessuna sessione / API key mancante |
| 403 | `FORBIDDEN` | Sessione valida ma permesso negato |
| 404 | `NOT_FOUND` | Risorsa non trovata |
| 409 | `CONFLICT` | Conflitto stato (es. email già usata) |
| 422 | `UNPROCESSABLE` | Input valido sintatticamente ma non processabile |
| 429 | `RATE_LIMITED` | Rate limit raggiunto |
| 500 | `INTERNAL_ERROR` | Errore server — non esporre dettagli |

```typescript
// Gestione errori globale in route handler
try {
  // logica
} catch (e) {
  console.error('[API ERROR]', e)
  return err('INTERNAL_ERROR', 'Errore interno del server', 500)
}
```

## Validazione Input (Zod)

```typescript
import { z } from 'zod'

const CreateProdottoSchema = z.object({
  nome: z.string().min(1).max(200),
  prezzo: z.number().positive(),
  categoria_id: z.number().int().positive(),
})

export async function POST(request: Request) {
  const body = await request.json()
  const parsed = CreateProdottoSchema.safeParse(body)
  if (!parsed.success) {
    return err('INVALID_INPUT', 'Input non valido', 400, parsed.error.flatten())
  }
  // usa parsed.data — type-safe
}
```

## Health Check

```typescript
// app/api/health/route.ts
export async function GET() {
  try {
    await query('SELECT 1')  // verifica DB
    return Response.json({ status: 'ok', timestamp: new Date().toISOString() })
  } catch {
    return Response.json({ status: 'degraded', db: 'unreachable' }, { status: 503 })
  }
}
```

## OpenAPI / Documentazione

Per API pubbliche o condivise con team:
- Usa `zod-openapi` o `@hono/zod-openapi` per generare spec da schema Zod
- Esponi `/api/docs` con Scalar UI (moderno) o Swagger UI
- Mantieni `/api/v1/openapi.json` aggiornato automaticamente

```bash
# Hono con OpenAPI
npm install @hono/zod-openapi @scalar/hono-api-reference
```
