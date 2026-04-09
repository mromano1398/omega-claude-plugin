# omega

> **Universal lifecycle navigator for Claude Code** — from idea to production, for any project type, for everyone.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-orange?logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code/overview)
[![Version](https://img.shields.io/badge/version-4.2.1-blue)](https://github.com/mromano1398/omega-claude-plugin/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Skills](https://img.shields.io/badge/sub--skills-26-purple)](skills/)
[![Language](https://img.shields.io/badge/language-Italiano-red)](README.md)
[![CI](https://github.com/mromano1398/omega-claude-plugin/actions/workflows/validate.yml/badge.svg)](https://github.com/mromano1398/omega-claude-plugin/actions/workflows/validate.yml)

---

**omega** è un plugin per [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) che ti guida dall'idea al prodotto finale in produzione — non solo come tool tecnico, ma come co-fondatore digitale. Analizza gli obiettivi di business, studia i competitor, suggerisce feature proattivamente, poi costruisce.

**Funziona per:** sviluppatori esperti, principianti assoluti, team, project manager.  
**Costruisce:** web app, SaaS, gestionali, e-commerce, app mobile iOS/Android, API, CLI, bot, script Python, progetti AI.  
**4 tier di design:** da interfacce funzionali a esperienze 3D immersive.  
**Business strategy inclusa:** competitor research, North Star metric, viral loops, CRO, growth patterns per tipo.  
**Lingua:** sempre italiano.

---

## Requisiti

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) — versione con supporto plugin (`--plugin-dir`)
- Nessun altro requisito — omega è puro testo (Markdown + JSON)

---

## Installazione

### Installazione rapida (Mac/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/mromano1398/omega-claude-plugin/main/install.sh | bash
```

### Installazione rapida (Windows PowerShell)

```powershell
irm https://raw.githubusercontent.com/mromano1398/omega-claude-plugin/main/install.ps1 | iex
```

---

### Metodo 1 — Sessione singola (prova rapida)

```bash
git clone https://github.com/mromano1398/omega-claude-plugin.git
claude --plugin-dir ./omega-claude-plugin
```

### Metodo 2 — Permanente (consigliato)

Clona il repository ovunque vuoi, poi aggiungi il percorso in `settings.json` di Claude Code:

**Mac/Linux:** `~/.claude/settings.json`  
**Windows:** `C:\Users\<nome>\.claude\settings.json`

```json
{
  "pluginDirs": [
    "/percorso/assoluto/dove/hai/clonato/omega"
  ]
}
```

Riavvia Claude Code — il plugin è attivo in tutte le sessioni.

### Metodo 3 — Directory plugins globale

```bash
git clone https://github.com/mromano1398/omega-claude-plugin.git ~/.claude/plugins/omega
```

### Verifica installazione

In qualsiasi sessione Claude Code, scrivi:

```
/omega:omega
```

Se vedi il menu con il pannello di stato, il plugin è installato correttamente.

---

## Come si usa

### Avvio base

Scrivi una qualsiasi di queste frasi — omega capisce da solo:

```
/omega:omega
omega
nuovo progetto
da dove parto
riprendi il progetto
```

### Per principianti (nessuna esperienza di programmazione)

Descrivi cosa vuoi in parole semplici:

```
"Voglio un sito per la mia pizzeria"
"Ho bisogno di un'app per gestire i miei dipendenti"
"Voglio vendere le mie ceramiche online"
```

omega rileva automaticamente che non sei uno sviluppatore, attiva la modalità principiante e ti fa solo 3 domande. Zero jargon tecnico — vedi solo i progressi in linguaggio business.

### Full Autopilot — dal documento al deploy

Con i documenti del progetto già presenti, scrivi:

```
[AP FULL]
```

omega legge tutto, crea il piano completo e implementa autonomamente — si ferma **solo** per 6 decisioni obbligatorie:
1. Deploy in produzione
2. Migration su dati reali
3. Costi monetari
4. Requisiti ambigui
5. Breaking change su API pubblica
6. Migration distruttiva su staging

Tutto il resto lo decide e lo esegue da solo.

### Reskin del design

Vuoi cambiare il design senza toccare la logica?

```
[RESKIN]
```

omega analizza il codice, separa design da logica, e rifa solo l'aspetto visivo.

### Audit UI anti-AI-slop

```
[AUDIT-UI]
```

omega verifica font, colori, layout e contenuti per assicurarsi che il risultato non sembri generato male dall'AI.

### Build check manuale

```
[CHECK]
```

Verifica build, TypeScript e test in qualsiasi momento. Viene anche eseguito automaticamente dall'autopilot.

### Recupera documentazione ufficiale

```
/omega:fetch-docs nextjs
/omega:fetch-docs stripe
/omega:fetch-docs fastapi
/omega:fetch-docs claude-code
```

### Usa un BLUEPRINT.md per saltare il wizard

Se hai già le idee chiare, crea un `BLUEPRINT.md` nella root del tuo progetto e omega lo legge direttamente — zero domande.

```bash
# Copia un template di esempio
cp /percorso/omega/examples/gestionale-magazzino/BLUEPRINT.md ./BLUEPRINT.md
# Modifica con i dettagli del tuo progetto, poi:
/omega:omega
```

Vedi la cartella `examples/` per 3 BLUEPRINT.md completi e commentati.

---

## Sub-skills

omega è modulare. Il skill principale (`omega`) orchestra automaticamente i sotto-moduli quando necessario — non devi invocarli manualmente, ma puoi farlo in qualsiasi momento.

| Skill | Shortcut | Scope |
|---|---|---|
| `omega` | — | Orchestratore principale, 4 percorsi, menu, piani |
| `omega-wizard` | — | Wizard adattivo (Nuovo/Esistente/Riprendi/Blueprint) |
| `omega-product-strategy` | `[PS]` | **Business canvas:** obiettivi, competitor research, feature suggestions, growth patterns, STRATEGY.md |
| `omega-beginner` | `[BEG]` | Principianti: 3 domande, 6 profili, zero jargon |
| `omega-autopilot-engine` | `[AP FULL]` | Autopilot BASE/FULL/FAST con build-check e audit UI integrati |
| `omega-stack-advisor` | `[STACK]` | Catalogo completo 19 categorie tecnologie, raccomandazioni per tipo progetto |
| `omega-tier-system` | `[DS]` | 4 tier di design: Funzionale/Professionale/Cinematic/Immersivo |
| `omega-blueprints` | — | 8 architetture per tipo progetto (gestionale/saas/ecommerce/landing/mobile/cli/showcase/monorepo) |
| `omega-reskin` | `[RESKIN]` | Cambio design senza toccare la logica |
| `omega-build-checker` | `[CHECK]` | Autocontrollo build/tsc/test/lint + baseline mode |
| `omega-audit-ui` | `[AUDIT-UI]` | Audit anti-AI-slop: font, colori, layout, contenuti |
| `omega-context-updater` | — | Aggiornamento progressivo CLAUDE.md + state.md |
| `omega-doc-generator` | — | Generazione/rigenerazione documenti omega/ con templates |
| `omega-stitch` | — | Import design esterno: URL/screenshot/Figma/CSS/DESIGN.md |
| `omega-debug` | — | Diagnostica automatica, 5 recovery scenarios |
| `omega-devops` | `[10]` | Docker, CI/CD, Nginx, SSL, monitoring |
| `omega-security` | `[SEC]` | OWASP audit avanzato, GDPR, pre-lancio |
| `omega-legacy` | `[LEG]` | Strangler Fig, MySQL→PostgreSQL, session bridging |
| `omega-testing` | `[T]` | Vitest, Playwright, k6, integration test DB reale |
| `omega-team` | `[TEAM]` | Multi-developer, PR workflow, sprint planning |
| `omega-pm` | `[PM]` | Vista business, rischi, launch readiness |
| `omega-supabase` | `[SUPA]` | RLS, Auth, Storage, real-time, migrations |
| `omega-multitenant` | `[MT]` | Row-level isolation, provisioning, feature gates |
| `omega-mobile` | `[MOB]` | Expo, EAS Build, App Store, Play Store |
| `omega-ai` | `[AI]` | Vercel AI SDK v6, RAG, tool calling, streaming |
| `omega-payments` | `[PAY]` | Stripe checkout, abbonamenti, webhook, Portal |
| `omega-python` | `[PY]` | FastAPI, SQLAlchemy, Alembic, pytest, Docker |
| `omega-cli` | `[CLI]` | CLI Node/Python, bot Discord/Telegram, GitHub Actions |

---

## 4 Tier di design

omega introduce un sistema a 4 livelli di complessità visiva. La palette è sempre personalizzata:

| Tier | Nome | Animazioni | Ideale per |
|------|------|------------|------------|
| 1 | Funzionale | Nessuna | Gestionali, ERP, tool interni |
| 2 | Professionale | Framer Motion base | SaaS B2C, dashboard |
| 3 | Cinematic | GSAP + Lenis | Landing premium, portfolio |
| 4 | Immersivo | Three.js / R3F | Showcase 3D, esperienze |

Il tier si sceglie all'avvio con omega-wizard. Puoi cambiarlo in qualsiasi momento con `[RESKIN]`.

---

## Google Stitch — Import design esterno (opzionale)

Se hai un design già fatto (da Stitch, un URL, o uno screenshot), omega può importarlo:

```
[STITCH] durante il wizard
```

omega estrae palette, font e pattern di spacing e li applica al `omega/design-system.md`.
Se non lo usi, omega genera il design da zero in base al tier scelto.

---

## Plugin complementari

omega si integra bene con altri plugin Claude Code:

| Plugin | Cosa aggiunge |
|--------|---------------|
| `frontend-design` | Componenti UI avanzati, ispirazione visiva |
| `code-reviewer` | Code review strutturata dopo ogni feature |

---

## Come funziona

### Wizard adattivo

Al primo avvio, omega rileva automaticamente il contesto:

```
Utente non tecnico?              → omega-beginner (3 domande, 6 profili)
Cartella vuota?                  → NUOVO: wizard intelligente
Progetto esistente, primo omega? → ESISTENTE: analisi codice + lacune
omega/ già presente?             → RIPRENDI: da dove eri rimasto
"Cambia design"?                 → RESKIN: chirurgico, solo design
BLUEPRINT.md presente?           → MODALITÀ C: salta wizard
[AP FULL]?                       → Autopilot fino al deploy
```

### Business canvas (omega-product-strategy)

Incluso automaticamente nel wizard per ogni progetto nuovo. Prima del codice:

1. Domande specifiche per tipo (SaaS → trial/freemium? E-commerce → AOV target? Mobile → paywall timing?)
2. Analisi competitor (Google / G2 / Reddit — gap di mercato identificati)
3. Feature suggerite proattivamente (core / crescita / avanzate con motivazione business)
4. North Star Metric e benchmarks di retention/conversione per tipo
5. Genera `omega/STRATEGY.md` — alimenta PRD e MVP come fonte di verità business

Invocabile anche su progetti esistenti con `[PS]`.

### Build check automatico

omega-build-checker viene eseguito automaticamente:
- Dopo ogni 3 file modificati
- Alla fine di ogni piano
- Prima di passare alla fase successiva

Se il build fallisce, omega si ferma e corregge prima di procedere.

### Documenti generati

Per ogni progetto, omega genera e mantiene aggiornati:

```
omega/
├── STRATEGY.md      ← Obiettivi business, competitor, feature scope, North Star, growth plan
├── MVP.md           ← Scope, feature obbligatorie, fuori scope, criterio di successo
├── PRD.md           ← Requisiti funzionali (RF-001...) e non funzionali
├── design-system.md ← Palette, tipografia, componenti, regole assolute
├── roadmap.md       ← Fasi 1-5 con checkbox
├── state.md         ← Stato corrente (max 60 righe, letto ad ogni sessione)
├── log.md           ← Log append-only di ogni azione con timestamp
└── plans/           ← Piani checkbox per ogni azione significativa
CLAUDE.md            ← Root del progetto — letto automaticamente da Claude Code ad ogni sessione
```

### Score sistema

Ad ogni avvio, omega calcola automaticamente lo stato del progetto:

| Area | Punti |
|---|---|
| Documentazione (MVP + PRD + design-system + roadmap) | /20 |
| Fasi completate (scala 10→50 per fase 1→5) | /50 |
| Sicurezza (audit completo + zero critici) | /15 |
| Testing configurato | /15 |
| **Totale** | **/100** |

### Hook automatici

- **SessionStart**: Carica `omega/state.md` + ultime 30 righe di log + calcola score + inietta palette e regole assolute da `omega/design-system.md`. Se autopilot attivo, lo segnala. Se `DESIGN.md` esiste nella root, suggerisce `omega-stitch`.
- **PostToolUse**: Quando completi tutti i checkbox di un piano, ti ricorda di aggiornare `## Stato: COMPLETE`.

---

## Struttura repository

```
omega/
├── .claude-plugin/
│   └── plugin.json              ← versione 4.2.1
├── skills/
│   ├── omega/SKILL.md           ← Orchestratore principale
│   │   └── references/          ← performance, accessibility, seo, api-patterns, security-defaults
│   ├── omega-wizard/SKILL.md
│   ├── omega-beginner/SKILL.md
│   ├── omega-autopilot-engine/SKILL.md
│   ├── omega-tier-system/SKILL.md + references/tier-1..4.md
│   ├── omega-blueprints/SKILL.md + references/8 blueprint
│   ├── omega-product-strategy/SKILL.md + references/ (question-trees, growth-patterns, competitor-research)
│   ├── omega-stack-advisor/SKILL.md + references/ (catalog, recommendations)
│   ├── omega-debug/SKILL.md
│   ├── omega-reskin/SKILL.md
│   ├── omega-build-checker/SKILL.md
│   ├── omega-audit-ui/SKILL.md + references/anti-slop-checklist.md
│   ├── omega-context-updater/SKILL.md
│   ├── omega-doc-generator/SKILL.md + references/templates.md
│   ├── omega-stitch/SKILL.md + references/stitch-guide.md
│   ├── omega-devops/SKILL.md + references/
│   ├── omega-security/SKILL.md + references/
│   ├── omega-legacy/SKILL.md + references/
│   ├── omega-testing/SKILL.md + references/
│   ├── omega-team/SKILL.md + references/
│   ├── omega-pm/SKILL.md + references/
│   ├── omega-supabase/SKILL.md + references/
│   ├── omega-multitenant/SKILL.md + references/
│   ├── omega-mobile/SKILL.md + references/
│   ├── omega-ai/SKILL.md + references/
│   ├── omega-payments/SKILL.md + references/
│   ├── omega-python/SKILL.md + references/
│   └── omega-cli/SKILL.md + references/
├── commands/                    ← comandi (fetch-docs)
│   └── fetch-docs.md
├── examples/                    ← BLUEPRINT.md di esempio per 3 tipi di progetto
│   ├── gestionale-magazzino/BLUEPRINT.md
│   ├── saas-b2c-tool/BLUEPRINT.md
│   └── landing-waitlist/BLUEPRINT.md
├── hooks/
│   └── hooks.json               ← SessionStart + PostToolUse
└── README.md
```

---

## Aggiornamenti

```bash
cd /percorso/omega
git pull
```

Nessun restart necessario se hai usato `settings.json` — le modifiche ai file SKILL.md sono lette alla prossima sessione.

Se hai usato `--plugin-dir`, riavvia Claude Code.

---

## Contribuire

Le contribuzioni sono benvenute. omega è fatto di file Markdown — non serve sapere programmare per contribuire.

### Come contribuire

1. **Fork** del repository
2. Crea un branch: `git checkout -b feature/nome-contributo`
3. Modifica o aggiungi file in `skills/` o `commands/`
4. Apri una **Pull Request** con descrizione di cosa hai cambiato e perché

### Cosa serve

- **Nuovi sub-skill** — nuovi framework, stack, scenari non coperti
- **Fix pattern** — API cambiate, pattern deprecati, errori nei codici di esempio
- **Traduzioni** — omega è in italiano ma i pattern di codice sono universali
- **Esempi reali** — casi d'uso concreti da aggiungere ai SKILL.md

### Struttura di un SKILL.md

```markdown
---
name: omega-[nome]
description: Use when [condizioni di trigger specifiche]
user-invocable: false
---

# omega-[nome] — [Titolo]

**Lingua:** Sempre italiano.

## [Sezione principale]
...

## CHECKLIST [NOME]
- [ ] ...
```

---

## FAQ

**Il plugin funziona solo con Claude Code?**  
Sì — è un plugin nativo per Claude Code con `--plugin-dir` o `pluginDirs` in settings.json.

**Costa qualcosa?**  
No. omega è MIT. Hai bisogno solo di un account Claude Code (che può avere costi propri di Anthropic).

**Posso usarlo per progetti già esistenti?**  
Sì. Il percorso ESISTENTE analizza il codice esistente e genera i documenti omega a partire da quello che c'è già.

**Funziona in inglese?**  
omega risponde sempre in italiano — è by design. I pattern di codice nei SKILL.md sono in inglese/TypeScript standard.

**Come aggiungo un framework non presente in fetch-docs?**  
Apri `commands/fetch-docs.md` e aggiungi una riga alla tabella mappatura. Pull request benvenuta.

**L'autopilot può rompere qualcosa?**  
L'autopilot ha 6 gate obbligatori — non tocca mai il deploy di produzione, le migration su dati reali, o operazioni a costo senza chiedere conferma esplicita.

**Quante sub-skill ha omega?**  
26 sub-skill specializzati, dall'orchestratore principale ai moduli per business strategy, mobile, AI, pagamenti, devops, sicurezza e molto altro.

**Cosa è il reskin?**  
omega-reskin cambia il design visivo senza toccare la logica. Analizza il codice, separa design da logica, e modifica solo le classi CSS e i componenti UI.

**Cosa fa omega-build-checker?**  
Verifica automaticamente che build, TypeScript e test siano verdi dopo ogni modifica significativa. Si chiama con `[CHECK]` o viene eseguito automaticamente dall'autopilot.

---

## Licenza

MIT — vedi [LICENSE](LICENSE).

---

## Changelog

Il changelog completo è in [CHANGELOG.md](CHANGELOG.md).

### v4.2.1 — Aprile 2026 (corrente)

**"Business strategy layer + bug fixes"**

- `omega-product-strategy` — business canvas adattivo: domande specifiche per tipo, competitor research, feature suggestions proattive, growth patterns, STRATEGY.md. Shortcut `[PS]`
- Wizard Step 1.5 obbligatorio: business canvas prima della scelta stack
- Autopilot FAST MODE documentato: 2 gate bloccanti, domande in batch
- 10 bug critici corretti (vedere CHANGELOG.md per dettaglio)

### v4.1.0 — Aprile 2026

**"Stack advisor + pattern avanzati tier 3/4"**

- `omega-stack-advisor` — catalogo 19 categorie, raccomandazioni per tipo progetto
- Pattern Tier 3: scroll-driven animations, text splitting, magnetic cursor
- Pattern Tier 4: GLSL shaderMaterial, React Spring+R3F, video texture
- Gate 5 (breaking change API) e Gate 6 (migration distruttiva staging) nell'autopilot

### v4.0.0 — Aprile 2026

**"Design system vivo, build sempre verde"**

- 8 nuovi skill: `omega-tier-system`, `omega-blueprints`, `omega-reskin`, `omega-build-checker`, `omega-audit-ui`, `omega-context-updater`, `omega-doc-generator`, `omega-stitch`
- Tutte le skill esistenti ristrutturate con progressive disclosure (`references/`)
- 4 percorsi adattivi: NUOVO / ESISTENTE / RIPRENDI / RESKIN
- Sicurezza Fase 1 integrata di default
