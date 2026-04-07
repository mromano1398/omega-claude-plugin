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

---

## SCELTA STACK

| Tipo | Stack consigliato |
|---|---|
| CLI distribuita (npm) | **Node.js + Commander.js + TypeScript** |
| CLI distribuita (binario) | **Go** (binario unico, cross-platform) |
| Script/automazione | **Python + Typer** o **Node.js** |
| Bot Discord | **Node.js + Discord.js v14** |
| Bot Telegram | **Node.js + Telegraf v4** |
| GitHub Action | **Node.js** o **Docker** |
| Cron job | **Node.js script** + GitHub Actions scheduled |

---

## CLI NODE.JS + COMMANDER

```bash
mkdir mia-cli && cd mia-cli
npm init -y
npm install commander chalk ora
npm install -D typescript @types/node tsx
```

### `package.json` — configurazione CLI

```json
{
  "name": "mia-cli",
  "version": "1.0.0",
  "description": "Descrizione breve della CLI",
  "bin": {
    "mia-cli": "./dist/index.js"
  },
  "scripts": {
    "dev": "tsx src/index.ts",
    "build": "tsc",
    "test": "vitest run"
  },
  "files": ["dist"],
  "engines": { "node": ">=18" }
}
```

### `src/index.ts` — struttura CLI

```typescript
#!/usr/bin/env node
import { Command } from 'commander'
import chalk from 'chalk'
import { version } from '../package.json'

const program = new Command()

program
  .name('mia-cli')
  .description('Descrizione della tua CLI')
  .version(version)

// Comando principale
program
  .command('genera <nome>')
  .description('Genera qualcosa con <nome>')
  .option('-o, --output <dir>', 'Directory di output', '.')
  .option('-f, --force', 'Sovrascrivi se esiste')
  .action(async (nome: string, options: { output: string; force: boolean }) => {
    try {
      await generaAction(nome, options)
    } catch (err) {
      console.error(chalk.red(`Errore: ${err instanceof Error ? err.message : err}`))
      process.exit(1)
    }
  })

// Sottocomandi
const configCmd = program.command('config').description('Gestisci configurazione')
configCmd
  .command('set <key> <value>')
  .description('Imposta valore config')
  .action((key, value) => setConfig(key, value))

configCmd
  .command('get <key>')
  .description('Leggi valore config')
  .action((key) => console.log(getConfig(key)))

program.parse()
```

### Spinner e output (UX da terminale)

```typescript
import ora from 'ora'
import chalk from 'chalk'

async function generaAction(nome: string, options: { output: string; force: boolean }) {
  const spinner = ora(`Generando ${nome}...`).start()

  try {
    // Operazione asincrona
    await doSomething(nome)
    spinner.succeed(chalk.green(`✓ ${nome} generato in ${options.output}`))
  } catch (err) {
    spinner.fail(chalk.red(`Errore durante la generazione`))
    throw err
  }
}
```

### Config persistente (~/.config/mia-cli)

```typescript
import { readFileSync, writeFileSync, mkdirSync } from 'fs'
import { homedir } from 'os'
import { join } from 'path'

const CONFIG_DIR = join(homedir(), '.config', 'mia-cli')
const CONFIG_FILE = join(CONFIG_DIR, 'config.json')

export function getConfig(key: string): string | undefined {
  try {
    const config = JSON.parse(readFileSync(CONFIG_FILE, 'utf-8'))
    return config[key]
  } catch { return undefined }
}

export function setConfig(key: string, value: string) {
  mkdirSync(CONFIG_DIR, { recursive: true })
  const config = (() => {
    try { return JSON.parse(readFileSync(CONFIG_FILE, 'utf-8')) }
    catch { return {} }
  })()
  config[key] = value
  writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2))
}
```

---

## PYTHON CLI — Typer

```bash
pip install typer rich
```

```python
# main.py
import typer
from rich.console import Console
from rich.progress import track

app = typer.Typer(help="Descrizione della tua CLI")
console = Console()

@app.command()
def genera(
    nome: str = typer.Argument(..., help="Nome del file da generare"),
    output: str = typer.Option(".", "--output", "-o", help="Directory di output"),
    force: bool = typer.Option(False, "--force", "-f", help="Sovrascrivi se esiste"),
):
    """Genera qualcosa con NOME."""
    for step in track(["step 1", "step 2", "step 3"], description="Generando..."):
        processa(step)
    console.print(f"[green]✓ {nome} generato in {output}[/green]")

@app.command()
def config(key: str, value: str):
    """Imposta un valore di configurazione."""
    salva_config(key, value)
    console.print(f"[green]✓ {key} = {value}[/green]")

if __name__ == "__main__":
    app()
```

---

## BOT DISCORD — Discord.js v14

```bash
npm install discord.js
```

```typescript
// src/bot.ts
import { Client, GatewayIntentBits, Events, SlashCommandBuilder, REST, Routes } from 'discord.js'

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
})

// Definizione comandi slash
const commands = [
  new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Risponde con Pong!'),
  new SlashCommandBuilder()
    .setName('info')
    .setDescription('Mostra info del server'),
].map(cmd => cmd.toJSON())

// Registra comandi slash su Discord
async function registerCommands() {
  const rest = new REST().setToken(process.env.DISCORD_TOKEN!)
  await rest.put(
    Routes.applicationCommands(process.env.DISCORD_CLIENT_ID!),
    { body: commands }
  )
  console.log('Comandi registrati')
}

// Gestione eventi
client.on(Events.InteractionCreate, async interaction => {
  if (!interaction.isChatInputCommand()) return

  switch (interaction.commandName) {
    case 'ping':
      await interaction.reply({ content: 'Pong! 🏓', ephemeral: true })
      break

    case 'info':
      await interaction.reply({
        embeds: [{
          title: interaction.guild?.name ?? 'Server',
          description: `Membri: ${interaction.guild?.memberCount}`,
          color: 0x5865F2,
          timestamp: new Date().toISOString(),
        }]
      })
      break
  }
})

client.once(Events.ClientReady, () => {
  console.log(`Bot online come ${client.user?.tag}`)
})

registerCommands()
client.login(process.env.DISCORD_TOKEN)
```

---

## BOT TELEGRAM — Telegraf v4

```bash
npm install telegraf
```

```typescript
// src/bot.ts
import { Telegraf, Markup, session } from 'telegraf'
import type { Context } from 'telegraf'

interface SessionData {
  step: number
  data: Record<string, string>
}

type MyContext = Context & { session: SessionData }

const bot = new Telegraf<MyContext>(process.env.TELEGRAM_TOKEN!)

// Session middleware
bot.use(session({ defaultSession: () => ({ step: 0, data: {} }) }))

// Comandi
bot.command('start', ctx => {
  ctx.reply(
    'Ciao! Cosa vuoi fare?',
    Markup.keyboard([
      ['📋 Lista', '➕ Nuovo'],
      ['⚙️ Impostazioni'],
    ]).resize()
  )
})

bot.hears('📋 Lista', async ctx => {
  const items = await getItems(ctx.from.id)
  if (items.length === 0) {
    return ctx.reply('Nessun elemento ancora.')
  }
  await ctx.reply(items.map((i, n) => `${n + 1}. ${i.nome}`).join('\n'))
})

// Conversazione multi-step con scene (usa telegraf-scenes per workflow complessi)
bot.on('text', async ctx => {
  const { step } = ctx.session
  if (step === 1) {
    ctx.session.data.nome = ctx.message.text
    ctx.session.step = 2
    return ctx.reply('Perfetto! Ora dimmi la descrizione:')
  }
  if (step === 2) {
    await salva({ nome: ctx.session.data.nome, descrizione: ctx.message.text })
    ctx.session.step = 0
    return ctx.reply('✅ Salvato!')
  }
})

// Avvio
bot.launch({ dropPendingUpdates: true })
process.once('SIGINT', () => bot.stop('SIGINT'))
process.once('SIGTERM', () => bot.stop('SIGTERM'))
```

---

## GITHUB ACTION

```yaml
# .github/workflows/cron-task.yml
name: Task Schedulato

on:
  schedule:
    - cron: '0 8 * * 1-5'  # Lunedì-venerdì alle 08:00
  workflow_dispatch:  # Esecuzione manuale dal pannello GitHub

jobs:
  esegui:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with: { node-version: '20' }

      - run: npm ci
      - run: npm run task

        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
```

```typescript
// scripts/task.ts — eseguito dal GitHub Action
async function main() {
  console.log(`[${new Date().toISOString()}] Inizio task`)

  try {
    const result = await eseguiTask()
    console.log(`✓ Completato: ${result.count} elementi processati`)
    process.exit(0)
  } catch (err) {
    console.error(`✗ Errore:`, err)
    process.exit(1)  // Exit code 1 → GitHub Action fallisce + notifica email
  }
}

main()
```

---

## PUBBLICAZIONE NPM

```bash
# Login
npm login

# Test pubblicazione (dry run)
npm publish --dry-run

# Pubblica
npm publish --access public

# Versioning
npm version patch  # 1.0.0 → 1.0.1 (bugfix)
npm version minor  # 1.0.0 → 1.1.0 (nuova feature)
npm version major  # 1.0.0 → 2.0.0 (breaking change)
```

### GitHub Action per release automatica

```yaml
# .github/workflows/release.yml
on:
  push:
    tags: ['v*']

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # Per npm provenance
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci && npm run build
      - run: npm publish --provenance --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

---

## CHECKLIST CLI/BOT

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
