# Playwright — E2E Test

Doc ufficiale: https://playwright.dev/docs/intro

## Setup

```bash
npm install -D @playwright/test
npx playwright install
```

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

## Flusso critico — Login → Crea Richiesta → Verifica

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

## Comandi Playwright

```bash
npx playwright test               # tutti gli E2E
npx playwright test --headed      # con browser visibile
npx playwright show-report        # report HTML
```
