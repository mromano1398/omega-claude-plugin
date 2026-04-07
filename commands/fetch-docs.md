# /omega:fetch-docs

Recupera la documentazione ufficiale di un framework o libreria specificata in $ARGUMENTS.

## Mappatura framework → URL ufficiale

| Keyword | URL documentazione ufficiale |
|---|---|
| nextjs / next | https://nextjs.org/docs |
| react | https://react.dev/reference/react |
| typescript / ts | https://www.typescriptlang.org/docs |
| tailwind / tailwindcss | https://tailwindcss.com/docs |
| prisma | https://www.prisma.io/docs |
| postgresql / postgres / pg | https://www.postgresql.org/docs/current |
| nextauth / next-auth | https://next-auth.js.org/getting-started/introduction |
| authjs / auth.js | https://authjs.dev/getting-started |
| stripe | https://stripe.com/docs/api |
| resend | https://resend.com/docs/introduction |
| supabase | https://supabase.com/docs |
| vercel | https://vercel.com/docs |
| railway | https://docs.railway.app |
| docker | https://docs.docker.com/reference |
| nginx | https://nginx.org/en/docs |
| vitest | https://vitest.dev/guide |
| playwright | https://playwright.dev/docs/intro |
| k6 | https://k6.io/docs |
| zod | https://zod.dev |
| trpc | https://trpc.io/docs |
| astro | https://docs.astro.build |
| expo / react-native | https://docs.expo.dev |
| hono | https://hono.dev/docs |
| express | https://expressjs.com/en/api.html |
| owasp | https://owasp.org/www-project-top-ten |
| gdpr | https://gdpr.eu/what-is-gdpr |
| claude-code / claudecode | https://docs.anthropic.com/en/docs/claude-code/overview |
| anthropic | https://docs.anthropic.com |
| openai | https://platform.openai.com/docs |
| openapi / swagger | https://swagger.io/specification |
| shadcn | https://ui.shadcn.com/docs |
| radix | https://www.radix-ui.com/primitives/docs/overview/introduction |
| framer / framer-motion | https://www.framer.com/motion |
| gsap | https://gsap.com/docs/v3 |
| node / nodejs | https://nodejs.org/docs/latest/api |

## Istruzioni

1. Leggi `$ARGUMENTS` (il nome del framework da cercare)
2. Trova la riga corrispondente nella tabella sopra (cerca case-insensitive, match parziale)
3. Se trovato: usa il tool `WebFetch` per recuperare la documentazione dall'URL mappato
4. Se non trovato: esegui una ricerca web con `WebSearch` per trovare la documentazione ufficiale del framework specificato
5. Riassumi i punti più rilevanti per l'uso nel progetto corrente (considera il tipo di progetto da `omega/state.md` se esiste)

## Output atteso

```
📚 Documentazione: [Nome Framework] v[versione se disponibile]
🔗 Fonte: [URL]

## Punti chiave
- [concetto/API principale]
- [pattern consigliato]
- [best practice rilevante]

## Rilevante per questo progetto
- [perché è utile nel contesto del progetto corrente]
```

## Esempi di invocazione

```
/omega:fetch-docs nextjs          → recupera docs Next.js
/omega:fetch-docs prisma          → recupera docs Prisma ORM
/omega:fetch-docs stripe          → recupera docs API Stripe
/omega:fetch-docs claude-code     → recupera docs Claude Code
/omega:fetch-docs openapi         → recupera OpenAPI Specification
```
