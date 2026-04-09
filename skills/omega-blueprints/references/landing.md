# Blueprint: Landing Page

## Struttura Cartelle
```
src/
├── app/
│   ├── page.tsx                 # Homepage principale
│   ├── chi-siamo/page.tsx
│   ├── servizi/page.tsx
│   ├── pricing/page.tsx
│   ├── contatti/page.tsx
│   ├── sitemap.xml/route.ts     # Sitemap generata
│   └── robots.txt/route.ts
├── components/
│   ├── sections/
│   │   ├── Hero.tsx
│   │   ├── Features.tsx
│   │   ├── Testimonials.tsx
│   │   ├── Pricing.tsx
│   │   ├── FAQ.tsx
│   │   └── Footer.tsx
│   ├── ui/                      # shadcn base
│   └── ContactForm.tsx
└── lib/
    └── email.ts                 # Resend per form contatti
```

## Stack Consigliato
- **Next.js** (App Router, static export dove possibile) — SEO ottimale
- **Alternativa**: Astro per siti puramente statici (più veloce, zero JS default)
- Zero auth, zero DB complesso
- Form: Resend + react-hook-form + Zod

## SEO (OBBLIGATORIO)
```tsx
// app/layout.tsx
export const metadata: Metadata = {
  title: { default: 'Nome Azienda', template: '%s | Nome Azienda' },
  description: 'Descrizione SEO ottimizzata (150-160 caratteri)',
  openGraph: {
    type: 'website',
    locale: 'it_IT',
    url: 'https://dominio.com',
    siteName: 'Nome Azienda',
    images: [{ url: '/og-image.jpg', width: 1200, height: 630 }]
  },
  twitter: { card: 'summary_large_image' }
}
```

**Sitemap dinamica:**
```ts
// app/sitemap.xml/route.ts
export function GET() {
  const pages = ['/', '/chi-siamo', '/servizi', '/pricing', '/contatti']
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${pages.map(p => `<url><loc>https://dominio.com${p}</loc><changefreq>monthly</changefreq></url>`).join('')}
</urlset>`
  return new Response(sitemap, { headers: { 'Content-Type': 'application/xml' } })
}
```

## Lighthouse >= 90 (OBBLIGATORIO)

**Performance:**
- Immagini: `next/image` con `priority` su above-fold, `loading="lazy"` sulle altre
- Font: `next/font` con `display: swap`
- NO layout shift (CLS < 0.1): dimensioni immagini sempre specificate
- Bundle: analizza con `@next/bundle-analyzer`

**Core Web Vitals target:**
- LCP < 2.5s (immagine hero ottimizzata, CDN)
- FID/INP < 100ms (idratazione minima)
- CLS < 0.1 (skeleton/placeholder per elementi dinamici)

## Form Contatti (Resend)
```tsx
// ContactForm.tsx
const schema = z.object({
  nome: z.string().min(2),
  email: z.string().email(),
  messaggio: z.string().min(10).max(500)
})

async function onSubmit(data: FormData) {
  await fetch('/api/contact', { method: 'POST', body: JSON.stringify(data) })
}
// Rate limit: max 3 invii per IP per ora (upstash)
```

## Componenti Obbligatori
- `Hero`: headline + subheadline + CTA primario + CTA secondario + immagine/video
- `Features`: 3-6 feature con icone Lucide + descrizione
- `Testimonials`: carousel o grid con quote + nome + foto/avatar
- `Pricing`: tabella piani con feature comparison + CTA per ogni piano
- `FAQ`: accordion (shadcn Accordion) con domande frequenti
- `Footer`: logo + link + social + copyright + privacy/cookie policy
- `ContactForm`: con validazione Zod + honeypot anti-spam + rate limiting

## Analytics
- Google Analytics 4 o Plausible (privacy-first)
- Installa SOLO dopo cookie consent
- Google Search Console: verifica dominio

## Deployment
- Vercel (preferito per Next.js)
- CDN per assets statici
- Edge config per A/B testing (opzionale)
