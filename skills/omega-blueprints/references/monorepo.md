# Blueprint: Monorepo / Micro-frontend

**Quando usarlo:** team multipli su più app che condividono codice, design system condiviso, o architettura micro-frontend con più Next.js app indipendenti.

**Stack di default:** Turborepo + pnpm workspaces + Next.js (per ogni app) + shared packages

---

## Struttura cartelle — Turborepo

```
monorepo/
├── apps/
│   ├── web/                    ← app principale (Next.js)
│   ├── admin/                  ← pannello admin (Next.js separato)
│   └── docs/                   ← documentazione (Astro o Next.js)
├── packages/
│   ├── ui/                     ← design system condiviso (shadcn/ui base)
│   ├── database/               ← Prisma schema + client condiviso
│   ├── auth/                   ← Auth.js config condivisa
│   ├── config/
│   │   ├── eslint/             ← config ESLint condivisa
│   │   ├── typescript/         ← tsconfig base condiviso
│   │   └── tailwind/           ← tailwind.config base
│   └── utils/                  ← utility condivise (validazione, formatting)
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

---

## Setup iniziale

```bash
# Crea monorepo con Turborepo
npx create-turbo@latest my-monorepo
cd my-monorepo

# Struttura pnpm-workspace.yaml
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

# turbo.json base
cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": { "cache": false, "persistent": true },
    "lint": {},
    "type-check": {}
  }
}
EOF
```

---

## Package UI condiviso (design system)

```typescript
// packages/ui/package.json
{
  "name": "@repo/ui",
  "exports": {
    "./button": "./src/button.tsx",
    "./card": "./src/card.tsx",
    // aggiungi per ogni componente
  },
  "peerDependencies": {
    "react": "^19",
    "react-dom": "^19"
  }
}

// In ogni app che lo usa:
// apps/web/package.json
{
  "dependencies": {
    "@repo/ui": "workspace:*"
  }
}

// Importo nel codice:
import { Button } from "@repo/ui/button"
```

---

## Package Database condiviso

```typescript
// packages/database/package.json
{
  "name": "@repo/database",
  "exports": {
    ".": "./src/index.ts"
  }
}

// packages/database/src/index.ts
export { PrismaClient } from "@prisma/client"
export * from "@prisma/client"

// Singleton pattern per dev (evita too many connections):
import { PrismaClient } from "@prisma/client"

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }
export const prisma = globalForPrisma.prisma ?? new PrismaClient()
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma
```

---

## Script root package.json

```json
{
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "type-check": "turbo type-check",
    "format": "prettier --write \"**/*.{ts,tsx,md}\"",
    "db:push": "pnpm --filter @repo/database db:push",
    "db:migrate": "pnpm --filter @repo/database db:migrate"
  }
}
```

---

## Vercel Deploy — monorepo

```json
// vercel.json nella root (deploy app specifica)
{
  "buildCommand": "cd ../.. && npx turbo build --filter=web",
  "outputDirectory": "apps/web/.next",
  "installCommand": "pnpm install --frozen-lockfile"
}
```

Oppure usa Vercel Projects separati (uno per app), puntando ognuno alla sua `apps/[nome]/`.

---

## Moduli core per monorepo

- [ ] Turborepo + pnpm workspaces configurati
- [ ] `@repo/ui` con componenti base condivisi
- [ ] `@repo/database` con Prisma singleton
- [ ] `@repo/auth` con Auth.js config condivisa
- [ ] `@repo/config` (eslint, tsconfig, tailwind base)
- [ ] Pipeline CI che builda solo i pacchetti modificati (Turborepo remote cache)
- [ ] Versioning interno con Changesets (per librerie pubblicate)

---

## Stack di default

```
Monorepo:  Turborepo + pnpm workspaces
Apps:      Next.js App Router (una per contesto)
Shared UI: packages/ui con shadcn/ui base
Database:  packages/database con Prisma o pg diretto
Auth:      packages/auth con Auth.js v5
Deploy:    Vercel (un progetto per app) o Railway
CI:        GitHub Actions + Turborepo remote cache
```

---

## Sicurezza specifica

- Ogni app ha il suo `.env` — non usare variabili d'ambiente condivise tra app
- `packages/` non dovrebbe mai contenere segreti
- Verifica che `packages/ui` non esponga API keys accidentalmente
- Remote cache Turborepo: usa token separato per CI vs dev locale

---

## Checklist pre-lancio monorepo

- [ ] Build di tutte le app verde (`turbo build`)
- [ ] Type check passa su tutti i package (`turbo type-check`)
- [ ] Nessuna dipendenza ciclica tra packages
- [ ] `packages/ui` ha exports corretti per tutti i componenti usati
- [ ] Variabili d'ambiente documentate per ogni app
- [ ] Remote cache Turborepo configurata per CI (riduce build time 60-80%)
- [ ] Deploy verificato: ogni app deploya indipendentemente
