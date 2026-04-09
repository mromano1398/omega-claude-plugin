# Provisioning — Onboarding Tenant e Inviti

## TENANT DETECTION — Middleware

### Opzione A — Subdomain (myorg.app.com)

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const hostname = request.headers.get('host') || ''
  const appDomain = process.env.NEXT_PUBLIC_APP_DOMAIN!  // 'app.com'

  // Estrai subdomain
  const subdomain = hostname.replace(`.${appDomain}`, '')
  const isRootDomain = subdomain === appDomain || !hostname.includes(appDomain)

  if (isRootDomain) {
    // Root domain → landing page
    return NextResponse.next()
  }

  // Aggiungi subdomain (slug tenant) all'header per uso in Server Components
  const response = NextResponse.next()
  response.headers.set('x-tenant-slug', subdomain)
  return response
}

export const config = {
  matcher: ['/((?!_next|api/public|favicon.ico).*)'],
}
```

```typescript
// lib/tenant.ts — recupera tenant in Server Component
import { headers } from 'next/headers'
import { cache } from 'react'
import { db } from './db'

export const getCurrentTenant = cache(async () => {
  const slug = headers().get('x-tenant-slug')
  if (!slug) return null

  const tenant = await db.organizzazioni.findUnique({ where: { slug } })
  return tenant
})
```

### Opzione B — Path-based (/org/[slug]/...)

```typescript
// app/org/[slug]/layout.tsx
import { db } from '@/lib/db'
import { notFound } from 'next/navigation'

export default async function TenantLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: { slug: string }
}) {
  const tenant = await db.organizzazioni.findUnique({
    where: { slug: params.slug }
  })

  if (!tenant) notFound()

  return (
    <TenantProvider tenant={tenant}>
      {children}
    </TenantProvider>
  )
}
```

## PROVISIONING — Onboarding nuovo tenant

```typescript
// app/actions/provisioning.ts
'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { generateSlug } from '@/lib/utils'

export async function creaOrganizzazione(nome: string) {
  const session = await auth()
  if (!session?.user?.id) throw new Error('Non autenticato')

  // Genera slug univoco
  const baseSlug = generateSlug(nome)
  let slug = baseSlug
  let count = 0
  while (await db.organizzazioni.findUnique({ where: { slug } })) {
    slug = `${baseSlug}-${++count}`
  }

  // Transazione: crea org + aggiungi utente come OWNER
  const result = await db.$transaction(async (tx) => {
    const org = await tx.organizzazioni.create({
      data: { nome, slug, piano: 'FREE' }
    })

    await tx.membri.create({
      data: {
        utente_id: session.user.id,
        organizzazione_id: org.id,
        ruolo: 'OWNER',
      }
    })

    // Provisioning iniziale: crea dati di default (es. categorie, template)
    await tx.categorie.createMany({
      data: CATEGORIE_DEFAULT.map(c => ({
        ...c,
        organizzazione_id: org.id
      }))
    })

    return org
  })

  return result
}
```

## INVITI TEAM

```typescript
// Schema
// CREATE TABLE inviti (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   organizzazione_id UUID NOT NULL REFERENCES organizzazioni(id),
//   email TEXT NOT NULL,
//   ruolo TEXT NOT NULL DEFAULT 'MEMBER',
//   token TEXT UNIQUE NOT NULL,  -- token sicuro per accettazione
//   scade_il TIMESTAMPTZ NOT NULL,
//   accettato_il TIMESTAMPTZ,
//   creato_da UUID REFERENCES auth.users(id)
// );

// app/actions/inviti.ts
export async function invitaMembro(email: string, organizzazioneId: string, ruolo: string) {
  const session = await auth()
  if (!session?.user) throw new Error('Non autenticato')

  // Verifica che l'utente sia OWNER o ADMIN
  const membro = await db.membri.findFirst({
    where: {
      utente_id: session.user.id,
      organizzazione_id: organizzazioneId,
      ruolo: { in: ['OWNER', 'ADMIN'] }
    }
  })
  if (!membro) throw new Error('Non autorizzato')

  const token = crypto.randomUUID()
  await db.inviti.create({
    data: {
      email,
      organizzazione_id: organizzazioneId,
      ruolo,
      token,
      scade_il: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),  // 7 giorni
      creato_da: session.user.id,
    }
  })

  // Invia email con link /inviti/accetta/[token]
  await sendEmail({
    to: email,
    subject: `Invito a ${org.nome}`,
    html: inviteEmailTemplate(token, org.nome),
  })
}
```
