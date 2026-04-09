# Blueprint: E-commerce

## Struttura Cartelle
```
src/
├── app/
│   ├── (shop)/
│   │   ├── page.tsx             # Homepage / catalogo
│   │   ├── prodotti/
│   │   │   ├── page.tsx         # Lista prodotti con filtri
│   │   │   └── [slug]/page.tsx  # Pagina prodotto
│   │   ├── categorie/
│   │   │   └── [slug]/page.tsx
│   │   ├── carrello/page.tsx
│   │   ├── checkout/
│   │   │   ├── page.tsx         # Form dati + pagamento
│   │   │   └── success/page.tsx
│   │   └── account/
│   │       ├── ordini/page.tsx
│   │       └── [ordineId]/page.tsx
│   └── api/
│       ├── checkout/route.ts
│       └── webhooks/stripe/route.ts
├── modules/
│   ├── prodotti/
│   │   ├── types.ts
│   │   ├── queries.ts
│   │   └── search.ts
│   ├── carrello/
│   │   └── context.tsx          # Cart context
│   └── ordini/
│       ├── types.ts
│       ├── queries.ts
│       └── actions.ts
└── lib/
    ├── stripe.ts
    ├── inventory.ts             # Advisory lock stock
    └── email.ts                 # Resend per email conferma
```

## Cart Context (React Context + localStorage)
```tsx
// modules/carrello/context.tsx
interface CartItem { productId: string; slug: string; name: string; price: number; qty: number; image: string }
interface CartContext { items: CartItem[]; add: (item) => void; remove: (id) => void; total: number }

export const CartContext = createContext<CartContext>(...)
export function CartProvider({ children }) {
  const [items, setItems] = useLocalStorage<CartItem[]>('cart', [])
  // add/remove/update/clear logic
  return <CartContext.Provider value={{ items, add, remove, total }}>{children}</CartContext.Provider>
}
```

## Prezzi Server-Side (CRITICO)
```ts
// MAI fidarsi del prezzo inviato dal client
// SEMPRE recuperare il prezzo dal DB sul server al momento del checkout

export async function createCheckout(productIds: string[]) {
  // 1. Recupera prezzi dal DB (fonte di verità)
  const products = await db.query(
    'SELECT id, price, name FROM products WHERE id = ANY($1) AND active = true',
    [productIds]
  )
  // 2. Crea sessione Stripe con prezzi server-side
  const lineItems = products.rows.map(p => ({
    price_data: { currency: 'eur', product_data: { name: p.name }, unit_amount: p.price },
    quantity: 1
  }))
  return stripe.checkout.sessions.create({ mode: 'payment', line_items: lineItems, ... })
}
```

## Inventory Lock (Advisory Lock)
```ts
// Previene overselling in acquisti concorrenti
export async function purchaseWithLock(db: Pool, productId: string, qty: number) {
  await db.query('SELECT pg_advisory_xact_lock($1)', [hashId(productId)])
  const { rows } = await db.query('SELECT stock FROM products WHERE id = $1 FOR UPDATE', [productId])
  if (rows[0].stock < qty) throw new Error('Insufficient stock')
  await db.query('UPDATE products SET stock = stock - $1 WHERE id = $2', [qty, productId])
}
```

## Schema DB Base
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR UNIQUE NOT NULL,
  name VARCHAR NOT NULL,
  description TEXT,
  price INTEGER NOT NULL,         -- centesimi (es. 1990 = €19.90)
  stock INTEGER NOT NULL DEFAULT 0,
  category_id UUID,
  images JSONB DEFAULT '[]',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  stripe_payment_intent_id VARCHAR UNIQUE,
  status VARCHAR NOT NULL DEFAULT 'pending', -- pending/paid/shipped/delivered/refunded
  total INTEGER NOT NULL,
  items JSONB NOT NULL,
  shipping_address JSONB,
  email VARCHAR NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Email Conferma (Resend)
```ts
// lib/email.ts
import { Resend } from 'resend'
const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendOrderConfirmation(order: Order) {
  await resend.emails.send({
    from: 'ordini@tuodominio.com',
    to: order.email,
    subject: `Ordine #${order.id.slice(0,8)} confermato`,
    react: <OrderConfirmationEmail order={order} />
  })
}
```

## GDPR e Cookie Consent
- Banner cookie al primo accesso (es. `react-cookie-consent`)
- Dati obbligatori conservati: ordini, fatture (7 anni per legge italiana)
- Dati opzionali (analytics): solo con consenso esplicito
- Privacy policy + Cookie policy obbligatorie

## Componenti Specifici
- `ProductCard`: immagine + nome + prezzo + add-to-cart
- `CartDrawer`: sidebar carrello con slide-over (Tier 2+)
- `CheckoutSteps`: stepper visivo (carrello → dati → pagamento → conferma)
- `OrderStatus`: timeline stato ordine con icone
- `SearchBar`: ricerca prodotti con autocomplete
- `FilterSidebar`: filtri per categoria, prezzo, disponibilità
