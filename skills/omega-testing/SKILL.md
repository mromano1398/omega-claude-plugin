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

## QUANDO USARE

- Setup iniziale test suite in un nuovo progetto
- Scrittura test per una nuova feature
- Verifica coverage prima del deploy
- Load test per validare performance sotto concorrenza

## FLUSSO — Scegli il tipo di test

```
Logica pura (calcoli, validators, formatters) → Unit test (Vitest)
Server actions + DB reale → Integration test (Vitest + transazione rollback)
Flusso utente completo → E2E (Playwright)
Concorrenza + performance → Load test (k6)
API con contratto OpenAPI → Contract test (supertest + spectral)
```

## REGOLE CHIAVE

1. **Mai mockare il DB negli integration test** — usa DB di test reale con transazioni rollback
2. **Ogni integration test parte pulito** — ROLLBACK garantisce isolamento
3. **Load test obbligatorio su advisory lock** — verifica zero duplicati sotto concorrenza
4. **Coverage ≥ 80% su business logic** — non su componenti UI
5. **DB di test separato da produzione** — mai `.env` di prod nei test
6. **E2E sui flussi critici** — almeno login → operazione principale → verifica
7. **CI deve girare tutti i test** — unit + integration + E2E + load

## CHECKLIST SINTETICA

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

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/vitest.md] — setup Vitest, unit test, integration test con rollback, OpenAPI contract testing
- [references/playwright.md] — setup Playwright, config, flussi E2E completi
- [references/k6.md] — load test advisory lock, performance test, strategie per tipo progetto
