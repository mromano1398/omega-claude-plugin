---
name: omega-payments
description: Use when integrating payments — one-time charges, subscriptions, free trials, billing portal, webhooks, or invoicing. Covers Stripe complete setup for Next.js including webhook handler, subscription lifecycle, customer portal, and payment failure handling. Triggered by mentions of "pagamenti", "Stripe", "abbonamento", "checkout", "fattura", "billing".
user-invocable: false
---

# omega-payments — Stripe · Abbonamenti · Webhook · Portal · Fatture

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- Stripe Docs: https://stripe.com/docs
- Stripe API Reference: https://stripe.com/docs/api
- Stripe Next.js: https://stripe.com/docs/payments/quickstart

---

## SETUP

```bash
npm install stripe @stripe/stripe-js
```

```bash
# .env.local
STRIPE_SECRET_KEY=sk_test_...          # Chiave segreta (solo server)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...  # Chiave pubblica (client)
STRIPE_WEBHOOK_SECRET=whsec_...        # Per validare webhook
```

### `lib/stripe.ts` — Client singleton

```typescript
import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-01-27.acacia',
  typescript: true,
})
```

---

## PAGAMENTO UNA TANTUM — Checkout Session

```typescript
// app/api/checkout/route.ts
import { stripe } from '@/lib/stripe'
import { auth } from '@/lib/auth'
import { NextResponse } from 'next/server'

export async function POST(req: Request) {
  const session = await auth()
  if (!session?.user?.id) return NextResponse.json({ error: 'Non autenticato' }, { status: 401 })

  const { priceId, quantity = 1 } = await req.json()

  const checkoutSession = await stripe.checkout.sessions.create({
    mode: 'payment',
    payment_method_types: ['card'],
    line_items: [{ price: priceId, quantity }],
    customer_email: session.user.email!,
    metadata: {
      utente_id: session.user.id,
    },
    success_url: `${process.env.NEXTAUTH_URL}/grazie?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXTAUTH_URL}/prezzi`,
    // Dati fiscali (per fatture italiane)
    tax_id_collection: { enabled: true },
    automatic_tax: { enabled: true },
    invoice_creation: { enabled: true },
  })

  return NextResponse.json({ url: checkoutSession.url })
}
```

```typescript
// Componente React — pulsante "Acquista"
'use client'
export function BuyButton({ priceId }: { priceId: string }) {
  const [loading, setLoading] = useState(false)

  const handleClick = async () => {
    setLoading(true)
    const res = await fetch('/api/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ priceId }),
    })
    const { url } = await res.json()
    window.location.href = url
  }

  return (
    <button onClick={handleClick} disabled={loading} className="btn-primary">
      {loading ? 'Reindirizzamento...' : 'Acquista ora'}
    </button>
  )
}
```

---

## ABBONAMENTI — Subscription

### Crea abbonamento con periodo di prova

```typescript
// app/api/subscribe/route.ts
export async function POST(req: Request) {
  const session = await auth()
  if (!session?.user?.id) return NextResponse.json({ error: 'Non autenticato' }, { status: 401 })

  const { priceId } = await req.json()

  // Recupera o crea Customer Stripe
  let customerId = await getStripeCustomerId(session.user.id)
  if (!customerId) {
    const customer = await stripe.customers.create({
      email: session.user.email!,
      name: session.user.name ?? undefined,
      metadata: { utente_id: session.user.id },
    })
    customerId = customer.id
    await saveStripeCustomerId(session.user.id, customerId)
  }

  const checkoutSession = await stripe.checkout.sessions.create({
    mode: 'subscription',
    customer: customerId,
    line_items: [{ price: priceId, quantity: 1 }],
    subscription_data: {
      trial_period_days: 14,  // 14 giorni gratuiti
      metadata: { utente_id: session.user.id },
    },
    success_url: `${process.env.NEXTAUTH_URL}/dashboard?abbonamento=attivato`,
    cancel_url: `${process.env.NEXTAUTH_URL}/prezzi`,
    allow_promotion_codes: true,
  })

  return NextResponse.json({ url: checkoutSession.url })
}
```

### Schema DB abbonamenti

```sql
CREATE TABLE abbonamenti (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  utente_id UUID NOT NULL REFERENCES utenti(id),
  stripe_customer_id TEXT UNIQUE NOT NULL,
  stripe_subscription_id TEXT UNIQUE,
  piano TEXT NOT NULL DEFAULT 'FREE',  -- FREE, PRO, ENTERPRISE
  stato TEXT NOT NULL DEFAULT 'TRIAL', -- TRIAL, ACTIVE, PAST_DUE, CANCELED
  periodo_fine TIMESTAMPTZ,
  creato_il TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  aggiornato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ON abbonamenti (utente_id);
CREATE INDEX ON abbonamenti (stripe_customer_id);
```

---

## WEBHOOK HANDLER — Cuore del sistema pagamenti

Il webhook riceve tutti gli eventi Stripe e mantiene aggiornato il DB.

```typescript
// app/api/webhook/stripe/route.ts
import { stripe } from '@/lib/stripe'
import { headers } from 'next/headers'

// ⚠️ Disabilita il body parsing automatico di Next.js
export const runtime = 'nodejs'

export async function POST(req: Request) {
  const body = await req.text()
  const signature = headers().get('stripe-signature')!

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    console.error('Webhook signature non valida:', err)
    return new Response('Webhook Error', { status: 400 })
  }

  // ✅ Idempotenza: ignora eventi già processati
  const esistente = await db.query(
    'SELECT id FROM webhook_events WHERE stripe_event_id = $1',
    [event.id]
  )
  if (esistente.rows.length > 0) {
    return new Response('Already processed', { status: 200 })
  }

  // Processa l'evento
  try {
    await handleStripeEvent(event)
    await db.query(
      'INSERT INTO webhook_events (stripe_event_id, tipo, processato_il) VALUES ($1, $2, NOW())',
      [event.id, event.type]
    )
  } catch (err) {
    console.error(`Errore processing evento ${event.type}:`, err)
    return new Response('Processing Error', { status: 500 })
  }

  return new Response('OK', { status: 200 })
}

async function handleStripeEvent(event: Stripe.Event) {
  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object as Stripe.Checkout.Session
      if (session.mode === 'subscription') {
        await attivaAbbonamento(session)
      } else {
        await registraAcquisto(session)
      }
      break
    }

    case 'customer.subscription.updated': {
      const subscription = event.data.object as Stripe.Subscription
      await aggiornaAbbonamento(subscription)
      break
    }

    case 'customer.subscription.deleted': {
      const subscription = event.data.object as Stripe.Subscription
      await cancellaAbbonamento(subscription)
      break
    }

    case 'invoice.payment_failed': {
      const invoice = event.data.object as Stripe.Invoice
      await gestisciPagamentoFallito(invoice)
      break
    }

    case 'invoice.paid': {
      const invoice = event.data.object as Stripe.Invoice
      await rinnova(invoice)
      break
    }
  }
}

async function attivaAbbonamento(session: Stripe.Checkout.Session) {
  const utenteId = session.metadata?.utente_id
  if (!utenteId) throw new Error('utente_id mancante nei metadata')

  await db.query(
    `INSERT INTO abbonamenti (utente_id, stripe_customer_id, stripe_subscription_id, piano, stato, periodo_fine)
     VALUES ($1, $2, $3, 'PRO', 'ACTIVE', NOW() + INTERVAL '1 month')
     ON CONFLICT (stripe_customer_id) DO UPDATE
     SET stripe_subscription_id = $3, piano = 'PRO', stato = 'ACTIVE'`,
    [utenteId, session.customer, session.subscription]
  )
}

async function gestisciPagamentoFallito(invoice: Stripe.Invoice) {
  await db.query(
    `UPDATE abbonamenti SET stato = 'PAST_DUE' WHERE stripe_customer_id = $1`,
    [invoice.customer]
  )
  // Invia email all'utente
  await sendEmail({
    to: invoice.customer_email!,
    subject: 'Problema con il tuo pagamento',
    template: 'payment-failed',
    data: { link: invoice.hosted_invoice_url },
  })
}
```

### Schema webhook_events (idempotenza)

```sql
CREATE TABLE webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_event_id TEXT UNIQUE NOT NULL,
  tipo TEXT NOT NULL,
  processato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX ON webhook_events (stripe_event_id);
```

---

## CUSTOMER PORTAL — Gestione abbonamento self-service

Permette agli utenti di cambiare piano, aggiornare carta, scaricare fatture senza contattarti.

```typescript
// app/api/billing-portal/route.ts
export async function POST() {
  const session = await auth()
  if (!session?.user?.id) return NextResponse.json({ error: 'Non autenticato' }, { status: 401 })

  const abbonamento = await db.query(
    'SELECT stripe_customer_id FROM abbonamenti WHERE utente_id = $1',
    [session.user.id]
  )

  if (!abbonamento.rows[0]) {
    return NextResponse.json({ error: 'Nessun abbonamento trovato' }, { status: 404 })
  }

  const portalSession = await stripe.billingPortal.sessions.create({
    customer: abbonamento.rows[0].stripe_customer_id,
    return_url: `${process.env.NEXTAUTH_URL}/impostazioni`,
  })

  return NextResponse.json({ url: portalSession.url })
}
```

```typescript
// Pulsante "Gestisci abbonamento"
export function ManageBillingButton() {
  const redirect = async () => {
    const res = await fetch('/api/billing-portal', { method: 'POST' })
    const { url } = await res.json()
    window.location.href = url
  }
  return <button onClick={redirect}>Gestisci abbonamento</button>
}
```

---

## PROTEZIONE ROUTE PER PIANO

```typescript
// lib/subscription.ts
export async function getSubscriptionPlan(userId: string) {
  const { rows } = await db.query(
    `SELECT piano, stato, periodo_fine FROM abbonamenti
     WHERE utente_id = $1
     AND (stato = 'ACTIVE' OR stato = 'TRIAL')
     AND (periodo_fine IS NULL OR periodo_fine > NOW())`,
    [userId]
  )
  return rows[0]?.piano ?? 'FREE'
}

// In Server Component / Server Action
export async function checkPianoPro() {
  const session = await auth()
  if (!session?.user?.id) redirect('/login')

  const piano = await getSubscriptionPlan(session.user.id)
  if (piano === 'FREE') redirect('/prezzi?upgrade=true')

  return piano
}
```

---

## TEST IN SVILUPPO

```bash
# Installa Stripe CLI
# https://stripe.com/docs/stripe-cli

# Forwarda webhook al server locale
stripe listen --forward-to localhost:3000/api/webhook/stripe

# Testa eventi specifici
stripe trigger checkout.session.completed
stripe trigger customer.subscription.deleted
stripe trigger invoice.payment_failed

# Carte di test
# 4242424242424242 → pagamento riuscito
# 4000000000000002 → carta rifiutata
# 4000002500003155 → richiede 3D Secure
# 4000000000009995 → fondi insufficienti
```

---

## FATTURE ITALIANE + IVA

```typescript
// Abilita raccolta dati fiscali nel checkout
const checkoutSession = await stripe.checkout.sessions.create({
  // ...
  tax_id_collection: { enabled: true },
  automatic_tax: { enabled: true },
  invoice_creation: {
    enabled: true,
    invoice_data: {
      // Numero di sequenza per fatture italiane (opzionale)
      rendering_options: { amount_tax_display: 'include_inclusive_tax' }
    }
  },
  // Indirizzo di fatturazione obbligatorio per IVA
  billing_address_collection: 'required',
})
```

---

## CHECKLIST PAGAMENTI

- [ ] Chiavi test vs produzione separate in env (mai chiavi prod in sviluppo)
- [ ] Webhook endpoint configurato su Stripe Dashboard
- [ ] `STRIPE_WEBHOOK_SECRET` aggiunto all'env
- [ ] Idempotenza webhook (tabella `webhook_events`)
- [ ] Gestione `invoice.payment_failed` con email all'utente
- [ ] Customer Portal configurato
- [ ] Schema DB abbonamenti con `stato` e `periodo_fine`
- [ ] Protezione route per piano (FREE non vede funzionalità PRO)
- [ ] Test con Stripe CLI prima del deploy
- [ ] Transizione da test a produzione: aggiorna chiavi env in produzione
- [ ] Automatic tax abilitato (IVA automatica per paese utente)
