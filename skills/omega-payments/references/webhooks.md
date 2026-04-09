# Webhooks — Handler Stripe Completo

## Webhook Handler — Cuore del sistema pagamenti

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

## Schema webhook_events (idempotenza)

```sql
CREATE TABLE webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_event_id TEXT UNIQUE NOT NULL,
  tipo TEXT NOT NULL,
  processato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX ON webhook_events (stripe_event_id);
```

## Ciclo di vita eventi abbonamento

| Evento | Quando | Azione da fare |
|---|---|---|
| `checkout.session.completed` | Pagamento riuscito (subscription o one-time) | Attiva abbonamento / registra acquisto |
| `customer.subscription.updated` | Piano cambiato, rinnovo | Aggiorna piano e stato nel DB |
| `customer.subscription.deleted` | Disdetta | Imposta stato CANCELED |
| `invoice.payment_failed` | Pagamento rinnovo fallito | Imposta PAST_DUE, invia email |
| `invoice.paid` | Rinnovo riuscito | Aggiorna periodo_fine |

**Regola:** Implementa TUTTI questi eventi — non solo `checkout.session.completed`.

### Schema tabella `webhook_events` (idempotenza)

```sql
CREATE TABLE webhook_events (
  id          SERIAL PRIMARY KEY,
  stripe_id   TEXT UNIQUE NOT NULL,   -- es. "evt_1234abc"
  tipo        TEXT NOT NULL,           -- es. "invoice.payment_succeeded"
  processato  BOOLEAN DEFAULT FALSE,
  payload     JSONB NOT NULL,
  errore      TEXT,                    -- null se successo
  tentativi   INT DEFAULT 0,
  creato_il   TIMESTAMPTZ DEFAULT NOW(),
  processato_il TIMESTAMPTZ
);
CREATE INDEX ON webhook_events (stripe_id);
CREATE INDEX ON webhook_events (processato, creato_il DESC);
```

### Retry logic per webhook falliti

```typescript
// lib/webhook-retry.ts
// Eseguito da un cron job ogni 5 minuti (Inngest, Trigger.dev, o cron Vercel)
export async function retryFailedWebhooks() {
  const { rows } = await query(`
    SELECT id, stripe_id, tipo, payload, tentativi
    FROM webhook_events
    WHERE processato = FALSE
      AND tentativi < 5
      AND creato_il > NOW() - INTERVAL '24 hours'
    ORDER BY creato_il ASC
    LIMIT 10
  `)

  for (const event of rows) {
    try {
      await processWebhookEvent(event.tipo, event.payload)
      await query(
        `UPDATE webhook_events
         SET processato = TRUE, processato_il = NOW(), tentativi = tentativi + 1
         WHERE id = $1`,
        [event.id]
      )
    } catch (err) {
      await query(
        `UPDATE webhook_events
         SET tentativi = tentativi + 1, errore = $2
         WHERE id = $1`,
        [event.id, String(err)]
      )
      // Dopo 5 tentativi falliti → alert su Sentry
      if (event.tentativi + 1 >= 5) {
        Sentry.captureException(new Error(`Webhook ${event.stripe_id} fallito 5 volte`))
      }
    }
  }
}
```
