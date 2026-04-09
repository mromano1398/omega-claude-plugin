# Bot — Discord e Telegram

Doc ufficiale:
- Discord.js: https://discord.js.org/docs
- Telegraf (Telegram): https://telegraf.js.org

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

// Conversazione multi-step con scene
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

## GitHub Action per release NPM automatica

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
      id-token: write
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
