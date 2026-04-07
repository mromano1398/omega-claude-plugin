# omega

> **Universal lifecycle navigator for Claude Code** — from idea to production, for any project type, for everyone.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-orange?logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code/overview)
[![Version](https://img.shields.io/badge/version-3.0.0-blue)](https://github.com/mromano1398/omega-claude-plugin/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Skills](https://img.shields.io/badge/sub--skills-17-purple)](skills/)
[![Language](https://img.shields.io/badge/language-Italiano-red)](README.md)

---

**omega** è un plugin per [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) che ti guida dall'idea al prodotto finale in produzione — con wizard adattivo, piani checkbox, log persistente, autopilot autonomo e 17 sub-skill specializzati per ogni scenario.

**Funziona per:** sviluppatori esperti, principianti assoluti, team, project manager.  
**Costruisce:** web app, SaaS, gestionali, e-commerce, app mobile iOS/Android, API, CLI, bot, script Python, progetti AI.  
**Lingua:** sempre italiano.

---

## Requisiti

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) — versione con supporto plugin (`--plugin-dir`)
- Nessun altro requisito — omega è puro testo (Markdown + JSON)

---

## Installazione

### Metodo 1 — Sessione singola (prova rapida)

```bash
git clone https://github.com/mromano1398/omega-claude-plugin.git
claude --plugin-dir ./omega-claude-plugin
```

### Metodo 2 — Permanente (consigliato)

Clona il repository ovunque vuoi, poi aggiungi il percorso in `settings.json` di Claude Code:

**Mac/Linux:** `~/.claude/settings.json`  
**Windows:** `C:\Users\<nome>\\.claude\settings.json`

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

omega legge tutto, crea il piano completo e implementa autonomamente — si ferma **solo** per 4 decisioni obbligatorie:
1. Deploy in produzione
2. Migration su dati reali
3. Costi monetari
4. Requisiti ambigui

Tutto il resto lo decide e lo esegue da solo.

### Recupera documentazione ufficiale

```
/omega:fetch-docs nextjs
/omega:fetch-docs stripe
/omega:fetch-docs fastapi
/omega:fetch-docs claude-code
```

---

## Sub-skills

omega è modulare. Il skill principale (`omega`) orchestra automaticamente i sotto-moduli quando necessario — non devi invocarli manualmente, ma puoi farlo in qualsiasi momento.

| Skill | Shortcut menu | Scope |
|---|---|---|
| `omega` | — | Orchestratore principale, wizard, menu, piani, state |
| `omega-wizard` | — | Wizard 8 domande, MODALITÀ A/B/C, generazione documenti |
| `omega-beginner` | `[BEG]` | Principianti: 3 domande, profili preconfezionati, zero jargon |
| `omega-autopilot-engine` | `[AP FULL]` | Autopilot autonomo, 4 gate, session resume, "definizione di completo" |
| `omega-devops` | `[10]` | Docker corretto, CI/CD GitHub Actions, Nginx, SSL, monitoring |
| `omega-security` | `[SEC]` | OWASP Top 10:2025, GDPR, auth sicura, file upload, audit log PII |
| `omega-legacy` | `[LEG]` | Strangler Fig, MySQL→PostgreSQL, session bridging, rollback plan |
| `omega-testing` | `[T]` | Vitest, Playwright, k6, integration test DB reale, OpenAPI contract |
| `omega-team` | `[TEAM]` | Multi-developer, PR workflow, sprint planning, standup, release |
| `omega-pm` | `[PM]` | Vista business PM, rischi in linguaggio semplice, launch readiness |
| `omega-supabase` | `[SUPA]` | RLS policies, Auth, Storage, real-time, migrations workflow |
| `omega-multitenant` | `[MT]` | Row-level isolation, tenant detection, provisioning, feature gates |
| `omega-mobile` | `[MOB]` | Expo, EAS Build, App Store submission (iOS), Play Store (Android) |
| `omega-ai` | `[AI]` | Vercel AI SDK v6, RAG con pgvector, tool calling, streaming, guardrails |
| `omega-payments` | `[PAY]` | Stripe checkout, abbonamenti, webhook idempotente, Customer Portal |
| `omega-python` | `[PY]` | FastAPI, SQLAlchemy 2.0 async, Alembic, pytest, Docker |
| `omega-cli` | `[CLI]` | CLI Node/Python, bot Discord/Telegram, GitHub Actions, script |

---

## Come funziona

### Wizard adattivo

Al primo avvio, omega rileva automaticamente il contesto:

```
Utente non tecnico?      → omega-beginner (3 domande, profili preconfezionati)
Cartella vuota?          → MODALITÀ A: wizard 8 domande
Progetto esistente?      → MODALITÀ B: 5 domande mirate, analisi del codice
BLUEPRINT.md presente?   → MODALITÀ C: salta wizard, genera documenti dal blueprint
```

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

- **SessionStart**: Carica `omega/state.md` + ultime 30 righe di log + calcola score. Se autopilot attivo, lo riprende automaticamente.
- **PostToolUse**: Quando completi tutti i checkbox di un piano, ti ricorda di aggiornare `## Stato: COMPLETE`.

---

## Struttura repository

```
omega/
├── .claude-plugin/
│   └── plugin.json              ← Manifest del plugin (nome, versione, descrizione)
├── skills/
│   ├── omega/SKILL.md           ← Orchestratore principale
│   ├── omega-wizard/SKILL.md
│   ├── omega-beginner/SKILL.md
│   ├── omega-autopilot-engine/SKILL.md
│   ├── omega-devops/SKILL.md
│   ├── omega-security/SKILL.md
│   ├── omega-legacy/SKILL.md
│   ├── omega-testing/SKILL.md
│   ├── omega-team/SKILL.md
│   ├── omega-pm/SKILL.md
│   ├── omega-supabase/SKILL.md
│   ├── omega-multitenant/SKILL.md
│   ├── omega-mobile/SKILL.md
│   ├── omega-ai/SKILL.md
│   ├── omega-payments/SKILL.md
│   ├── omega-python/SKILL.md
│   └── omega-cli/SKILL.md
├── commands/
│   └── fetch-docs.md            ← /omega:fetch-docs [framework]
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
Sì. La MODALITÀ B analizza il codice esistente e genera i documenti omega a partire da quello che c'è già.

**Funziona in inglese?**  
omega risponde sempre in italiano — è by design. I pattern di codice nei SKILL.md sono in inglese/TypeScript standard.

**Come aggiungo un framework non presente in fetch-docs?**  
Apri `commands/fetch-docs.md` e aggiungi una riga alla tabella mappatura. Pull request benvenuta.

**L'autopilot può rompere qualcosa?**  
L'autopilot ha 4 gate obbligatori — non tocca mai il deploy di produzione, le migration su dati reali, o operazioni a costo senza chiedere conferma esplicita.

---

## Licenza

MIT — vedi [LICENSE](LICENSE).

---

## Changelog

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
