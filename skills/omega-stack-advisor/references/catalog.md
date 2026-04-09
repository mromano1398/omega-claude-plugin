# Catalogo Tecnologie — omega-stack-advisor

Catalogo di riferimento per tutte le tecnologie supportate, organizzato per categoria.
**Tier supporto:** T1 = pattern completi | T2 = pattern base + docs | T3 = guidance generica

---

## 1. FRONTEND

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Next.js App Router | T1 | Gratis | Full-stack React, SSR/SSG/ISR, deployment nativo Vercel. Stack di default per web app |
| Astro | T1 | Gratis | Zero JS per default, islands architecture. Ideale per landing, blog, siti content-heavy |
| Remix | T2 | Gratis | Web-first, form handling ottimo, loader/action pattern |
| SvelteKit | T2 | Gratis | Bundle minimo, sintassi pulita, buona per app leggere |
| Nuxt.js | T2 | Gratis | Vue ecosystem, SSR/SSG, ottimo per chi conosce Vue |
| Vite + React | T2 | Gratis | SPA pura, nessun SSR. Per tool interni o dashboard senza SEO |
| Angular | T3 | Gratis | Enterprise, opinionated, team grande |
| Qwik | T3 | Gratis | Resumability pattern, performance estrema |

---

## 2. CSS / UI FRAMEWORK

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Tailwind CSS v4 | T1 | Gratis | Utility-first, ottimo con Next.js + shadcn. Standard omega |
| shadcn/ui | T1 | Gratis | Componenti Radix UI + Tailwind, copia nel progetto (no dependency lock) |
| Framer Motion | T1 | Gratis | Animazioni React. Standard per Tier 2 (PROFESSIONALE) |
| GSAP + Lenis | T1 | Gratis* | Animazioni avanzate + smooth scroll. Standard Tier 3 (CINEMATIC). *GSAP Club per alcuni plugin |
| Three.js / R3F | T1 | Gratis | 3D nel browser. Standard Tier 4 (IMMERSIVO) |
| CSS Modules | T2 | Gratis | Scoping CSS classico, senza utility |
| Styled Components | T2 | Gratis | CSS-in-JS, non compatibile con App Router RSC |
| Emotion | T2 | Gratis | CSS-in-JS, stessa limitazione RSC |
| Chakra UI | T2 | Gratis | Component library opinionated |
| MUI / Material UI | T2 | Gratis | Material Design, enterprise look |
| Mantine | T2 | Gratis | Componenti ricchi, bundle pesante |
| DaisyUI | T2 | Gratis | Plugin Tailwind con temi preconfezionati |

---

## 3. BACKEND / RUNTIME

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Next.js API Routes / Server Actions | T1 | Gratis | Full-stack nello stesso progetto. Default per web app |
| Node.js + Hono | T1 | Gratis | API standalone leggera, ottimo per microservizi |
| Node.js + Express | T1 | Gratis | Classico, flessibile, documentazione enorme |
| FastAPI (Python) | T1 | Gratis | Python async, OpenAPI automatico, ottimo per AI/ML |
| Flask (Python) | T2 | Gratis | Micro-framework Python, semplice ma meno strutturato |
| Django | T2 | Gratis | Batteries-included, ORM proprio, admin panel |
| NestJS | T2 | Gratis | TypeScript backend, architettura moduli, enterprise |
| Fastify | T2 | Gratis | Node.js veloce, plugin ecosystem |
| Bun | T2 | Gratis | Runtime JS veloce, compatibile con molti package Node |
| Deno | T3 | Gratis | Sicuro per default, runtime alternativo |
| Go (stdlib/Gin) | T3 | Gratis | Performance alta, tipizzazione forte |
| Rust (Axum/Actix) | T3 | Gratis | Performance massima, curva ripida |
| PHP (Laravel) | T3 | Gratis | Matura, ottimo hosting condiviso |

---

## 4. DATABASE

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| PostgreSQL (self-hosted) | T1 | €5-20/mese (VPS) | Relazionale solido, feature-ricco, standard omega |
| Supabase (PostgreSQL hosted) | T1 | Gratis → €25/mese | PostgreSQL + Auth + Storage + Realtime. Ottimo per SaaS |
| SQLite | T1 | Gratis | File locale, ottimo per tool personali e prototipi |
| MySQL / MariaDB | T2 | €5-20/mese | Diffuso, buon hosting, meno feature di PostgreSQL |
| MongoDB | T2 | Gratis → €57/mese | Document store, schema flessibile, Atlas cloud |
| PlanetScale | T2 | Gratis → $39/mese | MySQL serverless, branching schema |
| Neon | T2 | Gratis → $19/mese | PostgreSQL serverless, ottimo per Vercel |
| Turso (libSQL) | T2 | Gratis → $29/mese | SQLite distribuito, edge-friendly |
| Redis | T2 | Gratis → $7/mese (Upstash) | Cache, session, rate limiting, pub/sub |
| Firestore | T3 | Gratis → pay-as-you-go | Google NoSQL, realtime, legato a Firebase |
| DynamoDB | T3 | Pay-as-you-go | AWS NoSQL, serverless nativo, complessità alta |
| ClickHouse | T3 | Self-hosted / cloud | Analytics OLAP, query su miliardi di righe |

---

## 5. ORM / QUERY BUILDER

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| pg (node-postgres diretto) | T1 | Gratis | Controllo totale, transazioni complesse, aggregazioni. Preferibile per tabelle append-only |
| Prisma | T1 | Gratis | ORM type-safe, migrations automatiche. Ottimo per CRUD semplice |
| Drizzle ORM | T1 | Gratis | ORM leggero, type-safe, SQL-like API |
| SQLAlchemy | T1 | Gratis | Python ORM maturo, async con SQLAlchemy 2.0 |
| Knex.js | T2 | Gratis | Query builder SQL, flessibile, meno type-safe |
| TypeORM | T2 | Gratis | Decorator-based, pesante, usato con NestJS |
| Mongoose | T2 | Gratis | ODM per MongoDB |
| Sequelize | T3 | Gratis | ORM classico Node.js, verboso |

---

## 6. AUTH / IDENTITY

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Auth.js v5 (NextAuth) | T1 | Gratis | Standard per Next.js, provider OAuth, email/password |
| Supabase Auth | T1 | Gratis (nel piano Supabase) | OAuth + magic link + MFA, integrato con RLS |
| Clerk | T2 | Gratis → $25/mese | Hosted auth UI, componenti React pronti, multi-tenant |
| Lucia Auth | T2 | Gratis | Leggera, session-based, controllo totale |
| BetterAuth | T2 | Gratis | Auth moderna per TypeScript, plugin ecosystem |
| Kinde | T2 | Gratis → $25/mese | Hosted, OAuth, RBAC incluso |
| Auth0 | T2 | Gratis → $23/mese | Enterprise identity, SAML, SSO |
| Firebase Auth | T3 | Gratis → pay-as-you-go | OAuth + phone, legato a Firebase |
| AWS Cognito | T3 | Pay-as-you-go | Enterprise, SAML, complesso da configurare |

---

## 7. PAGAMENTI

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Stripe | T1 | 1.5% + €0.25 / transazione EU | Standard industry, abbonamenti, webhook, Customer Portal |
| LemonSqueezy | T2 | 5% + $0.50 / transazione | Merchant of Record (gestisce IVA), ottimo per SaaS indie |
| Paddle | T2 | 5% + $0.50 | Merchant of Record, global tax compliance |
| PayPal | T2 | 2.9% + $0.30 | Diffuso, meno developer-friendly di Stripe |
| Braintree | T3 | Simile PayPal | Owned by PayPal, enterprise |

---

## 8. EMAIL TRANSAZIONALE

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Resend | T1 | Gratis (3k email/mese) → $20/mese | Developer-first, React Email, ottimo DX |
| Nodemailer + SMTP | T1 | Gratis (+ costo SMTP) | Controllo totale, hosting SMTP personale |
| SendGrid | T2 | Gratis (100/giorno) → $19.95/mese | Storico, enterprise, statistiche avanzate |
| Postmark | T2 | $15/mese (10k) | Focus deliverability, ottimo per transazionale |
| Mailgun | T2 | $35/mese (50k) | API solida, verifica email |
| Amazon SES | T3 | $0.10 / 1000 email | Economico su scala, setup complesso |

---

## 9. STORAGE / MEDIA

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Supabase Storage | T1 | Gratis (nel piano) | S3-compatible, RLS, ottimo con Supabase stack |
| Vercel Blob | T1 | Gratis (2GB) → pay-as-you-go | Integrato con Vercel, semplice API |
| Cloudinary | T2 | Gratis (25GB) → $89/mese | Trasformazioni immagini on-the-fly, CDN |
| AWS S3 | T2 | Pay-as-you-go | Standard industry, economico su scala |
| Uploadthing | T2 | Gratis → $10/mese | Developer-friendly, Next.js integration |
| Cloudflare R2 | T2 | Gratis (10GB) → $0.015/GB | Economico, zero egress fee, S3-compatible |
| MinIO (self-hosted) | T3 | Gratis (self-hosted) | S3-compatible on-premise |

---

## 10. DEPLOY / HOSTING

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Vercel | T1 | Gratis → $20/mese | Deploy Next.js nativo, preview automatici, edge network |
| Railway | T1 | $5/mese | Full-stack deploy, DB incluso, ottimo per backend |
| Fly.io | T1 | Gratis → pay-as-you-go | Container deploy globale, ottimo per API |
| VPS + Docker | T1 | €5-20/mese | Controllo totale, /omega:omega-devops per setup |
| Netlify | T2 | Gratis → $19/mese | Ottimo per static/Astro, meno per full-stack |
| Render | T2 | Gratis → $7/mese | Deploy semplice, free tier lento |
| DigitalOcean App Platform | T2 | $5/mese | Managed platform, meno feature di Vercel |
| AWS (EC2/ECS/Lambda) | T3 | Pay-as-you-go | Enterprise, complessità alta |
| Google Cloud Run | T3 | Pay-as-you-go | Container serverless, buon free tier |
| Heroku | T3 | $5/mese | Classico, costoso su scala |

---

## 11. ANALYTICS

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Vercel Analytics | T1 | Gratis → $14/mese | Integrato, privacy-first, nessun cookie banner |
| PostHog | T1 | Gratis (1M eventi) | Open source, self-hostable, product analytics |
| Plausible | T2 | €9/mese | Privacy-first, GDPR compliant, leggero |
| Fathom | T2 | $15/mese | Privacy-first, GDPR/CCPA |
| Google Analytics 4 | T2 | Gratis | Standard, richiede cookie consent |
| Mixpanel | T2 | Gratis → $28/mese | Funnel analysis, retention |
| Amplitude | T3 | Gratis → $61/mese | Product analytics avanzato, enterprise |

---

## 12. MONITORING / ERROR TRACKING

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Sentry | T1 | Gratis (5k errori) → $26/mese | Standard error tracking, performance monitoring |
| Vercel Observability | T1 | Gratis → piano Vercel | Integrato, Core Web Vitals, edge logs |
| Datadog | T2 | $15/host/mese | APM completo, enterprise |
| New Relic | T2 | Gratis (100GB) | APM, infrastructure, logs |
| Grafana + Prometheus | T3 | Gratis (self-hosted) | Stack monitoring completo, setup complesso |
| BetterStack | T2 | Gratis → $24/mese | Uptime + log management, ottimo DX |
| LogTail | T2 | Gratis → $15/mese | Log management integrato con BetterStack |

---

## 13. SEARCH

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| PostgreSQL Full-Text Search | T1 | Incluso in PostgreSQL | Sufficiente per la maggior parte dei casi |
| Algolia | T2 | Gratis (10k operazioni) → $50/mese | Search-as-a-service, ottimo DX, velocissimo |
| Meilisearch | T2 | Gratis (self-hosted) | Open source, typo-tolerant, ottima alternative Algolia |
| Typesense | T2 | Gratis (self-hosted) | Similar Meilisearch, Typesense Cloud disponibile |
| Elasticsearch | T3 | Self-hosted / Elastic Cloud | Enterprise, complesso, ottimo su dati enormi |
| Pinecone | T3 | Gratis → $70/mese | Vector search per AI/RAG |

---

## 14. AI / LLM

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Anthropic Claude API | T1 | Pay-as-you-go | Claude Opus/Sonnet/Haiku, tool calling, vision |
| OpenAI API | T1 | Pay-as-you-go | GPT-4o, assistants, embeddings, vision |
| Vercel AI SDK v6 | T1 | Gratis | Unified interface multi-provider, streaming, tool use |
| LangChain.js | T2 | Gratis | Orchestrazione LLM, RAG pipeline |
| LlamaIndex | T2 | Gratis | RAG framework Python/JS |
| Groq | T2 | Gratis → pay-as-you-go | Inferenza velocissima (LPU), ottimo per prototype |
| Ollama | T2 | Gratis (self-hosted) | LLM locali, privati, no API cost |
| Google Gemini API | T2 | Gratis → pay-as-you-go | Gemini 1.5/2.0, multimodale |
| Mistral API | T3 | Pay-as-you-go | Modelli europei, GDPR-friendly |

---

## 15. INTEGRAZIONI / WEBHOOK

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Zapier | T2 | Gratis (100 task) → $20/mese | No-code automation, 6000+ app |
| Make (ex Integromat) | T2 | Gratis → $9/mese | Visual automation, più flessibile di Zapier |
| n8n | T2 | Gratis (self-hosted) | Open source, self-hostable, ottimo per team tech |
| Inngest | T1 | Gratis → $20/mese | Durable workflows in TypeScript, background jobs |
| Trigger.dev | T1 | Gratis → $20/mese | Background jobs, cron jobs, webhooks TypeScript |
| QStash (Upstash) | T2 | Gratis → $1/mese | Message queue serverless, ottimo per Vercel |

---

## 16. CUSTOMER SUPPORT

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Crisp | T2 | Gratis → €25/mese | Live chat + helpdesk, ottimo small business |
| Intercom | T3 | $39/mese | Enterprise support platform |
| Zendesk | T3 | $55/agente/mese | Enterprise ticketing |
| Tawk.to | T2 | Gratis | Live chat gratuito, pubblicità rimuovibile a pagamento |
| Plain | T2 | $12/mese | Moderno, developer-focused, API-first |

---

## 17. DOMINI / DNS

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Cloudflare (DNS + CDN) | T1 | Gratis | DNS veloce, DDoS protection, proxy, Analytics |
| Vercel Domains | T2 | €8-15/anno | Integrato con Vercel, SSL automatico |
| Namecheap | T2 | €8-15/anno | Registrar economico |
| GoDaddy | T3 | €10-20/anno | Diffuso, upselling aggressivo |

---

## 18. SICUREZZA AGGIUNTIVA

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Arcjet | T1 | Gratis → $25/mese | Rate limiting, bot detection, shield Next.js |
| Vercel BotID | T1 | Incluso in Vercel | Bot detection nativo Vercel |
| Cloudflare Turnstile | T1 | Gratis | CAPTCHA alternativo privacy-first (no fingerprinting) |
| hCaptcha | T2 | Gratis | CAPTCHA privacy-first |
| Upstash Rate Limiting | T1 | Gratis → pay-as-you-go | Rate limiting Redis-based per serverless |
| Snyk | T2 | Gratis → $25/mese | Vulnerability scanning dipendenze |

---

## 19. ANIMAZIONE E CREATIVITÀ

| Tecnologia | Tier | Costo | Note |
|------------|------|-------|------|
| Lottie / dotLottie | T2 | Gratis | Animazioni vettoriali da After Effects su web. `@lottiefiles/dotlottie-react` |
| Rive | T2 | Gratis → $30/mese | Animazioni state-machine interattive, superiore a Lottie per interattività |
| Spline | T2 | Gratis → $15/mese | Scene 3D no-code embedded con `@splinetool/react-spline`. Ottimo per hero veloci |
| Theatre.js | T3 | Gratis | Sequencer animazioni per scene complesse R3F. Curva ripida |
| p5.js | T2 | Gratis | Generative art, canvas 2D animato, background procedurali |
| Vanilla Extract | T2 | Gratis | CSS-in-TypeScript zero runtime, type-safe. Alternativa moderna a Styled Components |
| Open Props | T2 | Gratis | Sistema di CSS custom properties community-driven. Compatible con qualsiasi framework |
| Motion Canvas | T3 | Gratis | Animazioni programmatiche tipo Remotion per web. Niche ma potente |

**Quando usare Rive vs Lottie:**
- Lottie: animazioni one-shot (loader, icone, illustrazioni)
- Rive: animazioni con stato interattivo (hover, click, transizioni condizionali)

**Quando usare Spline vs Three.js/R3F:**
- Spline: prototipo rapido, designer può modificare senza codice
- R3F: controllo totale, performance ottimizzabile, integrazione React profonda
