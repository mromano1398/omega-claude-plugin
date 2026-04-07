---
name: omega-testing
description: Use when setting up tests, writing unit/integration/E2E/load tests, configuring Vitest/Playwright/k6, or running the test suite. Triggered by menu option [T] Testing or when a plan phase requires test coverage.
user-invocable: false
---

# omega-testing — Unit · Integration · E2E · Load

**Lingua:** Sempre italiano. Riferimenti:
- Vitest: https://vitest.dev/guide
- Playwright: https://playwright.dev/docs/intro
- k6: https://k6.io/docs

---

## STRATEGIA PER TIPO PROGETTO

| Tipo | Unit | Integration | E2E | Load |
|---|---|---|---|---|
| Gestionale/ERP | helpers, calcoli, formatters | server actions + DB reale | login→richiesta→evasione→giacenza | advisory lock (10 req simultane) |
| SaaS | business logic, webhook proc | auth flow, subscription | signup→payment→feature | endpoint critici |
| API pura | handlers, validators, middleware | endpoint + DB reale | — | k6: ≥ 100 req/s |
| E-commerce | calcoli prezzi, IVA | carrello, pagamento | browse→cart→checkout | checkout concorrente |
| Landing | — | form submission | pagina → form → conferma | — |

**Regola critica:** Mai mockare il DB per integration test. Testa su DB di test reale con transazioni rollback.

---

## SETUP

### Installazione

```bash
# Unit + Integration
npm install -D vitest @vitest/coverage-v8

# E2E
npm install -D @playwright/test
npx playwright install

# Load test
npm install -g k6
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

---

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

---

## INTEGRATION TEST (DB reale, no mock)

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
  // In produzione usa dependency injection o context
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

---

## E2E TEST (Playwright)

### `playwright.config.ts`

```typescript
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: process.env.E2E_BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
  ],
})
```

### Flusso critico — Login → Crea Richiesta → Verifica

```typescript
// e2e/richiesta.spec.ts
import { test, expect } from '@playwright/test'

test.describe('flusso richiesta materiale', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('[name=email]', 'admin@test.com')
    await page.fill('[name=password]', 'password123')
    await page.click('button[type=submit]')
    await expect(page).toHaveURL('/dashboard')
  })

  test('crea richiesta e compare nella lista', async ({ page }) => {
    await page.goto('/richieste/nuova')

    // Seleziona cantiere (cascading fields)
    await page.selectOption('[name=cliente_id]', '1')
    await page.waitForSelector('[name=commessa_id] option:not([disabled])')
    await page.selectOption('[name=commessa_id]', '1')
    await page.waitForSelector('[name=cantiere_id] option:not([disabled])')
    await page.selectOption('[name=cantiere_id]', '1')

    // Aggiungi articolo
    await page.click('[data-testid=aggiungi-riga]')
    await page.fill('[data-testid=cerca-articolo]', 'cavo')
    await page.click('[data-testid=articolo-result]:first-child')
    await page.fill('[data-testid=quantita-0]', '10')

    await page.click('[data-testid=invia-richiesta]')
    await expect(page.locator('[data-testid=toast-success]')).toBeVisible()

    // Verifica che appaia nella lista
    await page.goto('/richieste')
    await expect(page.locator('[data-testid=richiesta-row]').first()).toBeVisible()
  })
})
```

---

## LOAD TEST (k6)

### Test advisory lock — No duplicati sotto concorrenza

```javascript
// k6/advisory-lock.js
import http from 'k6/http'
import { check } from 'k6'

export const options = {
  vus: 10,          // 10 virtual users simultanei
  iterations: 100,  // 100 richieste totali
}

export default function() {
  const res = http.post(
    'http://localhost:3000/api/ddt/entrata',
    JSON.stringify({ fornitore_id: 1, articoli: [{ id: 1, quantita: 1 }] }),
    { headers: { 'Content-Type': 'application/json', 'Cookie': `session=${__ENV.SESSION}` } }
  )

  check(res, {
    'status 200': r => r.status === 200,
    'ha numero DDT': r => JSON.parse(r.body).numero !== undefined,
  })
}

// Dopo il test: verifica no numeri duplicati
// SELECT numero, COUNT(*) FROM ddt GROUP BY numero HAVING COUNT(*) > 1;
```

### Test performance API

```javascript
// k6/api-performance.js
import http from 'k6/http'
import { sleep } from 'k6'

export const options = {
  stages: [
    { duration: '30s', target: 20 },   // Ramp up
    { duration: '1m', target: 50 },    // Hold
    { duration: '30s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% delle req < 500ms
    http_req_failed: ['rate<0.01'],    // < 1% errori
  },
}

export default function() {
  http.get('http://localhost:3000/api/giacenze?sede_id=1')
  sleep(1)
}
```

### Esecuzione

```bash
k6 run k6/advisory-lock.js
k6 run k6/api-performance.js

# Con output summary
k6 run --summary-trend-stats="avg,p(90),p(95),p(99)" k6/api-performance.js
```

---

## OPENAPI CONTRACT TESTING (Progetti API)

Per progetti di tipo API, aggiungi contract testing con OpenAPI.

### Genera spec OpenAPI da Next.js (zod-openapi)

```bash
npm install @asteasolutions/zod-to-openapi
```

```typescript
// lib/openapi.ts
import { OpenAPIRegistry, OpenApiGeneratorV3 } from '@asteasolutions/zod-to-openapi'
import { z } from 'zod'

export const registry = new OpenAPIRegistry()

// Registra schema
export const ArticoloSchema = registry.register('Articolo', z.object({
  id: z.number(),
  codice: z.string(),
  nome: z.string(),
  categoria_id: z.number(),
}))

// Registra endpoint
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

// Genera spec YAML/JSON
export function generateOpenAPISpec() {
  const generator = new OpenApiGeneratorV3(registry.definitions)
  return generator.generateDocument({
    openapi: '3.0.0',
    info: { title: 'API', version: '1.0.0' },
    servers: [{ url: '/api' }],
  })
}
```

```typescript
// app/api/openapi.json/route.ts — endpoint della spec
import { generateOpenAPISpec } from '@/lib/openapi'

export async function GET() {
  return Response.json(generateOpenAPISpec())
}
```

### Contract test con supertest

```bash
npm install -D supertest @types/supertest
```

```typescript
// src/tests/contract/articoli.contract.test.ts
import { describe, it, expect } from 'vitest'
import request from 'supertest'

// Crea server Next.js per i test
const BASE_URL = process.env.TEST_BASE_URL || 'http://localhost:3000'

describe('Contract: GET /api/articoli/:id', () => {
  it('rispetta lo schema OpenAPI per 200', async () => {
    const res = await request(BASE_URL)
      .get('/api/articoli/1')
      .set('Authorization', `Bearer ${process.env.TEST_API_KEY}`)

    expect(res.status).toBe(200)

    // Verifica struttura risposta
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

### Validazione spec con spectral

```bash
npm install -g @stoplight/spectral-cli

# Crea .spectral.yaml
echo 'extends: ["spectral:oas"]' > .spectral.yaml

# Valida spec (in CI)
curl http://localhost:3000/api/openapi.json -o spec.json
spectral lint spec.json
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

---

## COMANDI

```bash
# Unit + Integration
npm test                          # tutti i test
npm run test:coverage             # con coverage report
npm run test:watch                # watch mode

# E2E
npx playwright test               # tutti gli E2E
npx playwright test --headed      # con browser visibile
npx playwright show-report        # report HTML

# Load
k6 run k6/advisory-lock.js        # test lock
k6 run k6/api-performance.js      # test performance

# Tutto insieme (CI)
npm run test && npx playwright test && k6 run k6/advisory-lock.js
```

---

## CHECKLIST TEST

- [ ] Unit test: helpers, calcoli, validators
- [ ] Integration test: server actions con DB reale (transazione rollback)
- [ ] Integration test: flussi critici (evasione, giacenza, numerazione)
- [ ] E2E: flusso principale dell'applicazione
- [ ] Load test: advisory lock → zero duplicati sotto concorrenza
- [ ] Load test: endpoint critici ≥ target performance
- [ ] Coverage ≥ 80% su moduli business logic
- [ ] Tutti i test passano in CI con DB di test isolato
- [ ] Nessun test che usa `.env` di produzione
- [ ] [Solo API] Spec OpenAPI generata e validata con spectral
- [ ] [Solo API] Contract test per ogni endpoint pubblico
- [ ] [Solo API] Test 401/403 per ogni route protetta
