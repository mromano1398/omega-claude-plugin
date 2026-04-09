# SEO — Guida per Tipo Progetto

## Meta Tags Base (tutti i tipi)

```tsx
// app/layout.tsx o app/[slug]/page.tsx
export const metadata: Metadata = {
  title: 'Titolo pagina',                    // < 60 caratteri
  description: 'Descrizione concisa...',     // < 160 caratteri
  openGraph: {
    title: 'Titolo OG',
    description: 'Descrizione OG',
    images: [{ url: '/og-image.jpg', width: 1200, height: 630 }],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Titolo Twitter',
    description: 'Descrizione Twitter',
    images: ['/og-image.jpg'],
  },
  alternates: {
    canonical: 'https://miosito.it/pagina',
  },
}
```

## Metadata Dinamico

```tsx
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const prodotto = await getProdotto(params.slug)
  return {
    title: `${prodotto.nome} — MyShop`,
    description: prodotto.descrizione.slice(0, 155),
    openGraph: {
      images: [prodotto.immagine_url],
    },
  }
}
```

## Sitemap (Next.js automatico)

```tsx
// app/sitemap.ts
import { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const prodotti = await getProdotti()
  return [
    { url: 'https://miosito.it', lastModified: new Date(), changeFrequency: 'weekly', priority: 1 },
    { url: 'https://miosito.it/prodotti', lastModified: new Date(), changeFrequency: 'daily', priority: 0.8 },
    ...prodotti.map(p => ({
      url: `https://miosito.it/prodotti/${p.slug}`,
      lastModified: p.aggiornato_il,
      changeFrequency: 'weekly' as const,
      priority: 0.6,
    })),
  ]
}
```

## Robots.txt

```tsx
// app/robots.ts
export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: '*', allow: '/', disallow: ['/api/', '/admin/'] },
    sitemap: 'https://miosito.it/sitemap.xml',
  }
}
```

## Structured Data (JSON-LD)

```tsx
// Landing page / prodotto
function JsonLd({ data }: { data: object }) {
  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }} />
}

// Prodotto e-commerce
const prodottoSchema = {
  '@context': 'https://schema.org',
  '@type': 'Product',
  name: prodotto.nome,
  description: prodotto.descrizione,
  image: prodotto.immagine_url,
  offers: { '@type': 'Offer', price: prodotto.prezzo, priceCurrency: 'EUR' },
}

// Organizzazione (homepage)
const orgSchema = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Nome Azienda',
  url: 'https://miosito.it',
  logo: 'https://miosito.it/logo.png',
}
```

## Redirect 301 (URL vecchi)

```tsx
// next.config.ts
redirects: async () => [
  { source: '/vecchio-path/:slug', destination: '/nuovo-path/:slug', permanent: true },
  { source: '/prodotti.html', destination: '/prodotti', permanent: true },
],
```

## Core Web Vitals Target SEO

| Metrica | Target Google | Metodo miglioramento |
|---|---|---|
| LCP | < 2.5s | `priority` su hero image, font preload |
| FID / INP | < 100ms | Riduci JavaScript main thread |
| CLS | < 0.1 | Dimensioni esplicite su immagini/video |

## SEO per Tipo Progetto

**Landing page:**
- Keyword nella H1, titolo, descrizione
- JSON-LD Organization o LocalBusiness
- OG image personalizzata 1200x630
- Velocità: Performance ≥ 90

**E-commerce:**
- JSON-LD Product per ogni prodotto
- Breadcrumb schema
- Canonical su prodotti con varianti
- Sitemap separata per prodotti

**Blog:**
- JSON-LD Article con datePublished/dateModified
- Author markup
- Sitemap news se frequenza alta

**SaaS (marketing site):**
- JSON-LD SoftwareApplication
- FAQ schema per pricing/features
- Hreflang se multi-lingua

**Gestionale (interno):**
- `noindex` su tutto → robots.ts con `disallow: '/'`

## Canonical URL

Sempre impostato per evitare duplicate content:
```tsx
alternates: { canonical: `https://miosito.it${pathname}` }
```
