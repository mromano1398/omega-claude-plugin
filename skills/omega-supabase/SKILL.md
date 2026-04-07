---
name: omega-supabase
description: Use when the project uses Supabase as database/auth/storage backend. Covers Row Level Security, Auth.js adapter, real-time subscriptions, Supabase Storage, Edge Functions, and migration workflow. Triggered when stack includes Supabase or user mentions RLS, Supabase Auth, or Supabase Storage.
user-invocable: false
---

# omega-supabase — RLS · Auth · Storage · Real-time · Migrations

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- Docs: https://supabase.com/docs
- Auth.js adapter: https://authjs.dev/getting-started/adapters/supabase
- RLS guide: https://supabase.com/docs/guides/database/postgres/row-level-security

---

## SETUP INIZIALE

```bash
npm install @supabase/supabase-js @supabase/ssr
# Per Auth.js con Supabase:
npm install next-auth @auth/supabase-adapter
```

### Variabili d'ambiente
```bash
NEXT_PUBLIC_SUPABASE_URL=https://[project-ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...   # Solo server-side, mai al client
```

### Client Supabase — Pattern SSR (App Router)

```typescript
// lib/supabase/server.ts — Per Server Components e Server Actions
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch { /* In Server Components, set è ignorato */ }
        },
      },
    }
  )
}

// lib/supabase/client.ts — Per Client Components (CSR)
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}

// lib/supabase/admin.ts — Per operazioni admin server-side (bypass RLS)
import { createClient } from '@supabase/supabase-js'

export const adminClient = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { auth: { autoRefreshToken: false, persistSession: false } }
)
// ⚠️ adminClient bypassa RLS — usare solo per operazioni privilegiate lato server
```

---

## ROW LEVEL SECURITY (RLS)

### Principio fondamentale

**RLS è la prima linea di difesa del DB.** Attiva su OGNI tabella che contiene dati utente.

```sql
-- Attiva RLS sulla tabella
ALTER TABLE ordini ENABLE ROW LEVEL SECURITY;

-- Senza policy: nessuno accede (default deny)
-- Con anon key e RLS attivo: solo le policy permettono accesso
```

### Policy pattern — CRUD completo per owner

```sql
-- Utente vede solo i propri record
CREATE POLICY "utenti vedono i propri ordini"
  ON ordini FOR SELECT
  USING (auth.uid() = utente_id);

-- Utente crea solo record propri
CREATE POLICY "utenti creano propri ordini"
  ON ordini FOR INSERT
  WITH CHECK (auth.uid() = utente_id);

-- Utente modifica solo i propri
CREATE POLICY "utenti modificano propri ordini"
  ON ordini FOR UPDATE
  USING (auth.uid() = utente_id)
  WITH CHECK (auth.uid() = utente_id);

-- Utente cancella solo i propri
CREATE POLICY "utenti cancellano propri ordini"
  ON ordini FOR DELETE
  USING (auth.uid() = utente_id);
```

### Policy per ruoli (RBAC)

```sql
-- Tabella con colonna ruolo in JWT
CREATE POLICY "admin vede tutto"
  ON ordini FOR SELECT
  USING (auth.jwt() ->> 'user_role' = 'admin');

-- Oppure con tabella profili separata
CREATE POLICY "admin vede tutto"
  ON ordini FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profili
      WHERE profili.id = auth.uid()
      AND profili.ruolo = 'ADMIN'
    )
  );
```

### Policy per organizzazioni (multi-tenant in row-level)

```sql
-- Utente vede i dati della sua organizzazione
CREATE POLICY "member vede dati organizzazione"
  ON clienti FOR SELECT
  USING (
    organizzazione_id IN (
      SELECT organizzazione_id FROM membri
      WHERE utente_id = auth.uid()
    )
  );
```

### Verifica RLS dal codice

```typescript
// ✅ Corretto — usa anon key, RLS filtra automaticamente
const supabase = createClient()
const { data } = await supabase.from('ordini').select('*')
// Ritorna solo gli ordini dell'utente autenticato

// ✅ Admin bypass (server-side only, per operazioni privilegiate)
const { data: all } = await adminClient.from('ordini').select('*')
// Ritorna TUTTI gli ordini — usare con cautela
```

---

## AUTH — Supabase Auth + Auth.js

### Opzione A — Supabase Auth nativo (consigliata per nuovi progetti)

```typescript
// app/login/page.tsx
'use client'
import { createClient } from '@/lib/supabase/client'

export default function LoginPage() {
  const supabase = createClient()

  const signInWithEmail = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: `${location.origin}/auth/callback` }
    })
  }
}

// app/auth/callback/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (code) {
    const supabase = createClient()
    await supabase.auth.exchangeCodeForSession(code)
  }
  return NextResponse.redirect(`${origin}/dashboard`)
}
```

### Opzione B — Auth.js con Supabase Adapter

```typescript
// auth.ts
import NextAuth from 'next-auth'
import { SupabaseAdapter } from '@auth/supabase-adapter'
import Google from 'next-auth/providers/google'

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: SupabaseAdapter({
    url: process.env.NEXT_PUBLIC_SUPABASE_URL!,
    secret: process.env.SUPABASE_SERVICE_ROLE_KEY!,
  }),
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
})
```

### Middleware per protezione route

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  if (!user && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return response
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
}
```

---

## REAL-TIME

### Subscription a tabella (Client Component)

```typescript
'use client'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState } from 'react'

export function LiveOrders() {
  const [orders, setOrders] = useState<Order[]>([])
  const supabase = createClient()

  useEffect(() => {
    // Carica inizialmente
    supabase.from('ordini').select('*').then(({ data }) => {
      if (data) setOrders(data)
    })

    // Subscribe agli aggiornamenti
    const channel = supabase
      .channel('ordini-live')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'ordini' },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setOrders(prev => [...prev, payload.new as Order])
          }
          if (payload.eventType === 'UPDATE') {
            setOrders(prev => prev.map(o =>
              o.id === payload.new.id ? payload.new as Order : o
            ))
          }
          if (payload.eventType === 'DELETE') {
            setOrders(prev => prev.filter(o => o.id !== payload.old.id))
          }
        }
      )
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [])

  return <div>{/* render orders */}</div>
}
```

**Nota:** Real-time funziona con RLS attiva — ogni utente riceve solo gli aggiornamenti che può vedere.

---

## SUPABASE STORAGE

### Setup bucket

```sql
-- In SQL Editor di Supabase
INSERT INTO storage.buckets (id, name, public) VALUES ('documenti', 'documenti', false);
-- false = privato, richiede auth per accesso

-- Policy storage — solo owner può leggere/caricare
CREATE POLICY "utenti gestiscono i propri file"
  ON storage.objects FOR ALL
  USING (auth.uid()::text = (storage.foldername(name))[1])
  WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);
```

### Upload dal Server Action

```typescript
// app/actions/upload.ts
'use server'
import { createClient } from '@/lib/supabase/server'

export async function uploadFile(formData: FormData) {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Non autenticato')

  const file = formData.get('file') as File
  const buffer = Buffer.from(await file.arrayBuffer())

  // Path: utente_id/uuid.ext — garantisce isolamento tra utenti
  const filePath = `${user.id}/${crypto.randomUUID()}.${file.name.split('.').pop()}`

  const { error } = await supabase.storage
    .from('documenti')
    .upload(filePath, buffer, { contentType: file.type })

  if (error) throw error
  return { path: filePath }
}
```

### Download con URL firmato (privato)

```typescript
// URL firmato — valido per 1 ora, solo per file privati
const { data } = await supabase.storage
  .from('documenti')
  .createSignedUrl(filePath, 3600)  // secondi

return data?.signedUrl  // URL temporaneo sicuro
```

---

## MIGRATIONS — Workflow Supabase

```bash
# Installa CLI Supabase
npm install -g supabase

# Link al progetto
supabase link --project-ref [project-ref]

# Crea nuova migration
supabase migration new nome_migration
# → crea supabase/migrations/[timestamp]_nome_migration.sql

# Applica in sviluppo
supabase db push

# Genera tipi TypeScript dal DB
supabase gen types typescript --linked > src/types/database.ts

# Pull schema da produzione (per sincronizzare)
supabase db pull
```

### Struttura migration

```sql
-- supabase/migrations/20260407120000_crea_ordini.sql

-- Crea tabella
CREATE TABLE ordini (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  utente_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  importo NUMERIC(12, 2) NOT NULL,
  stato TEXT NOT NULL DEFAULT 'BOZZA',
  creato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Attiva RLS subito
ALTER TABLE ordini ENABLE ROW LEVEL SECURITY;

-- Policy di base (espandi dopo)
CREATE POLICY "owner" ON ordini FOR ALL USING (auth.uid() = utente_id);

-- Indice
CREATE INDEX ON ordini (utente_id, creato_il DESC);
```

---

## EDGE FUNCTIONS (opzionale)

Usa Edge Functions quando hai bisogno di:
- Webhook esterni (Stripe, GitHub) che non passi da Next.js
- Logica server con bassa latenza globale
- Operazioni programmate (via pg_cron)

```typescript
// supabase/functions/webhook-stripe/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const body = await req.text()
  const sig = req.headers.get('stripe-signature')!

  // Verifica webhook Stripe
  // ...elabora evento...

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

```bash
# Deploy edge function
supabase functions deploy webhook-stripe
```

---

## CHECKLIST SUPABASE

- [ ] RLS attiva su tutte le tabelle con dati utente
- [ ] Policy definite per SELECT, INSERT, UPDATE, DELETE
- [ ] `adminClient` usato solo server-side, mai esposto al client
- [ ] `SUPABASE_SERVICE_ROLE_KEY` non in variabili pubbliche (`NEXT_PUBLIC_`)
- [ ] Bucket storage privati (public: false) per documenti sensibili
- [ ] Path storage include `utente_id` come primo segmento (isolamento)
- [ ] Middleware protegge tutte le route private
- [ ] Tipi TypeScript generati da schema (`supabase gen types`)
- [ ] Migration versionate in `supabase/migrations/`
- [ ] Real-time abilitato solo dove necessario (consuma risorse)
