# Raccomandazioni Stack per Tipo Progetto

Raccomandazioni pre-costruite per ogni tipo di progetto. Adattate in base a vincoli dell'utente.

---

## GESTIONALE / ERP

**Caso d'uso:** app interne aziendali, gestionali HR/magazzino/ordini, ERP light

```
Frontend:  Next.js App Router     — full-stack, SSR, route groups per ruoli
CSS/UI:    Tailwind + shadcn/ui    — componenti tabelle/form pronti, consistenza
Database:  PostgreSQL              — transazioni ACID, vincoli FK, scalabile
ORM:       pg diretto              — tabelle append-only (movimenti/audit), aggregazioni
Auth:      Auth.js v5              — session-based, RBAC custom, email/password
Deploy:    Vercel o VPS            — Vercel per semplicità, VPS per dati sensibili
Email:     Resend + React Email    — notifiche automatiche, report
```

**Pattern critici:** advisory lock per numerazione, audit trail su ogni write, RBAC granulare, transazioni multi-tabella, summary table per giacenze.

**Costo stimato:** €0-25/mese (Vercel + Supabase) o €10-40/mese (VPS)

---

## SAAS B2C (consumatori finali)

**Caso d'uso:** tool online, produttività personale, abbonamenti consumer

```
Frontend:  Next.js App Router     — SEO, landing + app nella stessa codebase
CSS/UI:    Tailwind + shadcn/ui + Framer Motion — onboarding curato, Tier 2
Database:  Supabase                — Auth + RLS + Realtime inclusi
ORM:       Prisma                  — CRUD semplice, migration gestite
Auth:      Supabase Auth           — OAuth social (Google/GitHub), magic link
Pagamenti: Stripe                  — abbonamenti, Customer Portal, trial
Deploy:    Vercel                  — CI/CD automatico, preview per PR
Email:     Resend                  — welcome, fatture, notifiche
```

**Costo stimato:** €0-45/mese

---

## SAAS B2B / ENTERPRISE

**Caso d'uso:** software venduto ad aziende, multi-tenant, SSO richiesto

```
Frontend:  Next.js App Router     — separazione tenant, subdomain routing
CSS/UI:    Tailwind + shadcn/ui    — look professionale, white-labeling
Database:  PostgreSQL + Redis      — PostgreSQL per dati, Redis per cache/session
ORM:       Prisma + pg diretto     — Prisma per CRUD, pg diretto per query RLS
Auth:      Auth.js v5 o Clerk      — SAML/SSO, multi-tenant org, inviti team
Pagamenti: Stripe                  — piani per seats, volume discounts
Deploy:    Vercel o Railway        — Vercel per frontend, Railway per jobs background
Email:     Resend + Postmark       — Resend per marketing, Postmark per transazionale
Monitor:   Sentry + Datadog        — error tracking + APM enterprise
```

**Pattern critici:** tenant isolation schema-per-tenant o row-level, subdomain routing, feature flags per piano.

**Costo stimato:** €50-200/mese (a seconda della scala)

**⚠️ Nota RLS:** Prisma bypassa Row Level Security per default. Per query tenant-sensitive
usa pg diretto o un connection pooler RLS-aware. Vedi omega-multitenant per il pattern completo.

---

## E-COMMERCE

**Caso d'uso:** negozio online prodotti fisici/digitali, marketplace

```
Frontend:  Next.js App Router     — ISR per pagine prodotto, SEO ottimizzato
CSS/UI:    Tailwind + shadcn/ui    — product card, checkout flow pulito
Database:  PostgreSQL              — inventory management, ordini, ACID
ORM:       Prisma                  — modello prodotti/varianti/inventario
Auth:      Auth.js v5              — account cliente, guest checkout
Pagamenti: Stripe                  — checkout, webhook ordini, rimborsi
Deploy:    Vercel                  — CDN globale, ISR per catalogo
Email:     Resend                  — conferma ordine, spedizione, rimborso
Storage:   Cloudinary o Vercel Blob — immagini prodotto con trasformazioni
```

**Pattern critici:** inventory lock (no overselling), prezzi server-side, webhook idempotenti, redirect 301 SEO.

**Costo stimato:** €20-50/mese + commissioni Stripe

---

## LANDING PAGE / MARKETING

**Caso d'uso:** landing per prodotto/servizio, pagine marketing, waitlist

```
Frontend:  Astro                   — zero JS per default, Lighthouse 100
CSS/UI:    Tailwind                — utility-first, mobile-first
Deploy:    Vercel o Netlify        — CDN globale, deploy da git
Email:     Resend                  — form contatto, waitlist
Analytics: Vercel Analytics o Plausible — privacy-first, no cookie banner
```

**Tier 3 (CINEMATIC):** aggiungi GSAP + Lenis per animazioni scroll.

**Pattern critici:** Lighthouse ≥ 90, sitemap.xml, Open Graph, form honeypot anti-spam.

**Costo stimato:** €0-5/mese

---

## PORTFOLIO / SHOWCASE

**Caso d'uso:** portfolio creativo, CV interattivo, showcase progetti

```
Frontend:  Astro o Next.js         — Astro per static, Next.js se blog+CMS
CSS/UI:    Tailwind + GSAP/Framer  — animazioni curate, Tier 2-3
Deploy:    Vercel                  — gratis, CDN globale
CMS:       Contentlayer o MDX      — blog/case study in Markdown
Analytics: Plausible               — privacy-first
```

**Tier 4 (IMMERSIVO):** Three.js / React Three Fiber per hero 3D, particelle, WebGL.

**Costo stimato:** €0/mese

---

## APP MOBILE (iOS + Android)

**Caso d'uso:** app consumer o B2B su smartphone

```
Mobile:    Expo (React Native)     — cross-platform iOS + Android, stesso codebase
Backend:   Next.js API o Supabase  — API REST o diretto Supabase SDK
Database:  Supabase                — Realtime, Auth mobile, Storage
Auth:      Supabase Auth           — OAuth nativo iOS/Google, magic link
Notifiche: Expo Notifications      — push notification iOS + Android
Deploy:    EAS Build (Expo)        — build cloud, distribuzione store
```

**Costi aggiuntivi:** €99/anno (Apple Developer) + €25 una tantum (Google Play)

**Costo stimato:** €25-50/mese + store fees

---

## API REST / BACKEND PURA

**Caso d'uso:** API standalone, microservizio, backend per app mobile/SPA

```
Backend:   Hono o Express          — Hono per edge/serverless, Express per VPS classico
Database:  PostgreSQL              — relazionale, pg diretto per performance
ORM:       pg diretto o Drizzle    — controllo query, no overhead ORM
Auth:      JWT + middleware         — stateless, API key per M2M
Deploy:    Railway o Fly.io o VPS  — container, scaling facile
Docs:      OpenAPI + Scalar        — spec valida, UI documentation
Testing:   Vitest + k6             — unit + load test
```

**Pattern critici:** rate limiting per IP + API key, request validation Zod, versioning /v1/, health check.

**Costo stimato:** €5-20/mese

---

## CLI / BOT / SCRIPT

**Caso d'uso:** tool CLI, bot Discord/Telegram, script automazione, GitHub Actions

```
Runtime:   Node.js o Bun           — Node.js consolidato, Bun per performance
Framework: Commander.js (CLI)      — parsing argomenti, subcommand, help automatico
           discord.js (Discord)    — event-driven, slash commands
           Telegraf (Telegram)     — Telegram Bot API
Database:  SQLite (locale) o pg    — SQLite per tool personali, pg per multi-user
Deploy:    VPS o Railway o self     — CLI: npm publish, bot: server sempre attivo
```

**Pattern critici:** error handling graceful, .env per token/segreti, aggiornamenti automatici.

**Costo stimato:** €0-10/mese (bot su server economico)

---

## PYTHON / DATA / AI

**Caso d'uso:** API Python, ML pipeline, data processing, RAG, AI backend

```
Backend:   FastAPI                 — async, OpenAPI auto, type hints
ORM:       SQLAlchemy 2.0          — async ORM, Alembic per migrations
Database:  PostgreSQL + pgvector   — pgvector per embeddings/RAG
AI:        Anthropic SDK o OpenAI SDK — LLM integration
Vector:    pgvector o Pinecone     — pgvector se già su PostgreSQL, Pinecone per scala
Deploy:    Railway o Fly.io        — Docker container, Python 3.12+
Testing:   pytest + httpx          — unit + integration test
```

**Pattern critici:** Pydantic validation, async tutto (no sync blocking), Docker per reproducibilità.

**Costo stimato:** €5-30/mese

---

## COMBINAZIONI CON SINERGIA ALTA

| Stack A | Stack B | Perché funzionano insieme |
|---------|---------|--------------------------|
| Next.js | Supabase | Auth + RLS + Realtime integrati, SDK ottimizzato |
| Next.js | Vercel | Deploy nativo, ISR, Edge Functions, Analytics |
| Astro | Cloudflare Pages | Zero JS, CDN globale, Workers per edge logic |
| FastAPI | PostgreSQL + pgvector | RAG pipeline, pgvector per embeddings |
| Expo | Supabase | Auth mobile nativa, Realtime, Storage SDK |
| Hono | Cloudflare Workers | Edge-first, latenza minima, zero cold start |
| Next.js | Stripe + Resend | SaaS completo: pagamenti + email in ore |
| Railway | PostgreSQL | Deploy + DB nella stessa piattaforma, network interno |

---

## COMBINAZIONI DA EVITARE

| Combinazione | Motivo |
|--------------|--------|
| Styled Components + Next.js App Router | CSS-in-JS non compatibile con React Server Components |
| Emotion + RSC | Stessa limitazione di Styled Components |
| TypeORM con schema complesso | Manutenzione pesante, migration fragili su schema grande |
| Firebase + PostgreSQL | Due database diversi senza motivo, complessità inutile |
| Mongoose + PostgreSQL | ODM MongoDB con DB relazionale — stack incoerente |
| Prisma su tabelle append-only crescenti | Performance degradata su milioni di righe, usa pg diretto |
