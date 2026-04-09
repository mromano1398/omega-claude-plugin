# Blueprint: CLI / Bot / Automazione

## Struttura CLI Node.js
```
src/
├── commands/
│   ├── init.ts
│   ├── deploy.ts
│   └── config.ts
├── lib/
│   ├── config.ts                # Lettura/scrittura config utente
│   ├── logger.ts                # Chalk + ora logger
│   └── api.ts                   # Client API se necessario
└── index.ts                     # Entry point
bin/
└── index.ts                     # Shebang + commander setup
package.json
tsconfig.json
```

## Commander.js Setup
```ts
// bin/index.ts
#!/usr/bin/env node
import { program } from 'commander'
import { version } from '../package.json'
import { initCommand } from '../src/commands/init'

program
  .name('mytool')
  .description('Descrizione del tool')
  .version(version)

program
  .command('init')
  .description('Inizializza un nuovo progetto')
  .argument('<name>', 'Nome del progetto')
  .option('-t, --template <template>', 'Template da usare', 'default')
  .option('--dry-run', 'Mostra cosa farebbe senza eseguire')
  .action(initCommand)

program
  .command('deploy')
  .description('Deploy del progetto')
  .requiredOption('-e, --env <environment>', 'Ambiente (staging|production)')
  .action(deployCommand)

program.parseAsync()
```

**Regola --help:** Ogni comando DEVE avere `.description()` completa.

## Exit Codes
```ts
// Convenzione Unix standard
process.exit(0)  // Successo
process.exit(1)  // Errore generico
process.exit(2)  // Errore uso (argomenti errati)
```

## Logger (chalk + ora)
```ts
// src/lib/logger.ts
import chalk from 'chalk'
import ora from 'ora'

export const log = {
  info: (msg: string) => console.log(chalk.blue('ℹ'), msg),
  success: (msg: string) => console.log(chalk.green('✓'), msg),
  warn: (msg: string) => console.log(chalk.yellow('⚠'), msg),
  error: (msg: string) => console.error(chalk.red('✗'), msg),
  spinner: (text: string) => ora(text).start()
}

// Uso:
const spinner = log.spinner('Inizializzo...')
await doSomething()
spinner.succeed('Inizializzazione completata')
```

## Config Utente
```ts
// src/lib/config.ts
import os from 'os'
import path from 'path'
import fs from 'fs'

const CONFIG_DIR = path.join(os.homedir(), '.config', 'mytool')
const CONFIG_FILE = path.join(CONFIG_DIR, 'config.json')

export function readConfig(): Config {
  if (!fs.existsSync(CONFIG_FILE)) return {}
  return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'))
}
export function writeConfig(config: Partial<Config>) {
  fs.mkdirSync(CONFIG_DIR, { recursive: true })
  fs.writeFileSync(CONFIG_FILE, JSON.stringify({ ...readConfig(), ...config }, null, 2))
}
```

## Bot Discord (discord.js v14)
```ts
// src/bot-discord.ts
import { Client, GatewayIntentBits, SlashCommandBuilder, REST, Routes } from 'discord.js'

const commands = [
  new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Risponde con pong')
    .toJSON()
]

// Deploy comandi
const rest = new REST().setToken(process.env.DISCORD_TOKEN!)
await rest.put(Routes.applicationCommands(process.env.CLIENT_ID!), { body: commands })

// Handler
client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return
  if (interaction.commandName === 'ping') {
    await interaction.reply({ content: 'Pong!', ephemeral: true })
  }
})
```

## Bot Telegram (Telegraf v4)
```ts
// src/bot-telegram.ts
import { Telegraf, Scenes, session, Markup } from 'telegraf'

const bot = new Telegraf(process.env.TELEGRAM_TOKEN!)

// Middleware auth
bot.use(async (ctx, next) => {
  const allowedUsers = process.env.ALLOWED_USERS?.split(',') ?? []
  if (!allowedUsers.includes(String(ctx.from?.id))) {
    return ctx.reply('Non autorizzato.')
  }
  return next()
})

// Keyboard inline
bot.command('menu', ctx => {
  return ctx.reply('Scegli:', Markup.inlineKeyboard([
    [Markup.button.callback('Opzione 1', 'opt1')],
    [Markup.button.callback('Opzione 2', 'opt2')]
  ]))
})

bot.action('opt1', ctx => ctx.editMessageText('Hai scelto Opzione 1'))
bot.launch()
```

## GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Ambiente'
        required: true
        default: 'staging'
        type: choice
        options: [staging, production]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'            # Caching dipendenze
      - run: npm ci
      - run: npm run build
      - name: Deploy
        run: ./scripts/deploy.sh ${{ inputs.environment }}
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
          API_TOKEN: ${{ secrets.API_TOKEN }}
```

## Installazione via npx
```json
// package.json
{
  "bin": { "mytool": "./bin/index.js" },
  "files": ["dist/", "bin/"],
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  }
}
```
Pubblica su npm: `npm publish --access public`
