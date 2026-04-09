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

## QUANDO USARE

- Integrazione pagamenti Stripe (una tantum o abbonamenti)
- Setup webhook handler per ciclo vita abbonamento
- Customer portal self-service
- Protezione route per piano (FREE/PRO/ENTERPRISE)
- Fatturazione italiana con IVA automatica

## FLUSSO DECISIONALE

```
Pagamento una tantum → Checkout Session mode='payment'
Abbonamento         → Checkout Session mode='subscription' + trial_period_days
Upgrade/downgrade   → Customer Portal (Stripe gestisce tutto)
Verifica piano      → getSubscriptionPlan(userId) in ogni Server Action protetta

Webhook obbligatori da implementare:
checkout.session.completed → attiva abbonamento
customer.subscription.updated → aggiorna piano
customer.subscription.deleted → cancella abbonamento
invoice.payment_failed → stato PAST_DUE + email utente
invoice.paid → aggiorna periodo_fine
```

## REGOLE CHIAVE

1. **Chiavi test vs produzione separate** in env — mai chiavi prod in sviluppo
2. **Webhook endpoint configurato** su Stripe Dashboard prima del deploy
3. **`STRIPE_WEBHOOK_SECRET`** obbligatorio per validare firma webhook
4. **Idempotenza webhook** — tabella `webhook_events` per evitare doppio processing
5. **`utente_id` nei metadata** del checkout — necessario per associare il pagamento
6. **Implementa tutti e 5 gli eventi webhook** — non solo `checkout.session.completed`
7. **Customer Portal** per gestione self-service — non costruirlo da zero
8. **`automatic_tax: true`** per IVA automatica per paese utente
9. **Test con Stripe CLI** prima del deploy in produzione
10. **`stato: PAST_DUE`** su `invoice.payment_failed` + email immediata all'utente

## CHECKLIST SINTETICA

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

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/stripe.md] — setup, checkout una tantum, abbonamenti, customer portal, protezione route, fatture IVA, test con Stripe CLI
- [references/webhooks.md] — webhook handler completo con idempotenza, tutti gli eventi, schema webhook_events, ciclo vita abbonamento
