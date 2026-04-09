# Blueprint: SaaS B2C

## Struttura Cartelle
```
src/
├── app/
│   ├── (marketing)/             # Pagine pubbliche
│   │   ├── page.tsx             # Landing
│   │   ├── pricing/page.tsx
│   │   └── layout.tsx
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── signup/page.tsx
│   │   └── onboarding/page.tsx  # Wizard post-signup
│   ├── (app)/                   # Area applicazione
│   │   ├── layout.tsx
│   │   ├── dashboard/page.tsx
│   │   └── settings/
│   │       ├── profile/page.tsx
│   │       ├── billing/page.tsx
│   │       └── team/page.tsx
│   └── api/
│       ├── auth/route.ts
│       └── webhooks/stripe/route.ts
├── modules/
│   ├── organizations/
│   │   ├── types.ts
│   │   ├── queries.ts
│   │   └── actions.ts
│   └── subscriptions/
│       ├── types.ts
│       ├── queries.ts
│       └── stripe.ts
└── lib/
    ├── auth.ts
    ├── db.ts
    ├── stripe.ts
    ├── tenant.ts                # Tenant detection middleware
    └── feature-gates.ts        # Plan-based features
```

## Multi-Tenant

**Opzione A: Row Level Security (PostgreSQL)**
```sql
-- Ogni tabella ha organization_id
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY projects_isolation ON projects
  USING (organization_id = current_setting('app.organization_id')::uuid);
-- Nel middleware: SET LOCAL app.organization_id = 'xxx'
```

**Opzione B: Schema per tenant** (per isolamento totale)
```sql
-- Ogni tenant ha il proprio schema
CREATE SCHEMA tenant_[org_id];
-- Più complesso da gestire, usa solo se richiesto per compliance
```

## Schema DB
```sql
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  slug VARCHAR UNIQUE NOT NULL,
  plan VARCHAR NOT NULL DEFAULT 'free', -- free/pro/enterprise
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  role VARCHAR NOT NULL DEFAULT 'member', -- owner/admin/member
  UNIQUE(user_id, organization_id)
);

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  stripe_subscription_id VARCHAR UNIQUE,
  stripe_customer_id VARCHAR,
  status VARCHAR NOT NULL, -- active/trialing/canceled/past_due
  plan VARCHAR NOT NULL,
  current_period_end TIMESTAMPTZ,
  trial_end TIMESTAMPTZ
);
```

## Onboarding Flow (wizard post-signup)
```
1. Benvenuto + spiega valore
2. Nome workspace / organizzazione
3. Invita teammates (opzionale, skip disponibile)
4. Configura preferenze base
5. → Dashboard con tutorial overlay
```
Usa step URL: `/onboarding?step=1`, `/onboarding?step=2`, ecc.

## Stripe Integration
```ts
// lib/stripe.ts
import Stripe from 'stripe'
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

// Checkout
export async function createCheckoutSession(orgId: string, plan: string) {
  return stripe.checkout.sessions.create({
    mode: 'subscription',
    payment_method_types: ['card'],
    line_items: [{ price: PRICE_IDS[plan], quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_URL}/settings/billing?success=1`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing`,
    metadata: { organizationId: orgId }
  })
}
```

**Webhook handler obbligatorio** (`/api/webhooks/stripe`):
- `checkout.session.completed` → attiva subscription
- `invoice.payment_succeeded` → rinnovo ok
- `invoice.payment_failed` → notifica utente
- `customer.subscription.deleted` → downgrade a free

## Feature Gates
```ts
// lib/feature-gates.ts
const PLAN_FEATURES = {
  free: { maxProjects: 3, maxTeamMembers: 1, hasApiAccess: false },
  pro: { maxProjects: 50, maxTeamMembers: 10, hasApiAccess: true },
  enterprise: { maxProjects: Infinity, maxTeamMembers: Infinity, hasApiAccess: true }
}

export function canUseFeature(plan: string, feature: keyof PlanFeatures): boolean {
  return !!PLAN_FEATURES[plan]?.[feature]
}
```

## Trial Management
- Trial: 14 giorni di default
- Mostra banner "X giorni rimanenti" nell'app
- Email reminder: a 7gg, 3gg, 1gg dalla scadenza
- Dopo scadenza: read-only mode, non bloccare accesso ai dati

## Componenti Specifici
- `PricingTable`: confronto piani con feature matrix
- `UpgradeModal`: triggered quando utente supera limite piano
- `UsageMeter`: barra progressione utilizzo (es. 3/50 progetti)
- `OnboardingWizard`: step-by-step post-signup
- `TeamInvite`: form invito + lista pending invitations
- `BillingPortal`: link a Stripe Customer Portal
