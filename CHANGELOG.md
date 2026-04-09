# Changelog

Tutte le modifiche notevoli a questo progetto sono documentate in questo file.

Il formato segue [Keep a Changelog](https://keepachangelog.com/it/1.0.0/).

---

## [4.2.1] — 2026-04-09 (bug fixes post-audit)

### Corretti
- **CRITICO** `omega-product-strategy`: riferimento a `references/feature-libraries.md` inesistente → corretto in `references/question-trees.md` (le feature sono già lì per tipo)
- **CRITICO** `omega-wizard` MODALITÀ C (BLUEPRINT): non generava `omega/STRATEGY.md` → aggiunto come primo documento; le sezioni assenti nel blueprint vengono marcate "[da definire]" invece di essere inventate
- **CRITICO** `omega-wizard` Step 3 trigger automatici: i trigger multi-tenant e pagamenti dicevano "se l'utente menziona" ma product-strategy (Step 1.5) era già stato eseguito → corretti per riferirsi all'output di product-strategy
- **CRITICO** `omega-autopilot-engine` MAPPA DI DECISIONE: nessuna azione se `omega/STRATEGY.md` mancante → aggiunto "chiama omega-product-strategy" come primo check dopo `nessun omega/`
- **IMPORTANTE** `omega-autopilot-engine`: FAST MODE [AP FAST] era documentato in omega/SKILL.md ma non in autopilot-engine → aggiunta tabella comparativa BASE/FULL/FAST con comportamento specifico di FAST (batch domande, solo 2 gate bloccanti)
- **IMPORTANTE** `omega-beginner`: NON chiamava omega-product-strategy (corretto — troppo tecnico), ma non generava nemmeno STRATEGY.md → aggiunta sezione "STRATEGY.md semplificato" dalle 3 domande beginner
- **IMPORTANTE** `omega-beginner` profili A-F: nessun mapping ai blueprint → aggiunte istruzioni esplicite per ogni profilo (`landing`, `gestionale`, `e-commerce`, `mobile`)
- **MINORE** `omega/SKILL.md` state.md schema: STRATEGY.md non incluso nella checklist documenti → aggiunto
- **MINORE** `omega/SKILL.md` STEP 0: lista documenti omega includeva solo MVP/PRD/design-system/roadmap/log → aggiunto STRATEGY
- **MINORE** `omega/SKILL.md` sezione [E]: step componenti UI presentato come universale → aggiunto guard "solo per React/Next.js"

---

## [4.2.0] — 2026-04-09

### Aggiunto
- `omega-product-strategy` — nuovo skill core: business canvas adattivo per ogni tipo di progetto. Domande specifiche per tipo (SaaS/e-commerce/mobile/landing/gestionale/API/CLI/Python), ricerca competitor strutturata, suggerimento feature proattivo, metriche North Star, piano crescita. Genera `omega/STRATEGY.md`. Shortcut `[PS]`
- `references/question-trees.md` — alberi di domande per 8 tipi di progetto con feature suggestions specifiche e North Star consigliata per tipo
- `references/growth-patterns.md` — pattern di crescita completi: AARRR benchmarks per tipo, K-factor formula, email sequences obbligatorie, viral loops, CRO patterns, ASO, Product Hunt checklist, event tracking minimo, UTM strategy
- `references/competitor-research.md` — framework competitor analysis: metodo rapido 5 minuti, ricerca approfondita, template analisi, matrice posizionamento, competitive advantage framework, positioning statement template

### Modificato
- `omega-wizard`: aggiunto Step 1.5 (Business Canvas) — chiama `omega-product-strategy` dopo aver rilevato il tipo, prima dello stack. Le domande di business sono ora in product-strategy, il wizard gestisce solo domande tecniche (max 3 per DEV, max 1 per BEGINNER)
- `omega-wizard` Step 4 (Proposta): aggiunta sezione STRATEGIA con target, North Star, vantaggio competitivo, scope MVP
- `omega-wizard` Step 5: `omega/STRATEGY.md` elencato come primo documento (già generato da product-strategy)
- `omega/SKILL.md` Percorso A: aggiunto Step 1.5 omega-product-strategy nel flow
- `omega/SKILL.md` Menu: aggiunto `[PS]` shortcut per Business Canvas
- `omega/SKILL.md` sub-skills: aggiunto `omega-product-strategy`
- `omega-doc-generator`: `omega/STRATEGY.md` come input per MVP.md e PRD.md — feature selezionate in strategy diventano RF- nel PRD
- `plugin.json`: versione 4.2.0, 26 sub-skills

---

## [4.1.0] — 2026-04-09

### Aggiunto
- `omega-stack-advisor` — nuovo skill con catalogo completo di 19 categorie di tecnologie, raccomandazioni per tipo progetto, verifica compatibilità stack. Shortcut `[STACK]`
- Pattern avanzati Tier 3: scroll-driven animations CSS native, text splitting, page transitions Next.js, magnetic cursor
- Pattern avanzati Tier 4: GLSL shaderMaterial R3F, React Spring+R3F, video texture, performance mobile con reduce-motion
- `omega-stitch` Opzione 5: import Figma Token Export (W3C Design Tokens JSON)
- `omega-stitch` Opzione 6: import CSS custom properties dirette
- `omega-multitenant`: pattern avanzati B2B — migration zero-downtime, rate limiting per tenant, error correlation, SSO/SAML
- `omega-legacy`: 7 patologie comuni migrazione MySQL→PostgreSQL con SQL esatto e checklist pre-cutover
- `omega-team`: sincronizzazione migration parallele Prisma in team
- `omega-build-checker`: modalità baseline per progetti con errori TS pre-esistenti, check bundle size, axe-core accessibility, npm audit, Lighthouse CI
- Catalogo tool creativi (categoria 19): Lottie, Rive, Spline, Theatre.js, Vanilla Extract, Open Props
- Gate 5 e Gate 6 nell'autopilot: breaking change API pubblica e migration distruttiva su staging
- `omega-reskin`: caso speciale Tier 4 con avviso architetturale obbligatorio
- Trigger automatico omega-multitenant quando tipo = SaaS B2B
- Rilevamento pattern legacy nel Percorso B (MySQL, PHP, pages router, jQuery)
- Mapping biunivoco Percorsi A/B/C/D ↔ omega-wizard documentato in entrambi i file
- Schema `omega/autopilot-state.md` documentato in omega-autopilot-engine
- Hook `Stop` per auto-save timestamp sessione
- Hook `PostToolUse` esteso a `Write|Edit|Bash`

### Corretto
- Package Lenis: `@studio-freight/lenis` → `lenis` (deprecato)
- Rimosso riferimento a `AGENTS.md` in omega/SKILL.md (file mai generato)
- omega-security scollegato da omega-audit-ui: audit OWASP ora sempre obbligatorio
- Conteggio sub-skills allineato a 25 in README, plugin.json, FAQ (fetch-docs è un comando, non uno skill)
- Disambiguazione domande BEGINNER: wizard (max 2) vs omega-beginner (3 domande dedicate)
- omega-wizard Step 5: aggiunta chiamata omega-blueprints prima di omega-doc-generator
- Precedenza doc-generator vs context-updater su CLAUDE.md definita esplicitamente
- Regex hook SessionStart: `\d` → `\d+` per supportare fasi a due cifre
- Incoerenza Prisma/RLS in SaaS B2B: aggiunta nota su bypass RLS e alternativa pg diretto
- omega-security disaccoppiata da audit-ui (dipendenza illogica rimossa)

---

## [4.0.0] — 2026-04-09

### Aggiunto
- Architettura **progressive disclosure**: tutti i 13 skill esistenti ristrutturati con SKILL.md compatto + cartella `references/` per contenuto dettagliato
- 8 nuovi skill: `omega-tier-system`, `omega-blueprints`, `omega-reskin`, `omega-build-checker`, `omega-audit-ui`, `omega-context-updater`, `omega-doc-generator`, `omega-stitch`
- 4 percorsi adattivi: NUOVO / ESISTENTE / RIPRENDI / RESKIN
- Sistema di tier design (T1 Funzionale → T4 Immersivo) con configurazione completa per ogni tier
- 7 blueprint per tipo progetto: Gestionale, SaaS, E-commerce, Landing, Showcase, Mobile, CLI/Bot
- omega-reskin: cambio design senza toccare la logica, flusso chirurgico
- omega-build-checker: verifica automatica ogni 3 file + file critici
- omega-audit-ui: rilevamento AI-slop in 6 aree (font, colori, layout, contenuti, componenti, animazioni)
- omega-context-updater: aggiornamento progressivo CLAUDE.md dopo ogni piano completato
- omega-doc-generator: generazione/rigenerazione documenti omega/ con approvazione
- omega-stitch: import design esterno da 4 fonti (DESIGN.md, URL/screenshot, testuale, MCP Stitch)
- Sicurezza Fase 1 automatica (non opt-in): headers, HTTPS, .env gitignore, rate limiting, Zod, IDOR
- Automazioni obbligatorie: build-checker ogni 3 file, audit-ui fine Fase 2, context-updater dopo ogni piano
- 5 file references in omega/: performance.md, accessibility.md, seo.md, api-patterns.md, security-defaults.md
- Hook SessionStart: autopilot detection + DESIGN.md detection
- Profilo F (Portfolio/Showcase) in omega-beginner

### Modificato
- omega-wizard riscritto con flusso adattivo a 3 percorsi e max 4 domande (prima 8)
- omega-beginner riscritto con 6 profili preconfezionati e tier semplificato (SEMPLICE/BELLO/WOW/3D)
- omega-autopilot-engine riscritto con integrazione build-checker, audit-ui, context-updater
- Menu principale espanso con shortcuts: [RESKIN], [AUDIT-UI], [CHECK], [PERF], [SEO], [A11Y]
- plugin.json aggiornato a v4.0.0 con 25 skills descritti

---

## [3.1.0] — precedente

### Corretto
- Rimosso riferimento a AGENTS.md mai generato (nota: il riferimento era rimasto in omega/SKILL.md — risolto definitivamente in v4.1.0)
- Vari fix di coerenza tra skill

---

## [3.0.0] — precedente

### Aggiunto
- Prima release pubblica del plugin omega
- Skill principali: omega, omega-wizard, omega-autopilot-engine, omega-devops, omega-security, omega-testing, omega-legacy, omega-team, omega-pm, omega-supabase, omega-multitenant, omega-mobile, omega-ai, omega-payments, omega-python, omega-cli
- Sistema di log (omega/log.md) e stato (omega/state.md)
- Hook SessionStart per caricamento contesto automatico
- Supporto per 10+ tipi di progetto
