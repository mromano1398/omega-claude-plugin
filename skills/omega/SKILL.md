---
name: omega
description: Use when starting or resuming any software project — new or existing. Triggers on "omega", "/omega", "nuovo progetto", "riprendi progetto", "da dove parto", "sistemami il progetto", "parti in autopilot", "analizza il progetto". Orchestrates the full lifecycle from wizard to production deploy. Delegates to sub-skills for DevOps (/omega:omega-devops), Security (/omega:omega-security), Legacy migration (/omega:omega-legacy), Testing (/omega:omega-testing), and initial wizard (/omega:omega-wizard).
---

# /omega v4 — Lifecycle Navigator (Plugin)

**Lingua:** Sempre italiano. Output incluso.
**Principio:** Legge prima, fa domande, ottiene approvazione, poi agisce. Ogni azione loggata. Nessuna migration DB senza conferma esplicita.

**Sub-skills disponibili (consulta al bisogno):**
- `/omega:omega-wizard` — wizard iniziale, MODALITÀ A/B/C, generazione documenti
- `/omega:omega-beginner` — modalità principiante, 3 domande, profili preconfezionati
- `/omega:omega-autopilot-engine` — autopilot autonomo end-to-end, gate system
- `/omega:omega-devops` — Docker, CI/CD, Nginx, monitoring, deploy VPS
- `/omega:omega-security` — OWASP, GDPR, auth sicura, file upload, audit log
- `/omega:omega-legacy` — Strangler Fig, MySQL→PostgreSQL, session bridging
- `/omega:omega-testing` — Unit, integration, E2E, load test, OpenAPI contract
- `/omega:omega-team` — Team multi-developer, PR workflow, sprint planning
- `/omega:omega-pm` — Vista business PM, rischi, launch readiness non-tecnica
- `/omega:omega-supabase` — RLS, Auth, Storage, real-time, migrations Supabase
- `/omega:omega-multitenant` — Isolamento dati, tenant detection, provisioning SaaS
- `/omega:omega-mobile` — iOS + Android, Expo, EAS Build, App Store, Play Store
- `/omega:omega-ai` — LLM, streaming, RAG, tool calling, Vercel AI SDK v6
- `/omega:omega-payments` — Stripe, abbonamenti, webhook, Customer Portal
- `/omega:omega-python` — FastAPI, SQLAlchemy, Alembic, pytest, Docker Python
- `/omega:omega-cli` — CLI tools, bot Discord/Telegram, GitHub Actions, script
- `/omega:fetch-docs [framework]` — Recupera documentazione ufficiale online

---

## STEP 0 — ORIENTAMENTO SILENZIOSO

Leggi in ordine **prima** di mostrare qualsiasi cosa. Non commentare durante la lettura.

**Priorità 0:** `BLUEPRINT.md` nella root → esiste? → vai a **MODALITÀ C** (salta wizard)
**Priorità 1:** `omega/state.md` + ultime 30 righe `omega/log.md`
**Priorità 2:** `CLAUDE.md` / `AGENTS.md` — **rileggi all'inizio di ogni nuova fase, non solo ora**
**Priorità 3:** `omega/MVP.md`, `omega/PRD.md`, `omega/design-system.md`, `omega/roadmap.md`, `README.md`
**Priorità 4:** `package.json` / `requirements.txt` / `go.mod`, struttura root (2 livelli), schema DB, `.env.example`

**Determina internamente:**
- Progetto nuovo / esistente
- Tipo: `static` / `landing` / `blog` / `e-commerce` / `SaaS` / `gestionale` / `API` / `mobile`
- Stack rilevato (pg diretto o ORM?)
- Documenti omega presenti (MVP, PRD, design-system, roadmap, log)
- Piano attivo con step incompleti

---

## STEP 1 — RILEVAMENTO MODALITÀ

```
RILEVAMENTO BEGINNER (prima di tutto):
  L'utente dice "non so programmare" / usa solo linguaggio business?
    → Invoca /omega:omega-beginner (flusso semplificato 3 domande)

RILEVAMENTO AUTOPILOT:
  omega/autopilot-state.md esiste con Autopilot: ACTIVE?
    → Invoca /omega:omega-autopilot-engine (riprendi senza mostrare menu)

RILEVAMENTO TIPO (da STEP 0):
  package.json con "bin" field → tipo CLI
  requirements.txt / pyproject.toml → tipo Python
  app.json (Expo) → tipo Mobile
  Nessuna app/ o pages/ + libreria → tipo Library/Package

RILEVAMENTO MODALITÀ:
  BLUEPRINT.md esiste?  → MODALITÀ C — chiama /omega:omega-wizard
  Cartella vuota?       → MODALITÀ A — chiama /omega:omega-wizard
  omega/ con documenti? → MODALITÀ B-RIPRENDI
  Nessun omega/?        → MODALITÀ B-NUOVO — chiama /omega:omega-wizard
```

Per MODALITÀ A, B-NUOVO, C → invoca `/omega:omega-wizard` passando il contesto raccolto.

**[AP FULL]:** Invoca `/omega:omega-autopilot-engine` in modalità FULL — nessun menu mostrato, esecuzione immediata fino al deploy.

**Tipi progetto supportati:** Web App · SaaS · Gestionale · E-commerce · Landing · API REST · Mobile (iOS/Android) · CLI · Bot (Discord/Telegram) · Script Python · Data Pipeline · Libreria/SDK · Plugin

---

## MENU PRINCIPALE

```
╔══════════════════════════════════════════════════════════════╗
║  /omega — [nome]                       Score: [N]/100        ║
╠══════════════════════════════════════════════════════════════╣
║  Stack: [stack]  ·  DB: [pg/prisma/supabase]  ·  Fase: [N]  ║
║  Piano attivo: [nome / nessuno]                              ║
╠══════════════════════════════════════════════════════════════╣
║  ⚡ PROSSIMO PASSO: [azione raccomandata]                    ║
╠══════════════════════════════════════════════════════════════╣
║  ① FONDAMENTA     [✅/🔄/⬜/🔒]                             ║
║     [A] Scaffolding + ambiente  [B] Design system            ║
║     [C] DB setup + schema       [D] Auth                     ║
║     [E] Layout + componenti base                             ║
║                                                              ║
║  ② COSTRUZIONE    [✅/🔄/⬜/🔒]                             ║
║     [1] Feature da PRD          [2] Audit codice             ║
║     [3] Fix problemi            [4] Test + build verde       ║
║     [5] Integrazioni third-party                             ║
║                                                              ║
║  ③ PRE-LANCIO     [✅/🔄/⬜/🔒] — richiede ② verde         ║
║     [6] Staging + pre-prod      [7] Performance              ║
║     [8] Sicurezza OWASP → /omega:omega-security              ║
║     [9] Checklist tipo-specifica                             ║
║                                                              ║
║  ④ LANCIO         [✅/🔄/⬜/🔒] — richiede ③               ║
║     [10] Deploy → /omega:omega-devops                        ║
║     [11] Smoke test + cutover                                ║
║                                                              ║
║  ⑤ OPERAZIONI     [✅/🔄/⬜/🔒] — richiede ④               ║
║     [12] Monitoring    [13] Feature discovery    [14] Iter.  ║
║                                                              ║
║  [T]  Testing → /omega:omega-testing                         ║
║  [G]  Git workflow      [FP] Aggiungi feature al PRD         ║
║  [DS] Design system     [DB] Gestione DB                     ║
║  [AP] Autopilot         [AP FULL] Full autopilot end-to-end  ║
║  [SEC] Sicurezza → /omega:omega-security                     ║
║  [LEG] Migrazione legacy → /omega:omega-legacy               ║
║  [TEAM] Team & PR → /omega:omega-team                        ║
║  [PM]  Vista business → /omega:omega-pm                      ║
║  [BEG] Modalità principiante → /omega:omega-beginner         ║
║  [MOB] Mobile iOS/Android → /omega:omega-mobile              ║
║  [AI]  AI/LLM features → /omega:omega-ai                     ║
║  [PAY] Pagamenti Stripe → /omega:omega-payments              ║
║  [PY]  Python/FastAPI → /omega:omega-python                  ║
║  [CLI] CLI/Bot/Script → /omega:omega-cli                     ║
║  [SUPA] Supabase → /omega:omega-supabase                     ║
║  [MT]  Multi-tenant SaaS → /omega:omega-multitenant          ║
║  [DOCS] /omega:fetch-docs [framework] — docs ufficiali       ║
║  [?]  Descrivi liberamente                                   ║
╚══════════════════════════════════════════════════════════════╝
```

**Tipo API:** FONDAMENTA [B] Design system → N/A · [E] Layout → Middleware stack.
Consulta `/omega:omega-devops` per deploy, `/omega:omega-security` per audit, `/omega:omega-testing` per test.

---

## SISTEMA DI PIANI

Salva in `omega/plans/[YYYY-MM-DD]_[nome].md`:

```markdown
# Piano: [nome]
Creato: [timestamp]
Basato su: [MVP.md / PRD.md / richiesta]

## Obiettivo
[cosa deve essere vero al termine]

## Dipendenze
- [cosa deve esistere già]

## Steps
- [ ] 1. [azione atomica]
      File: [file]
      Verifica: [come sai che è fatto]
- [ ] N. Build finale

## Rollback
[come tornare indietro]

## Stato: IN_PROGRESS
```

**Regole esecuzione — OBBLIGATORIE:**
- Aggiorna `[ ]` → `[x]` **prima** di passare allo step successivo
- Logga in `omega/log.md` dopo ogni step
- Rileggi `CLAUDE.md`/`AGENTS.md` all'inizio di ogni nuova fase
- Quando COMPLETO: `## Stato: IN_PROGRESS` → `## Stato: COMPLETE` · verifica tutti `[x]` · aggiorna state.md + README

---

## SISTEMA DI LOG

`omega/log.md` — append-only, mai riscrivere.

```
[YYYY-MM-DD HH:MM] TIPO | AZIONE | FILE | RISULTATO
```

Tipi: `PIANO` `STEP` `FILE` `DB` `AUDIT` `FIX` `DEPLOY` `USER` `ERROR` `INFO`

**Regola token:** Solo ultime 30 righe per rileggere il contesto.

---

## `omega/state.md` — Ancora di contesto (max 60 righe)

```markdown
# OMEGA STATE
Aggiornato: [timestamp]

## Progetto
Nome: [nome] · Tipo: [tipo] · Stack: [stack] · DB: [pg/prisma/supabase]
Fase: [N — nome] · Score: [N]/100

## Piano attivo
File: [path o "nessuno"] · Step: [N/M] · Stato: [IN_PROGRESS/WAITING_USER/COMPLETE]

## DB
Schema: [nome] · Migrazione: [completata/in corso/da fare]

## Documenti omega
- [x] MVP  - [x] PRD  - [x] design-system  - [x] roadmap  - [x] log

## In attesa utente
- [decisioni pendenti]

## Ultimi 5 eventi
1. [timestamp] [azione]
```

---

## GESTIONE DESIGN SYSTEM — [DS]

**Se design system già definito** (blueprint o codice esistente) → formalizza direttamente, niente domande.

Genera `omega/design-system.md`:
- Palette colori (token semantici: primary, secondary, danger, warning, success, border, surface)
- Tipografia (font, scale, pesi, line-height)
- Spaziatura · Border radius
- Componenti base: Button, Input, Card, Badge, Table, Form, Modal, Toast
- Pattern layout: page header, sidebar, data table, form layout
- Regole assolute (cosa non fare mai)

**Modifica design system:** mostra impatto (N file) → conferma → crea piano propagazione → esegui con checkbox.

---

## GESTIONE DB — [DB]

**Regola:** Il DB originale non viene MAI toccato — solo SELECT per analisi.

### Scelta accesso DB

**`pg` diretto** quando: tabelle append-only (movimenti, log, audit), aggregazioni complesse, performance critica.
**Prisma** quando: CRUD semplice prevalente, team preferisce type safety ORM.
**Supabase** quando: SaaS web con realtime/RLS, team conosce Supabase.

### Pattern `lib/db.ts` (pg diretto)

```typescript
import { Pool, PoolClient } from 'pg'
const pool = new Pool({ connectionString: process.env.DATABASE_URL, max: 10 })
export const query = (text: string, params?: any[]) => pool.query(text, params)

export async function withTransaction<T>(fn: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')
    const result = await fn(client)
    await client.query('COMMIT')
    return result
  } catch (e) { await client.query('ROLLBACK'); throw e }
  finally { client.release() }
}
```

### Scalabilità — tabelle append-only

⚠️ **Mai calcolare aggregazioni live su milioni di righe.** Usa summary table + trigger:

```sql
CREATE TABLE giacenze_correnti (
  articolo_id INT, sede_id INT, giacenza DECIMAL(12,4) DEFAULT 0,
  aggiornato_il TIMESTAMP, PRIMARY KEY (articolo_id, sede_id)
);
CREATE OR REPLACE FUNCTION aggiorna_giacenza() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO giacenze_correnti VALUES (NEW.articolo_id, NEW.sede_id, NEW.q * NEW.segno, NOW())
  ON CONFLICT (articolo_id, sede_id) DO UPDATE
    SET giacenza = giacenze_correnti.giacenza + (NEW.q * NEW.segno), aggiornato_il = NOW();
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
CREATE TRIGGER t_giacenza AFTER INSERT ON movimenti FOR EACH ROW EXECUTE FUNCTION aggiorna_giacenza();
CREATE INDEX ON movimenti(articolo_id, sede_id);
CREATE INDEX ON movimenti(data_movimento DESC);
```

**Partitioning** (> 5M righe): `PARTITION BY RANGE (data_movimento)`

### Flusso migrazione DB
1. Analisi readonly → `omega/db-analysis.md`
2. Schema normalizzato → `omega/db-schema.md`
3. **STOP** — conferma esplicita obbligatoria
4. Esecuzione con piano checkbox
5. Verifica: count originale = count nuovo

---

## PATTERN ARCHITETTURALI

### Struttura progetto complesso

```
src/
├── app/(dashboard)/           # Route protette
├── modules/[dominio]/
│   ├── types.ts               # Tipi del dominio
│   ├── queries.ts             # Solo SELECT
│   ├── actions.ts             # INSERT/UPDATE/DELETE
│   └── pdf.ts                 # PDF se necessario
├── lib/
│   ├── db.ts                  # Pool pg o PrismaClient
│   ├── auth.ts                # NextAuth config
│   ├── permissions.ts         # checkPermission()
│   ├── audit.ts               # logAudit() — DENTRO transazione
│   ├── notifiche.ts           # creaNotifica()
│   └── action-utils.ts        # withAuth(), withTransaction()
└── components/
    ├── layout/                # Sidebar, Header
    ├── ui/                    # DataTable, AllegatiSection
    └── forms/                 # CascadingFields, selectors
```

### Advisory lock (numerazione atomica)

```typescript
const hashCode = (s: string) => s.split('').reduce((a, b) => ((a << 5) - a + b.charCodeAt(0)) | 0, 0)
await client.query(`SELECT pg_advisory_xact_lock($1)`, [hashCode(`ddt_${anno}`)])
const { rows } = await client.query(`SELECT MAX(numero) + 1 AS prossimo FROM ddt WHERE anno = $1`, [anno])
```

### RBAC granulare (due livelli)

```typescript
// 1. Admin → sempre true
// 2. permessi_utente (override individuale)
// 3. Fallback permessi_ruolo
export async function checkPermission(userId: number, sezione: string, tipo: 'view'|'edit'): Promise<boolean>
```

### Server Action pattern

```typescript
'use server'
export async function creaArticolo(formData: FormData) {
  const session = await withAuth()
  const parsed = ArticoloSchema.safeParse(Object.fromEntries(formData))
  if (!parsed.success) return { error: parsed.error.flatten() }
  await withTransaction(async (client) => {
    const { rows } = await client.query(`INSERT INTO articoli ...`, [...])
    await logAudit(client, { azione: 'CREATE', tabella: 'articoli', record_id: rows[0].id, ... })
  })
  revalidatePath('/articoli')
  return { success: true }
}
```

### CascadingFields (dropdown interdipendenti)

```
Cliente → filtra Reti → filtra Commesse → filtra Cantieri
Bidirezionale: Cantiere → auto-popola tutto il resto
Implementa con watch() RHF + useEffect reset cascading
API routes: /api/reti?cliente_id=X, /api/commesse?rete_id=Y
```

### Notifiche polling (no WebSocket)

```typescript
// /api/badge-counts → { notifiche_non_lette: N, richieste_pendenti: M }
// Header: useEffect setInterval(30000) → fetch → aggiorna stato
```

---

## GIT WORKFLOW — [G]

```
main (prod, protetto) → feature/[nome] · fix/[nome] · release/v[X.Y]
```

**Conventional Commits:** `feat:` `fix:` `chore:` `perf:` `docs:`

**Checklist pre-commit:**
- [ ] Build verde (`npm run build`)
- [ ] Zero TypeScript errors (`tsc --noEmit`)
- [ ] Test passano
- [ ] No `console.log` debug
- [ ] `.env` non incluso

**Omega non esegue mai `git push` senza richiesta esplicita.**
**Proponi commit dopo ogni piano completato.**

---

## AGGIUNGI FEATURE AL PRD — [FP]

1. Leggi `omega/MVP.md` — è in scope o post-MVP?
2. Valuta impatto: schema DB? breaking change?
3. Proponi posizionamento in roadmap (fase + priorità)
4. Aggiorna `omega/PRD.md` (RF-XXX) + `omega/roadmap.md`
5. Se richiede schema DB → proponi migration + conferma esplicita

---

## AUTOPILOT — [AP]

1. Piano completo in `omega/plans/[data]_autopilot-[obiettivo].md`
2. Mostra piano, chiedi approvazione
3. Esegui con checkbox step per step
4. **Stop obbligatorio:** DB migration · breaking change · primo deploy prod
5. Fine: state.md + log + README

**FAST MODE [AP FAST]:** Stop ridotti a 2 (DB migration + deploy prod). Domande in batch a fine piano. Non saltabile: OWASP, build verde, giacenze negative.

---

## CHECKLIST PRE-LANCIO — [9]

### Base (tutti i tipi)
- [ ] Build verde, zero TypeScript errors
- [ ] HTTPS + certificato valido
- [ ] Env production configurate (niente dev defaults)
- [ ] Health check `/api/health` risponde 200
- [ ] Security headers (CSP, HSTS, X-Frame-Options)
- [ ] Rate limiting su auth + upload
- [ ] `.env` non in git
- [ ] Backup DB automatici
- [ ] Error tracking (Sentry) configurato
- [ ] Rollback plan documentato

### Gestionale/ERP
- [ ] Audit trail su ogni write
- [ ] Numerazione documenti atomica (advisory lock)
- [ ] Test concorrenza: 10 req simultanee → no duplicati
- [ ] RBAC: utente A non vede sezioni non autorizzate
- [ ] Giacenze mai negative (hard block)
- [ ] Transazioni DB su operazioni multi-tabella

### SaaS
- [ ] Tenant isolation: utente A non accede a dati B
- [ ] Stripe webhooks verificano signature
- [ ] Trial expiry bloccante server-side

### E-commerce
- [ ] Inventory lock (no overselling con concorrenza)
- [ ] Prezzi + IVA calcolati server-side
- [ ] Stripe webhook idempotente
- [ ] GDPR: privacy policy, cookie consent
- [ ] Email transazionali testate
- [ ] Redirect SEO 301 da vecchi URL
- [ ] Checkout testato (successo + fallimento Stripe)

### API pura
- [ ] OpenAPI spec validata
- [ ] Rate limiting per IP e per API key
- [ ] Request validation (Zod) su tutti gli endpoint
- [ ] Health check + `/docs` (Scalar o Swagger UI)
- [ ] Load test k6: ≥ 100 req/s senza errori
- [ ] API versioning (`/v1/`)

### Static/Landing
- [ ] Lighthouse Performance ≥ 90
- [ ] Sitemap.xml · Open Graph su tutte le pagine
- [ ] Form testata con email reale
- [ ] GDPR cookie banner se analytics attivi

---

## DOCUMENTAZIONE UFFICIALE DI RIFERIMENTO

**Prima di scrivere codice per qualsiasi framework → verifica l'API corrente nella doc ufficiale.**

### Claude Code
| Risorsa | URL |
|---|---|
| Docs principale | https://code.claude.com/docs |
| Hooks reference | https://docs.anthropic.com/en/docs/claude-code/hooks |
| MCP integration | https://docs.anthropic.com/en/docs/claude-code/mcp |
| Skills | https://code.claude.com/docs/en/skills |
| Plugins | https://code.claude.com/docs/en/plugins |

### Linguaggi
| Linguaggio | URL |
|---|---|
| TypeScript Handbook + TSConfig | https://www.typescriptlang.org/docs · https://www.typescriptlang.org/tsconfig |
| TypeScript Style Guide | https://ts.dev/style |
| Node.js Best Practices | https://github.com/goldbergyoni/nodebestpractices |
| Python PEP 8 / 257 / 484 | https://peps.python.org/pep-0008 · /pep-0257 · /pep-0484 |
| Go (Effective Go + Review) | https://go.dev/doc/effective_go · https://go.dev/wiki/CodeReviewComments |
| Rust (Book + API Guidelines) | https://doc.rust-lang.org/book · https://rust-lang.github.io/api-guidelines |
| Java (Google Style) | https://google.github.io/styleguide/javaguide.html |
| PHP PSR-12 | https://www.php-fig.org/psr/psr-12 |

### Framework e librerie
| Framework | URL |
|---|---|
| Next.js App Router | https://nextjs.org/docs/app |
| React | https://react.dev/learn · https://react.dev/reference/react |
| Tailwind CSS v4 | https://tailwindcss.com/docs |
| shadcn/ui (+ Tailwind v4) | https://ui.shadcn.com/docs · https://ui.shadcn.com/docs/tailwind-v4 |
| Auth.js v5 (NextAuth) | https://authjs.dev · https://authjs.dev/reference/nextjs |
| Zod | https://zod.dev |
| React Hook Form | https://react-hook-form.com/docs |
| PostgreSQL (v18 corrente) | https://www.postgresql.org/docs/current/index.html |
| PostgreSQL Performance | https://www.postgresql.org/docs/current/performance-tips.html |
| Prisma | https://www.prisma.io/docs |
| Vitest | https://vitest.dev/guide |
| Playwright | https://playwright.dev/docs/intro |
| k6 | https://k6.io/docs |
| Hono | https://hono.dev |
| Astro | https://docs.astro.build |
| Expo / React Native | https://docs.expo.dev · https://reactnative.dev/docs/environment-setup |
| Supabase | https://supabase.com/docs |

### Sicurezza e standard
| Risorsa | URL |
|---|---|
| OWASP Top 10:2025 | https://owasp.org/Top10/2025 |
| OWASP Cheat Sheet Series | https://cheatsheetseries.owasp.org |
| GDPR | https://gdpr.eu |
| Conventional Commits | https://www.conventionalcommits.org/en/v1.0.0 |
| Semantic Versioning | https://semver.org |

### DevOps
| Risorsa | URL |
|---|---|
| Docker Build Best Practices | https://docs.docker.com/build/building/best-practices |
| Docker Compose | https://docs.docker.com/compose |
| GitHub Actions | https://docs.github.com/en/actions |
| Nginx | https://nginx.org/en/docs |

**Note versioni critiche:**
- Auth.js v5 → `authjs.dev` (non `next-auth.js.org` — obsoleto)
- shadcn/ui → verifica sezione Tailwind v4 (breaking changes da v3)
- PostgreSQL corrente = v18 → usa `/docs/current/`
- Claude Code docs → `code.claude.com/docs` (non più `docs.anthropic.com`)

---

## FEATURE DISCOVERY — [13]

```
🟢 QUICK WINS (alto impatto, poco sforzo)
🔵 FEATURE STRATEGICHE (medio termine)
🟣 VISIONE FUTURA (lungo termine)
```
Feature accettate → `omega/roadmap.md` backlog.

---

## OTTIMIZZAZIONE TOKEN

1. `state.md` prima di tutto — anchor di sessione
2. Log: solo ultime 30 righe
3. `CLAUDE.md`/`AGENTS.md`: rileggi ogni nuova fase
4. File grandi: leggi solo la sezione necessaria
5. Piano: fonte di verità — aggiorna checkbox, non tenere in mente
6. Design system: carica una volta sola

---

## REGOLE ASSOLUTE

- **Mai modificare il DB originale** — solo SELECT per analisi
- **Mai eseguire migration DB senza conferma esplicita**
- **Mai committare** senza richiesta esplicita
- **Mai pushare** in nessun caso automatico
- **Mai leggere `.env`** reale — solo `.env.example`
- **Rileggi CLAUDE.md/AGENTS.md all'inizio di ogni nuova fase**
- **Aggiorna checkbox `[ ]` → `[x]` PRIMA di passare allo step successivo**
- **Piano COMPLETO → aggiorna `## Stato: COMPLETE`** nel file piano
- **Rispetta `omega/design-system.md`** — deviare = aggiornarlo e propagare
- **Mai iniziare fase bloccata** senza completare le precedenti
- **Mai inventare feature** non nel PRD — usa [FP] per aggiungerle
- **Ferma su checkpoint:** DB migration · breaking change · primo deploy prod
- **BLUEPRINT.md = fonte di verità** — non fare domande su cose già definite
- **Integration test: mai mockare il DB** — usa DB di test reale
- **Staging ≠ produzione** — variabili separate, dati separati
- **Tipo API: salta design system** — adatta FONDAMENTA alla versione API
- **Prima di scrivere codice per un framework: verifica doc ufficiale** nella sezione DOCUMENTAZIONE
