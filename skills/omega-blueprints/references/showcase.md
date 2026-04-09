# Blueprint: Showcase / Portfolio

## Struttura Cartelle
```
src/
├── app/
│   ├── page.tsx                 # Homepage / gallery principale
│   ├── progetti/
│   │   ├── page.tsx             # Tutti i progetti
│   │   └── [slug]/page.tsx      # Case study singolo
│   ├── about/page.tsx
│   ├── blog/                    # Opzionale
│   │   ├── page.tsx
│   │   └── [slug]/page.tsx
│   └── contatti/page.tsx
├── components/
│   ├── gallery/
│   │   ├── GalleryGrid.tsx
│   │   ├── ProjectCard.tsx
│   │   └── Lightbox.tsx
│   ├── filters/
│   │   └── FilterTabs.tsx
│   └── sections/
│       ├── HeroSection.tsx
│       ├── AboutSection.tsx
│       └── ContactSection.tsx
├── content/                     # MDX o JSON per contenuti
│   └── projects/
│       └── [slug].mdx
└── lib/
    ├── projects.ts              # Helper per leggere contenuti
    └── email.ts
```

## Fonte Dati

**Opzione A: File system (semplice)**
```ts
// lib/projects.ts
import fs from 'fs'
import path from 'path'
import matter from 'gray-matter'

export function getAllProjects(): Project[] {
  const dir = path.join(process.cwd(), 'content/projects')
  return fs.readdirSync(dir)
    .map(file => {
      const content = fs.readFileSync(path.join(dir, file), 'utf-8')
      const { data } = matter(content)
      return { ...data, slug: file.replace('.mdx', '') } as Project
    })
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
}
```

**Opzione B: CMS headless** (Sanity, Contentful, Notion API)
- Usa per clienti che devono aggiornare autonomamente

## Ottimizzazione Immagini
```tsx
// SEMPRE next/image per gallerie
<Image
  src={project.coverImage}
  alt={project.title}
  width={800}
  height={600}
  loading="lazy"           // lazy su tutte eccetto above-fold
  placeholder="blur"       // blur-up effect
  blurDataURL={project.blurDataUrl}
  className="object-cover"
/>
```
- Formato: WebP obbligatorio (next/image lo gestisce automaticamente)
- Dimensioni multiple: `sizes` prop per responsive images
- CDN: Cloudinary o Vercel Blob per storage

## Gallery e Lightbox
```tsx
// GalleryGrid.tsx — masonry o grid uniforme
<div className="columns-1 sm:columns-2 lg:columns-3 gap-4">
  {projects.map(p => <ProjectCard key={p.slug} project={p} onClick={() => openLightbox(p)} />)}
</div>

// Lightbox: usa 'yet-another-react-lightbox' o custom con framer-motion
```

## Filtri per Categoria
```tsx
// FilterTabs.tsx
const categories = ['Tutti', 'Web', 'Mobile', 'Branding', '3D']
const [active, setActive] = useState('Tutti')
const filtered = active === 'Tutti' ? projects : projects.filter(p => p.category === active)
```

## Animazioni (Tier 3-4)
Per portfolio sviluppatore o agenzia creativa: usa Tier 3 (GSAP) o Tier 4 (Three.js) come definito in omega-tier-system.

**Pattern specifici per showcase:**
- Stagger sulle cards della gallery (GSAP fromTo con stagger: 0.1)
- Transizione pagina progetto → case study (Framer o GSAP)
- Cursor custom (opzionale, non esagerare)
- Immagini con parallax leggero su scroll

## Auth Minima (opzionale)
Se il portfolio ha una sezione admin per aggiornare i contenuti:
```
/admin (protetta da password semplice o NextAuth GitHub)
/admin/progetti/nuovo
/admin/progetti/[slug]/edit
```
Non serve un sistema auth complesso per un portfolio personale.

## SEO per Portfolio
- Ogni progetto ha meta description unica
- Schema.org markup per portfolio (CreativeWork)
- Social sharing: og:image per ogni progetto
- Sitemap include tutte le pagine progetto

## Componenti
- `GalleryGrid`: layout masonry o grid con lazy loading
- `ProjectCard`: immagine + categoria + titolo + hover overlay
- `Lightbox`: visualizzatore fullscreen con navigazione
- `FilterTabs`: filtro per categoria con animazione
- `AboutSection`: bio + skills + foto
- `ContactSection`: form o link email/social
