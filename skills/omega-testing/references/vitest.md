# Vitest — Unit e Integration Test

Doc ufficiale: https://vitest.dev/guide

## Setup

```bash
npm install -D vitest @vitest/coverage-v8
```

### `vitest.config.ts`

```typescript
import { defineConfig } from 'vitest/config'
import { loadEnv } from 'vite'

export default defineConfig(({ mode }) => ({
  test: {
    environment: 'node',
    setupFiles: ['./src/tests/setup.ts'],
    env: loadEnv(mode, process.cwd(), ''),
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      exclude: ['node_modules/', '.next/'],
    },
  },
}))
```

### `.env.test`

```bash
DATABASE_URL_TEST=postgresql://postgres:testpass@localhost:5432/testdb
NEXTAUTH_SECRET=test_secret_not_real
```

### `src/tests/setup.ts`

```typescript
import { afterAll, afterEach, beforeAll, beforeEach } from 'vitest'
import { pool } from '@/lib/db'

// Transazione rollback — ogni test lavora su DB pulito
let client: any

beforeAll(async () => {
  // Crea schema di test se non esiste
  await pool.query('CREATE SCHEMA IF NOT EXISTS test')
})

beforeEach(async () => {
  client = await pool.connect()
  await client.query('BEGIN')
  // Override pool.query per usare il client con transazione aperta
  // (vedi pattern completo sotto)
})

afterEach(async () => {
  await client.query('ROLLBACK')
  client.release()
})

afterAll(async () => {
  await pool.end()
})
```

## UNIT TEST

### Cosa testare

- Calcoli e trasformazioni (prezzi, giacenze, totali)
- Validators e schema Zod
- Formatter (date, currency, codice fiscale)
- Utility functions (hashCode, generazione codici)
- Business logic pura (senza DB, senza network)

### Esempio — Calcolo giacenza

```typescript
// src/tests/unit/giacenza.test.ts
import { describe, it, expect } from 'vitest'
import { calcolaGiacenzaFinale, verificaGiacenzaSufficiente } from '@/lib/giacenze'

describe('calcolo giacenza', () => {
  it('somma correttamente entrate e uscite', () => {
    const movimenti = [
      { tipo: 'entrata', quantita: 100 },
      { tipo: 'uscita', quantita: 30 },
      { tipo: 'entrata', quantita: 20 },
    ]
    expect(calcolaGiacenzaFinale(movimenti)).toBe(90)
  })

  it('blocca se giacenza insufficiente', () => {
    expect(verificaGiacenzaSufficiente(10, 15)).toBe(false)
    expect(verificaGiacenzaSufficiente(20, 15)).toBe(true)
    expect(verificaGiacenzaSufficiente(15, 15)).toBe(true)  // esatto = ok
  })

  it('non va mai in negativo', () => {
    expect(calcolaGiacenzaFinale([{ tipo: 'uscita', quantita: 100 }])).toBeGreaterThanOrEqual(0)
  })
})
```

## INTEGRATION TEST (DB reale, no mock)

**Regola critica:** Mai mockare il DB per integration test. Testa su DB di test reale con transazioni rollback.

### Pattern con transazione rollback

```typescript
// src/tests/integration/articoli.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { pool } from '@/lib/db'
import { creaArticolo, getArticolo } from '@/modules/articoli/actions'

let client: any

beforeEach(async () => {
  client = await pool.connect()
  await client.query('BEGIN')
  // Sostituisce temporaneamente la query globale con quella del client di test
})

afterEach(async () => {
  await client.query('ROLLBACK')  // ← Annulla tutto — DB rimane pulito
  client.release()
})

describe('creaArticolo', () => {
  it('crea articolo e logga audit', async () => {
    const result = await creaArticolo({
      codice: 'TEST001',
      nome: 'Articolo Test',
      categoria_id: 1,
    })

    expect(result.success).toBe(true)
    expect(result.id).toBeDefined()

    // Verifica nel DB che l'articolo esiste
    const { rows: articoli } = await client.query(
      'SELECT * FROM articoli WHERE codice = $1', ['TEST001']
    )
    expect(articoli).toHaveLength(1)
    expect(articoli[0].nome).toBe('Articolo Test')

    // Verifica che l'audit sia stato loggato
    const { rows: audit } = await client.query(
      `SELECT * FROM registro_audit WHERE tabella = 'articoli' AND azione = 'CREATE'`
    )
    expect(audit).toHaveLength(1)
    expect(audit[0].record_id).toBe(String(result.id))
  })

  it('rifiuta codice duplicato', async () => {
    await client.query(
      'INSERT INTO articoli (codice, nome) VALUES ($1, $2)', ['DUP001', 'Esistente']
    )

    const result = await creaArticolo({ codice: 'DUP001', nome: 'Duplicato', categoria_id: 1 })
    expect(result.success).toBe(false)
    expect(result.error).toContain('codice')
  })
})
```

### Integration test per evasione richiesta (flusso critico)

```typescript
it('evasione aggiorna giacenza atomicamente', async () => {
  // Setup: articolo con giacenza 50
  const { rows: [art] } = await client.query(
    'INSERT INTO articoli (codice, nome) VALUES ($1,$2) RETURNING id', ['ART', 'Articolo']
  )
  await client.query(
    'INSERT INTO giacenze_correnti (articolo_id, sede_id, giacenza) VALUES ($1, 1, 50)', [art.id]
  )

  // Evadi richiesta di 30 pezzi
  await evadirichiesta({ righe: [{ articolo_id: art.id, quantita: 30, salta: false }] })

  // Giacenza deve essere 20
  const { rows: [g] } = await client.query(
    'SELECT giacenza FROM giacenze_correnti WHERE articolo_id = $1 AND sede_id = 1', [art.id]
  )
  expect(Number(g.giacenza)).toBe(20)
})

it('blocca evasione se giacenza insufficiente', async () => {
  // Giacenza = 5, richiesta = 10
  await expect(
    evadirichiesta({ righe: [{ articolo_id: 1, quantita: 10, salta: false }] })
  ).rejects.toThrow('giacenza_insufficiente')
})
```

## OPENAPI CONTRACT TESTING

### Installa

```bash
npm install @asteasolutions/zod-to-openapi
npm install -D supertest @types/supertest
```

### Genera spec OpenAPI (zod-openapi)

```typescript
// lib/openapi.ts
import { OpenAPIRegistry, OpenApiGeneratorV3 } from '@asteasolutions/zod-to-openapi'
import { z } from 'zod'

export const registry = new OpenAPIRegistry()

export const ArticoloSchema = registry.register('Articolo', z.object({
  id: z.number(),
  codice: z.string(),
  nome: z.string(),
  categoria_id: z.number(),
}))

registry.registerPath({
  method: 'get',
  path: '/api/articoli/{id}',
  summary: 'Recupera articolo per ID',
  request: {
    params: z.object({ id: z.string() }),
  },
  responses: {
    200: {
      description: 'Articolo trovato',
      content: { 'application/json': { schema: ArticoloSchema } },
    },
    404: { description: 'Non trovato' },
  },
})

export function generateOpenAPISpec() {
  const generator = new OpenApiGeneratorV3(registry.definitions)
  return generator.generateDocument({
    openapi: '3.0.0',
    info: { title: 'API', version: '1.0.0' },
    servers: [{ url: '/api' }],
  })
}
```

### Contract test

```typescript
// src/tests/contract/articoli.contract.test.ts
import { describe, it, expect } from 'vitest'
import request from 'supertest'

const BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000'

describe('Contract: GET /api/articoli/:id', () => {
  it('rispetta lo schema OpenAPI per 200', async () => {
    const res = await request(BASE_URL)
      .get('/api/articoli/1')
      .set('Authorization', `Bearer ${process.env.TEST_API_KEY}`)

    expect(res.status).toBe(200)
    expect(res.body).toMatchObject({
      id: expect.any(Number),
      codice: expect.any(String),
      nome: expect.any(String),
    })
  })

  it('ritorna 404 per ID inesistente', async () => {
    const res = await request(BASE_URL).get('/api/articoli/99999')
    expect(res.status).toBe(404)
  })

  it('ritorna 401 senza auth', async () => {
    const res = await request(BASE_URL).get('/api/articoli/1')
    expect(res.status).toBe(401)
  })
})
```

### Endpoint spec OpenAPI

```typescript
// app/api/openapi.json/route.ts — endpoint della spec
import { generateOpenAPISpec } from '@/lib/openapi'

export async function GET() {
  return Response.json(generateOpenAPISpec())
}
```

### Script generazione spec (package.json)

```json
{
  "scripts": {
    "gen:openapi": "tsx scripts/generate-openapi.ts",
    "test:contract": "vitest run src/tests/contract"
  }
}
```

### Validazione con spectral

```bash
npm install -g @stoplight/spectral-cli
echo 'extends: ["spectral:oas"]' > .spectral.yaml
curl http://localhost:3000/api/openapi.json -o spec.json
spectral lint spec.json
```

## COMANDI

```bash
# Unit + Integration
npm test                          # tutti i test
npm run test:coverage             # con coverage report
npm run test:watch                # watch mode

# Tutto insieme (CI)
npm run test && npx playwright test && k6 run k6/advisory-lock.js
```
