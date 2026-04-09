---
name: omega-blueprints
description: Use when selecting project architecture based on type. Provides complete folder structure, navigation patterns, security defaults, UX patterns, and recommended tier for 7 project types. Called by omega-wizard after project type is determined.
user-invocable: false
---

# omega-blueprints — 7 Architetture per Tipo Progetto

**Lingua:** Sempre italiano.
**Principio:** Ogni tipo di progetto ha pattern architetturali diversi. Scegli il blueprint corretto prima di scrivere una riga di codice.

## I 7 BLUEPRINT

| Blueprint | Quando | Tier consigliato | Auth | DB |
|-----------|--------|-----------------|------|----|
| Gestionale/ERP | Tool interno, team aziendale | 1-2 | Obbligatoria | PostgreSQL pg diretto |
| SaaS B2C | Prodotto per utenti finali | 2-3 | Obbligatoria | PostgreSQL + tenant isolation |
| E-commerce | Vendita prodotti/servizi | 2 | Opzionale | PostgreSQL + Stripe |
| Landing | Presentazione, conversione | 2-3 | No | Nessuno |
| Showcase/Portfolio | Gallery, portfolio dev | 3-4 | Opzionale | Minimo o nessuno |
| Mobile Expo | App iOS + Android | 2 | Obbligatoria | Supabase |
| CLI/Bot | Automazione, script, bot | N/A | Config-based | SQLite o nessuno |
| Monorepo | Turborepo + pnpm workspaces, design system condiviso, multi-app deployment | 2-3 | Per app | PostgreSQL condiviso via packages/database |

## FLUSSO

1. Determina il tipo di progetto dal wizard
2. Leggi il blueprint corrispondente in references/
3. Adatta la struttura al caso specifico (non copiare ciecamente)
4. Segnala all'utente le decisioni architetturali chiave

## REGOLA ADATTAMENTO

Il blueprint è un punto di partenza, non una prigione. Se il progetto ha caratteristiche ibride (es. SaaS con parti landing), usa il blueprint principale e integra pattern dall'altro. Documenta le deviazioni in CLAUDE.md.

## REFERENCES
Per struttura completa di ogni blueprint:
- [references/gestionale.md] — ERP, multi-ruolo, audit trail, advisory lock
- [references/saas.md] — Multi-tenant, subscription, onboarding
- [references/ecommerce.md] — Catalogo, carrello, checkout, inventory
- [references/landing.md] — Conversione, SEO, form, Lighthouse
- [references/showcase.md] — Gallery, animazioni, portfolio
- [references/mobile.md] — Expo, EAS Build, store submission
- [references/cli-bot.md] — Commander, bot Discord/Telegram, GitHub Actions
- [references/monorepo.md] — Turborepo, pnpm workspaces, shared packages, multi-app deploy
