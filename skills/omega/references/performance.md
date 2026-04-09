# Performance — Guida Operativa

## Next.js — Immagini

```tsx
// CORRETTO: sempre sizes + priority per above-the-fold
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={630}
  priority                          // solo above-the-fold
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>

// SBAGLIATO: mai senza sizes su immagini responsive
<Image src="/img.jpg" alt="" fill />  // manca sizes
```

Regole:
- `priority` solo sulla prima immagine above-the-fold
- `sizes` sempre su immagini che cambiano dimensione con viewport
- Formato: preferisci WebP/AVIF (Next.js converte automaticamente)
- Placeholder: `placeholder="blur"` + `blurDataURL` per LCP migliorato

## Next.js — Font

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'
const inter = Inter({
  subsets: ['latin'],
  display: 'swap',           // evita FOIT
  variable: '--font-inter',  // CSS variable per Tailwind
})
```

Mai usare `<link>` Google Fonts diretto — usa sempre `next/font`.

## Bundle Analyzer

```bash
npm install --save-dev @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({ enabled: process.env.ANALYZE === 'true' })
module.exports = withBundleAnalyzer({})
```

```bash
ANALYZE=true npm run build
```

Target: nessun chunk > 250KB gzipped.

## Lazy Loading

```tsx
// Componenti pesanti (editor, charts, mappe)
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <Skeleton className="h-64" />,
  ssr: false,  // solo se usa browser APIs
})
```

## Caching Next.js (v16+ con Cache Components)

Abilita in `next.config.ts`:
```ts
const nextConfig: NextConfig = { cacheComponents: true }
```

**`use cache` — componenti/funzioni cached:**
```tsx
import { cacheLife, cacheTag } from 'next/cache'

async function ProdottiCached() {
  'use cache'
  cacheLife('hours')        // profili: 'minutes' | 'hours' | 'days' | 'weeks' | 'max'
  cacheTag('prodotti')
  const data = await db.prodotti.findMany()
  return <ProdottiList items={data} />
}
```

**Invalidazione cache:**
```typescript
import { revalidateTag, updateTag } from 'next/cache'

// Background (prossima request vede dati freschi)
revalidateTag('prodotti')

// Immediato (stessa request vede dati freschi)
updateTag('prodotti')
```

**Contenuto dinamico — wrap in Suspense:**
```tsx
<Suspense fallback={<Skeleton />}>
  <ComponenteDinamico />   {/* accede a cookies/headers */}
</Suspense>
```

**Regola:** non usare `cookies()` / `headers()` dentro `use cache` — passali come props o usa `'use cache: private'`.

**Migrazione da `unstable_cache`:** sostituisci con funzione + `'use cache'` + `cacheTag()` + `cacheLife()`. Non servono più `keyParts` manuali.

## DB Query Optimization

**Prevenzione N+1:**
```typescript
// SBAGLIATO — N+1
const ordini = await db.ordini.findMany()
for (const o of ordini) {
  o.cliente = await db.clienti.findById(o.cliente_id)  // N query!
}

// CORRETTO — JOIN
const ordini = await db.query(`
  SELECT o.*, c.nome as cliente_nome
  FROM ordini o JOIN clienti c ON c.id = o.cliente_id
  WHERE o.stato = $1
`, ['attivo'])
```

**Index hints:**
```sql
-- Verifica uso index
EXPLAIN ANALYZE SELECT * FROM movimenti WHERE articolo_id = 1 AND sede_id = 2;

-- Index composto per query frequenti
CREATE INDEX idx_movimenti_articolo_sede ON movimenti(articolo_id, sede_id);
CREATE INDEX idx_movimenti_data ON movimenti(data_movimento DESC);
```

**Connection pooling:** usa `max: 10` in Pool pg. Mai creare nuova connessione per ogni request.

## Lighthouse Score Target

| Metrica | Target | Critico |
|---|---|---|
| Performance | ≥ 90 | < 70 |
| Accessibility | ≥ 90 | < 80 |
| SEO | ≥ 90 | < 80 |
| Best Practices | ≥ 90 | < 80 |

**Core Web Vitals:**
- LCP (Largest Contentful Paint): < 2.5s
- FID / INP (Interaction): < 100ms
- CLS (Layout Shift): < 0.1

**Quick wins LCP:**
1. `priority` sulla hero image
2. Font preload con `next/font`
3. Elimina JavaScript bloccante above-the-fold
4. Usa CDN per asset statici
