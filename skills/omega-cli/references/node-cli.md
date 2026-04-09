# Node CLI — Commander.js, Typer, GitHub Actions

Doc ufficiale:
- Commander.js: https://github.com/tj/commander.js
- Typer (Python): https://typer.tiangolo.com
- GitHub Actions: https://docs.github.com/en/actions

## Scelta stack

| Tipo | Stack consigliato |
|---|---|
| CLI distribuita (npm) | **Node.js + Commander.js + TypeScript** |
| CLI distribuita (binario) | **Go** (binario unico, cross-platform) |
| Script/automazione | **Python + Typer** o **Node.js** |
| GitHub Action | **Node.js** o **Docker** |
| Cron job | **Node.js script** + GitHub Actions scheduled |

## CLI Node.js + Commander

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

## Python CLI — Typer

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

if __name__ == "__main__":
    app()
```

## Pubblicazione NPM

```bash
npm login
npm publish --dry-run    # Test pubblicazione
npm publish --access public

# Versioning
npm version patch  # 1.0.0 → 1.0.1 (bugfix)
npm version minor  # 1.0.0 → 1.1.0 (nuova feature)
npm version major  # 1.0.0 → 2.0.0 (breaking change)
```

## GitHub Action per cron task schedulato

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

## GitHub Action — Script da cron

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
