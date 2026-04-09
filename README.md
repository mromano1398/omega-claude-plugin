# omega

> **Universal lifecycle navigator for Claude Code** — from idea to production, for any project type, for everyone.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-orange?logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code/overview)
[![Version](https://img.shields.io/badge/version-4.1.0-blue)](https://github.com/mromano1398/omega-claude-plugin/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Skills](https://img.shields.io/badge/sub--skills-25-purple)](skills/)
[![Language](https://img.shields.io/badge/language-Italiano-red)](README.md)
[![CI](https://github.com/mromano1398/omega-claude-plugin/actions/workflows/validate.yml/badge.svg)](https://github.com/mromano1398/omega-claude-plugin/actions/workflows/validate.yml)

---

**omega** è un plugin per [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) che ti guida dall'idea al prodotto finale in produzione — con 4 percorsi adattivi, wizard intelligente, piani checkbox, log persistente, autopilot autonomo e 25 sub-skill specializzati per ogni scenario.

**Funziona per:** sviluppatori esperti, principianti assoluti, team, project manager.  
**Costruisce:** web app, SaaS, gestionali, e-commerce, app mobile iOS/Android, API, CLI, bot, script Python, progetti AI.  
**4 tier di design:** da interfacce funzionali a esperienze 3D immersive.  
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
| `omega-wizard` | — | Wizard adattivo (Nuovo/Esistente/Riprendi) |
| `omega-beginner` | `[BEG]` | Principianti: 3 domande, 6 profili, zero jargon |
| `omega-autopilot-engine` | `[AP FULL]` | Autopilot con build-check e audit UI integrati |
| `omega-tier-system` | `[DS]` | 4 tier di design: Funzionale/Professionale/Cinematic/Immersivo |
| `omega-blueprints` | — | 7 architetture per tipo progetto |
| `omega-reskin` | `[RESKIN]` | Cambio design senza toccare la logica |
| `omega-build-checker` | `[CHECK]` | Autocontrollo build/tsc/test/lint |
| `omega-audit-ui` | `[AUDIT-UI]` | Audit anti-AI-slop: font, colori, layout, contenuti |
| `omega-context-updater` | — | Aggiornamento progressivo CLAUDE.md |
| `omega-doc-generator` | — | Generazione/rigenerazione documenti omega/ |
| `omega-stitch` | — | Import design esterno (opzionale) |
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
| `omega-stack-advisor` | `[STACK]` | Catalogo completo 18 categorie tecnologie, raccomandazioni per tipo progetto, verifica compatibilità |

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
Cartella vuota?                  → NUOVO: wizard 5 domande
Progetto esistente, primo omega? → ESISTENTE: analisi codice + lacune
omega/ già presente?             → RIPRENDI: da dove eri rimasto
"Cambia design"?                 → RESKIN: chirurgico, solo design
BLUEPRINT.md presente?           → MODALITÀ C: salta wizard
[AP FULL]?                       → Autopilot fino al deploy
```

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
│   └── plugin.json              ← versione 4.1.0
├── skills/
│   ├── omega/SKILL.md           ← Orchestratore principale
│   │   └── references/          ← performance, accessibility, seo, api-patterns, security-defaults
│   ├── omega-wizard/SKILL.md
│   ├── omega-beginner/SKILL.md
│   ├── omega-autopilot-engine/SKILL.md
│   ├── omega-tier-system/SKILL.md + references/tier-1..4.md
│   ├── omega-blueprints/SKILL.md + references/7 blueprint
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
25 sub-skill specializzati, dall'orchestratore principale ai moduli per mobile, AI, pagamenti, devops, sicurezza e molto altro.

**Cosa è il reskin?**  
omega-reskin cambia il design visivo senza toccare la logica. Analizza il codice, separa design da logica, e modifica solo le classi CSS e i componenti UI.

**Cosa fa omega-build-checker?**  
Verifica automaticamente che build, TypeScript e test siano verdi dopo ogni modifica significativa. Si chiama con `[CHECK]` o viene eseguito automaticamente dall'autopilot.

---

## Licenza

MIT — vedi [LICENSE](LICENSE).

---

## Changelog

### v4.0.0 — Aprile 2026

**"Design system vivo, build sempre verde"**

**Nuovi skill (8):**
- `omega-tier-system` — 4 tier di design (Funzionale/Professionale/Cinematic/Immersivo)
- `omega-blueprints` — 7 architetture per tipo progetto
- `omega-reskin` — cambio design chirurgico senza toccare la logica
- `omega-build-checker` — autocontrollo build/tsc/test dopo ogni modifica
- `omega-audit-ui` — audit anti-AI-slop: font, colori, layout, contenuti
- `omega-context-updater` — CLAUDE.md sempre aggiornato con stato reale del progetto
- `omega-doc-generator` — genera/rigenera tutti i documenti omega/ (con templates)
- `omega-stitch` — import design esterno opzionale (URL/screenshot/DESIGN.md)

**Ristrutturazione skill (13):**
- Tutte le skill esistenti ristrutturate con progressive disclosure
- Contenuto tecnico spostato in `references/` per ridurre l'uso di context window
- Ogni SKILL.md ora max 100-150 righe, references/ separati per dettagli

**Nuovi flussi:**
- 4 percorsi adattivi: NUOVO / ESISTENTE / RIPRENDI / RESKIN
- Wizard ridotto a max 4 domande (era 8)
- Sicurezza Fase 1 integrata di default (non più opt-in)
- Build check automatico ogni 3 file + fine piano
- Audit UI obbligatorio fine Fase 2
- Context update progressivo dopo ogni piano completato

**omega-beginner:**
- 6 profili (aggiunto Portfolio/Showcase)
- Tier semplificato: SEMPLICE/BELLO/WOW/3D

### v3.1.0 — Aprile 2026

**"Design system sempre presente"**

- `CLAUDE.md` generato automaticamente dal wizard come primo documento — letto da Claude Code ad ogni sessione
- Hook SessionStart: inietta palette + regole assolute da `omega/design-system.md` ad ogni avvio
- Palette personalizzata per stile (funzionale/moderno/marketing/bilanciato) — no più colori default fissi
- Propagazione obbligatoria `design-system.md` → `CLAUDE.md` ad ogni `[DS]`
- Step `[E] FONDAMENTA`: dettaglio componenti UI (shadcn o manuale) + pagina modello `esempio/page.tsx`
- Autopilot: check CLAUDE.md mancante nella mappa di decisione
- Fix: rimosso riferimento a `AGENTS.md` mai generato
- Fix: versione allineata a v3.1.0 in tutti i file

### v3.0.0 — Aprile 2026

**"Per tutti, per qualsiasi cosa"**

- `omega-beginner` — principianti assoluti, 3 domande, 5 profili preconfezionati
- `omega-autopilot-engine` — autopilot autonomo reale con gate system, session resume, "definizione di COMPLETO" per tipo progetto
- `omega-mobile` — iOS + Android completo, Expo, EAS Build, guida submission App Store e Play Store (asset, metadati, rejection reasons)
- `omega-ai` — Vercel AI SDK v6 aggiornato (fixed: `generateObject→Output.object`, `useChat` transport, `stopWhen`), RAG con pgvector, tool calling, guardrails
- `omega-payments` — Stripe checkout + abbonamenti + webhook idempotente + Customer Portal + IVA italiana
- `omega-python` — FastAPI, SQLAlchemy 2.0 async, Alembic, pytest con rollback, Docker
- `omega-cli` — CLI Node.js + Python Typer, bot Discord.js v14, Telegraf v4, GitHub Actions
- Menu orchestratore con 17 shortcut `[XXX]`

### v2.0.0

- `omega-team` — coordinamento multi-developer, PR workflow, sprint planning
- `omega-pm` — vista business per PM non tecnici
- `omega-supabase` — RLS, Auth, Storage, real-time
- `omega-multitenant` — isolamento dati, tenant detection, provisioning
- `/omega:fetch-docs` — documentazione ufficiale online per 30+ framework
- Score system nel SessionStart hook

### v1.0.0

- Prima versione come plugin Claude Code
- `omega-devops` — Dockerfile corretto (fix `.next/static`), CI/CD, Nginx
- `omega-security` — file upload fuori da `public/`, audit log con PII masking, IDOR protection
- `omega-legacy` — Strangler Fig, MySQL→PostgreSQL, session bridging
- `omega-testing` — integration test con DB reale (transazione rollback), k6 advisory lock
- Hook SessionStart e PostToolUse
