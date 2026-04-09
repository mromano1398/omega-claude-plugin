# Template Documenti Omega

---

## Template: CLAUDE.md

```markdown
# [NOME PROGETTO] — CLAUDE.md

> Fonte di verità per Claude Code. Leggi questo file prima di qualsiasi azione.

## [OVERVIEW]
**Progetto:** [nome]
**Tipo:** [Gestionale / SaaS / E-commerce / Landing / Showcase / Mobile / CLI]
**Obiettivo:** [1-2 frasi sull'obiettivo]
**Utenti target:** [chi usa il progetto]
**Stato:** [In sviluppo / Beta / Produzione]

## [STACK TECNICO]
- **Framework:** Next.js 15 App Router (o specificare)
- **Database:** PostgreSQL con pg (o Supabase / Drizzle / Prisma)
- **Auth:** NextAuth v5 (o Supabase Auth / Clerk)
- **UI:** shadcn/ui + Tailwind CSS
- **Animazioni:** [Nessuna / Framer Motion / GSAP + Lenis / Three.js R3F]
- **Deploy:** Vercel
- **Email:** Resend
- **Storage:** [Vercel Blob / Cloudinary / S3]

## [DESIGN SYSTEM]
<!-- Aggiornato: [DATA] -->
- **Tier:** [1-4] — [FUNZIONALE / PROFESSIONALE / CINEMATIC / IMMERSIVO]
- **Primary:** #[hex] — [uso]
- **Secondary:** #[hex] — [uso]
- **Surface:** #[hex]
- **Border:** #[hex]
- **Font body:** [Inter / altro]
- **Font display:** [solo Tier 3-4]
- **Design system completo:** omega/design-system.md

## [STRUTTURA PROGETTO]
<!-- Aggiornato: [DATA] -->
```
src/app/
  (auth)/           → login, register
  (dashboard)/      → area protetta
    layout.tsx      → sidebar + header
    page.tsx        → dashboard home
    [modulo]/       → pagine per modulo
  api/              → route handlers
src/modules/
  [dominio]/
    types.ts        → TypeScript interfaces
    queries.ts      → query DB (solo lettura)
    actions.ts      → server actions (scrittura)
src/components/
  ui/               → shadcn components
  layout/           → Sidebar, Header
  [dominio]/        → componenti specifici
src/lib/
  db.ts             → connessione DB
  auth.ts           → configurazione auth
omega/              → documenti progetto
```

## [MODULI IMPLEMENTATI]
<!-- Aggiornato: [DATA] -->
- [ ] Auth (login, logout, session)
- [ ] [Modulo 1]
- [ ] [Modulo 2]

## [SCHEMA DB — TABELLE ESISTENTI]
<!-- Aggiornato: [DATA] -->
- users (id, email, name, role, created_at)
- [aggiungere tabelle man mano]

## [DIPENDENZE CHIAVE]
<!-- Non modificare senza aggiornare questo file -->
- next: 15.x
- react: 19.x
- [altre dipendenze rilevanti]

## [REGOLE OMEGA]
<!-- NON MODIFICARE QUESTA SEZIONE -->
1. Ogni query DB filtra per user_id o org_id (mai esporre dati altrui)
2. Zod su ogni input utente (form, API, query params)
3. Audit trail su ogni CREATE/UPDATE/DELETE
4. omega-build-checker dopo ogni 3 file modificati
5. Nessun commit senza build verde
6. MAI usare `any` TypeScript senza commento esplicativo
7. Server Actions per tutti i write — mai chiamate DB dirette dal client

## [PROSSIMI STEP]
<!-- Aggiornato: [DATA] -->
1. [step 1]
2. [step 2]
3. [step 3]
```

---

## Template: omega/MVP.md

```markdown
# MVP — [NOME PROGETTO]
**Versione:** 1.0
**Data:** [DATA]
**Obiettivo MVP:** Validare [ipotesi principale] con [utenti target] entro [timeframe].

## SCOPE MVP (cosa è INCLUSO)
- [ ] [Feature 1] — [perché è nel MVP]
- [ ] [Feature 2] — [perché è nel MVP]
- [ ] [Feature 3] — [perché è nel MVP]

## FUORI SCOPE MVP (cosa NON è incluso)
- [Feature X] — rimandato a v1.1 (non necessario per validazione)
- [Feature Y] — complessità non giustificata nel MVP
- [Feature Z] — dipende dal feedback utenti

## CRITERI DI SUCCESSO
- [Metrica 1]: [target]
- [Metrica 2]: [target]

## UTENTI TARGET MVP
**Primari:** [chi sono]
**Secondari:** [chi sono]
**Problema risolto:** [descrizione]

## ASSUNZIONI
- [Assunzione 1 da validare]
- [Assunzione 2 da validare]
```

---

## Template: omega/PRD.md

```markdown
# PRD — Product Requirements Document
**Progetto:** [NOME]
**Versione:** 1.0
**Data:** [DATA]
**Autore:** [nome]

## OVERVIEW
[2-3 paragrafi che descrivono il prodotto, il problema risolto, e il valore per l'utente]

## USER STORIES

### [Modulo 1]
- Come [ruolo], voglio [azione], così da [beneficio]
- Come [ruolo], voglio [azione], così da [beneficio]

### [Modulo 2]
- Come [ruolo], voglio [azione], così da [beneficio]

## SPECIFICHE FUNZIONALI

### [Feature 1]
**Descrizione:** [cosa fa]
**Input:** [cosa riceve]
**Output:** [cosa produce]
**Edge cases:** [casi limite]
**Accettazione:** [come si verifica che funziona]

## SPECIFICHE NON-FUNZIONALI
- **Performance:** [requisiti di velocità]
- **Sicurezza:** [requisiti di sicurezza]
- **Accessibilità:** [WCAG level]
- **Browser support:** [browser supportati]

## OPEN QUESTIONS
- [ ] [Domanda aperta 1]
- [ ] [Domanda aperta 2]
```

---

## Template: omega/design-system.md

### Per Tier 1 (FUNZIONALE):
```markdown
# Design System — [NOME PROGETTO]
**Tier:** 1 — FUNZIONALE
**Aggiornato:** [DATA]

## PALETTE
| Token | Valore | Uso |
|-------|--------|-----|
| primary | #2563eb | CTA, link attivi, elementi brand |
| secondary | #6b7280 | Testo secondario, icone |
| surface | #ffffff | Background card |
| bg | #f9fafb | Background pagina |
| border | #e5e7eb | Bordi card e input |
| danger | #dc2626 | Errori, elimina |
| warning | #d97706 | Avvisi |
| success | #16a34a | Successo, stati ok |

## TIPOGRAFIA
- **Font:** Inter (Google Fonts, caricato con next/font)
- **Body:** 14px (tabelle dense) / 16px (standard), weight 400
- **Heading:** weight 600-700, da 20px a 32px
- **Label/badge:** 12px, weight 500

## SPACING
- Base unit: 4px
- Card padding: p-4 o p-6
- Gap elementi: gap-4 o gap-6
- Container max-width: 1280px

## ANIMAZIONI
- NESSUNA — transition: none su elementi critici
- Eccezione: transition-colors duration-150 su hover bottoni

## COMPONENTI BASE
- Button: default / outline / ghost / destructive
- Input: con label + messaggio errore
- Card: header + content + footer
- Badge: semantico per stati
- DataTable: sortabile, paginata, con filtro
```

### Per Tier 2 (PROFESSIONALE):
```markdown
# Design System — [NOME PROGETTO]
**Tier:** 2 — PROFESSIONALE
**Aggiornato:** [DATA]

## PALETTE
[token semantici personalizzati]

## TIPOGRAFIA
- **Font:** Inter (next/font)
- **Body:** 16px, weight 400
- **Heading:** weight 600-700, fluid con clamp()

## ANIMAZIONI (Framer Motion)
- Transizioni pagina: AnimatePresence, opacity + y 8px, duration 0.2s
- Hover card: y -2px, spring stiffness 300
- Button tap: scale 0.97
- Toast: slide-in da destra

## COMPONENTI AGGIUNTIVI
- Skeleton, EmptyState, AnimatedCounter, HoverCard
```

### Per Tier 3 (CINEMATIC):
```markdown
# Design System — [NOME PROGETTO]
**Tier:** 3 — CINEMATIC
**Aggiornato:** [DATA]

## PALETTE (Dark Theme Default)
| Token | Valore | Uso |
|-------|--------|-----|
| bg | #0a0a0a | Background root |
| surface | #111111 | Background card |
| border | rgba(255,255,255,0.08) | Bordi |
| text-primary | #fafafa | Testo principale |
| text-secondary | #a1a1aa | Testo secondario |
| accent | #[hex] | Colore brand principale |

## TIPOGRAFIA
- **Font Display:** [Space Grotesk / Geist / altro] — SOLO per H1, H2
- **Font Body:** Inter
- **Hero H1:** clamp(48px, 8vw, 96px)
- **H2:** clamp(32px, 5vw, 56px)
- **Body:** 16-18px

## ANIMAZIONI (GSAP + Lenis)
- Smooth scroll: Lenis duration 1.2
- Entrance: fade-up (y 60→0, opacity 0→1, 0.8s power3.out)
- Scroll trigger: start "top 85%"
- Parallax: max 20% velocità scroll
- Hover: scale(1.02) + glow shadow
```

---

## Template: omega/roadmap.md

```markdown
# Roadmap — [NOME PROGETTO]
**Aggiornato:** [DATA]

## FASE 1 — Foundation [Settimana 1]
- [ ] Setup progetto (Next.js, DB, auth)
- [ ] Design system e componenti base
- [ ] Layout e navigazione
- [ ] Deploy su Vercel (staging)

## FASE 2 — Core Features [Settimana 2-3]
- [ ] [Modulo principale 1]
- [ ] [Modulo principale 2]
- [ ] [Modulo principale 3]

## FASE 3 — Polish & Launch [Settimana 4]
- [ ] Testing e bug fix
- [ ] Performance optimization
- [ ] Deploy produzione
- [ ] Documentazione utente

## BACKLOG (post-MVP)
- [Feature futura 1]
- [Feature futura 2]

## MILESTONE
- **Alpha:** [data] — Foundation completa
- **Beta:** [data] — Core features completate
- **v1.0:** [data] — Launch pubblico
```

---

## Template: omega/state.md

```markdown
# State — [NOME PROGETTO]
**last_updated:** [DATA]

## COMPLETATO
- [x] Setup progetto
- [x] [Modulo completato 1]

## IN CORSO
- [ ] [Modulo in sviluppo]

## PENDING
- [ ] [Cosa ancora da fare]

## RECENT CHANGES
- [DATA]: [Descrizione cambiamento]
- [DATA]: [Descrizione cambiamento]

## KNOWN ISSUES
- [Problema aperto] — [workaround se esiste]

## DIPENDENZE AGGIUNTE
- [pacchetto@versione] — [perché è stato aggiunto]
```

---

## Template: README.md

```markdown
# [NOME PROGETTO]

[Descrizione in 1-2 frasi — cosa fa il progetto]

## Stack
- Next.js 15 App Router
- PostgreSQL
- [altre tecnologie chiave]

## Setup locale

### Prerequisiti
- Node.js 20+
- PostgreSQL 15+
- [altri requisiti]

### Installazione
```bash
git clone [repo]
cd [nome-progetto]
npm install
cp .env.example .env.local
# Configura le variabili in .env.local
npm run db:migrate
npm run dev
```

## Variabili d'ambiente
| Variabile | Descrizione | Obbligatoria |
|-----------|-------------|--------------|
| DATABASE_URL | Connessione PostgreSQL | ✅ |
| NEXTAUTH_SECRET | Secret per NextAuth | ✅ |
| [altra variabile] | [descrizione] | ✅/❌ |

## Struttura cartelle
```
src/
  app/          → Next.js routes
  modules/      → Business logic per dominio
  components/   → Componenti React
  lib/          → Utilities
omega/          → Documenti progetto
```

## Sviluppo
```bash
npm run dev        # Server di sviluppo
npm run build      # Build produzione
npm run test       # Test
npm run lint       # Lint
```

## Deploy
Il progetto è deployato su Vercel. Ogni push su `main` triggera un deploy automatico.

## Documentazione
- `CLAUDE.md` — istruzioni per Claude Code
- `omega/MVP.md` — scope del progetto
- `omega/design-system.md` — sistema di design
- `omega/roadmap.md` — roadmap sviluppo
```
