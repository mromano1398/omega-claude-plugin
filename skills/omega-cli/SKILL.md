---
name: omega-cli
description: Use when building a CLI tool, automation script, Discord/Telegram bot, GitHub Action, cron job, or any non-web project that runs in a terminal or as a background service. Triggered by mentions of "CLI", "script", "bot Discord", "bot Telegram", "automazione", "cron", "terminale", "riga di comando".
user-invocable: false
---

# omega-cli — CLI · Bot · Automazioni · Script · Background Services

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- Commander.js: https://github.com/tj/commander.js
- Typer (Python): https://typer.tiangolo.com
- Discord.js: https://discord.js.org/docs
- Telegraf (Telegram): https://telegraf.js.org
- GitHub Actions: https://docs.github.com/en/actions

## QUANDO USARE

- CLI distribuita via npm o binario
- Script di automazione (Node.js o Python)
- Bot Discord o Telegram
- GitHub Action personalizzata
- Cron job schedulato

## FLUSSO DECISIONALE

```
CLI npm → Node.js + Commander.js + TypeScript
CLI binario → Go (unico binario cross-platform)
Script automazione → Python + Typer (se team Python) o Node.js
Bot Discord → Node.js + Discord.js v14
Bot Telegram → Node.js + Telegraf v4
GitHub Action → Node.js action + workflow YAML
Cron job → GitHub Actions schedule o /api/cron + cron-job.org
```

## REGOLE CHIAVE

1. **`#!/usr/bin/env node`** in cima al file entry point — obbligatorio
2. **`bin` field in `package.json`** con path corretto al file compilato
3. **`--help` funzionante** per ogni comando e sottocomando
4. **Exit code 1 sugli errori** — tool CI-friendly, mai swallowcare eccezioni
5. **Nessun secret hardcodato** — usa variabili d'ambiente
6. **Token bot in variabile d'ambiente** — mai nel codice o in git
7. **Graceful shutdown** per bot (SIGINT/SIGTERM) — `bot.stop()`
8. **`npm publish --dry-run`** prima di pubblicare su npm
9. **GitHub Secrets** per variabili sensitive nei workflow, mai in YAML
10. **`process.exit(1)`** nello script cron se errore — GitHub Action fallisce e notifica

## CHECKLIST SINTETICA

- [ ] `#!/usr/bin/env node` in cima al file entry point
- [ ] `bin` field in `package.json` con path corretto
- [ ] `--help` funzionante per ogni comando e sottocomando
- [ ] Gestione errori con exit code 1 (tool CI-friendly)
- [ ] Nessun secret hardcodato (usa variabili d'ambiente)
- [ ] Test per ogni comando principale
- [ ] [Bot] Token in variabile d'ambiente, mai nel codice
- [ ] [Bot] Gestione graceful shutdown (SIGINT/SIGTERM)
- [ ] [CLI npm] `npm publish --dry-run` prima di pubblicare
- [ ] [GitHub Action] Segreti in GitHub Secrets, non in workflow YAML

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/node-cli.md] — CLI Node.js+Commander, package.json config, spinner UX, config persistente, CLI Python Typer, pubblicazione npm, script cron
- [references/bots.md] — Bot Discord.js v14 (slash commands, eventi), Bot Telegraf v4 (session, conversazioni multi-step), GitHub Action release automatica
