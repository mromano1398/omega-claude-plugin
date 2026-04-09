# Anti-Slop Checklist — Esempi Concreti

## AREA 1: FONT

### Pattern SLOP da cercare nel codice:
```tsx
// SLOP: font non configurato
<body className="font-sans">  // usa Inter di Tailwind, non personalizzato

// SLOP: font caricato con <link> HTML invece di next/font
<link href="https://fonts.googleapis.com/css2?family=Inter" rel="stylesheet" />

// SLOP: nessuna variabile font nel tailwind config
// tailwind.config.ts senza fontFamily customizzato
```

### Fix:
```tsx
// OK: next/font con variable CSS
import { Inter, Space_Grotesk } from 'next/font/google'
const inter = Inter({ subsets: ['latin'], variable: '--font-body' })
const display = Space_Grotesk({ subsets: ['latin'], variable: '--font-display' })
<body className={`${inter.variable} ${display.variable} font-body`}>

// tailwind.config.ts
fontFamily: {
  body: ['var(--font-body)', 'system-ui', 'sans-serif'],
  display: ['var(--font-display)', 'system-ui', 'sans-serif'],
}
```

### Indicatori di design UNICO:
- Font display diverso dal body (Tier 3-4)
- Fluid typography con `clamp()` per heading
- Font weight usati: almeno 400, 500, 600, 700

---

## AREA 2: COLORI

### Pattern SLOP da cercare nel codice:
```tsx
// SLOP: colori Tailwind hardcoded direttamente
<button className="bg-blue-600 hover:bg-blue-700 text-white">
<p className="text-gray-500">
<div className="border-gray-200">

// SLOP: nessuna CSS variable in globals.css
// globals.css senza --color-primary o simili

// SLOP: colori inconsistenti tra componenti
// Button usa blue-600, Link usa indigo-600, Badge usa violet-600
```

### Fix:
```css
/* globals.css */
:root {
  --color-primary: #2563eb;
  --color-primary-hover: #1d4ed8;
  --color-secondary: #6b7280;
  --color-surface: #ffffff;
  --color-border: #e5e7eb;
  --color-accent: #7c3aed;
  --color-danger: #dc2626;
  --color-warning: #d97706;
  --color-success: #16a34a;
}
```
```js
// tailwind.config.ts
colors: {
  primary: 'var(--color-primary)',
  secondary: 'var(--color-secondary)',
  surface: 'var(--color-surface)',
  border: 'var(--color-border)',
}
```
```tsx
// Uso corretto
<button className="bg-primary hover:bg-primary-hover text-white">
```

### Indicatori di design UNICO:
- Palette definita con nome progetto (es. brand-blue, brand-green)
- Dark mode con CSS variables che cambiano (non solo dark: prefix)
- Colori testati per accessibilità WCAG AA

---

## AREA 3: LAYOUT

### Pattern SLOP da cercare:
```tsx
// SLOP: hero section completamente generica
<section>
  <h1>Il Titolo Principale</h1>
  <p>La sottodescrizioner del prodotto.</p>
  <button>Inizia ora</button>
  <button>Scopri di più</button>
</section>

// SLOP: features grid 3 colonne sempre uguale
{features.map(f => (
  <div key={f.title}>
    <Icon />
    <h3>{f.title}</h3>
    <p>{f.description}</p>
  </div>
))}

// SLOP: sidebar identica a ogni gestionale
// Lista link verticale con icona + testo, nessuna personalizzazione
```

### Fix — Elementi Differenzianti:
- Hero: aggiungi elemento visivo (immagine reale, video, mockup, badge animato)
- Features: usa layout asimmetrico, oppure numbering grande, oppure screenshot reali
- Sidebar: colore brand specifico, logo prominente, avatar utente ben posizionato

### Indicatori di design UNICO:
- Almeno 1 elemento "wow" visivo nella hero
- Spacing non uniforme (non tutto p-6 / gap-4)
- Brand color usato in modo prominente (non solo nei bottoni)

---

## AREA 4: CONTENUTI

### Pattern SLOP — esempi esatti da cercare:
```tsx
// SLOP: lorem ipsum
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>

// SLOP: numeri inventati convincenti ma falsi
<span>+12,847 clienti soddisfatti</span>
<span>99.9% uptime garantito</span>
<span>Risparmia il 47% del tempo</span>

// SLOP: nomi placeholder
<p>Mario Rossi — CEO di Azienda Srl</p>
<p>"Questo prodotto ha cambiato il mio business." — John D.</p>

// SLOP: descrizioni corporate vuote
<p>Offriamo soluzioni innovative e scalabili per il tuo business.</p>
<p>Il nostro team di esperti è a tua disposizione 24/7.</p>

// SLOP: placeholder visibili in UI
<img src="/placeholder.svg" alt="placeholder" />
<p>Metrics coming soon...</p>
```

### Fix:
```tsx
// OK: contenuto specifico del dominio
<p>Gestisci le commesse dell'impianto con tracciabilità completa dei pezzi.</p>

// OK: mock dichiarato esplicitamente
{/* TODO: sostituire con dati reali da analytics */}
<span>127 ordini questo mese</span>

// OK: testimonianza reale o non mostrarla
// Non mostrare testimonianze se non hai quelle vere
```

---

## AREA 5: COMPONENTI

### Pattern SLOP da cercare:
```tsx
// SLOP: un solo tipo di button
<Button>Azione</Button>  // sempre uguale, mai varianti

// SLOP: nessun empty state
{items.length === 0 && <p>Nessun elemento</p>}  // testo puro, senza design

// SLOP: hover state assente
<div className="cursor-pointer" onClick={...}>  // nessun hover visivo

// SLOP: icone miste
import { HomeIcon } from '@heroicons/react'    // Heroicons
import { Settings } from 'lucide-react'        // Lucide
import { FaUser } from 'react-icons/fa'        // FontAwesome
// Tutte e 3 nello stesso progetto = SLOP
```

### Fix:
```tsx
// OK: varianti button
<Button variant="default">Salva</Button>
<Button variant="outline">Annulla</Button>
<Button variant="ghost">Indietro</Button>
<Button variant="destructive">Elimina</Button>

// OK: empty state curato
{items.length === 0 && (
  <EmptyState
    icon={<PackageOpen className="h-12 w-12 text-muted-foreground" />}
    title="Nessun articolo in magazzino"
    description="Aggiungi il primo articolo per iniziare a tracciare le giacenze."
    action={<Button onClick={onAddFirst}>Aggiungi articolo</Button>}
  />
)}

// OK: hover state esplicito
<div className="cursor-pointer hover:bg-accent/50 transition-colors rounded-md p-2">
```

---

## AREA 6: ANIMAZIONI

### Pattern SLOP per Tier 2:
```tsx
// SLOP: framer installato ma mai usato
// package.json ha "framer-motion" ma nessun componente usa motion.*

// SLOP: transizioni CSS invece di framer su Tier 2
<div className="transition-all duration-300">  // non abbastanza per Tier 2
```

### Pattern SLOP per Tier 1:
```tsx
// SLOP: animazioni su un progetto dichiarato Tier 1
<motion.div animate={{ opacity: 1 }}>  // Tier 1 = zero animazioni
```

### Fix Tier 2:
```tsx
import { motion, AnimatePresence } from 'framer-motion'
// Transizione pagina
<motion.main
  initial={{ opacity: 0, y: 8 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.2 }}
>
// Hover card
<motion.div whileHover={{ y: -2 }} transition={{ type: 'spring', stiffness: 300 }}>
```

---

## QUICK SCAN — Grep per trovare SLOP

```bash
# Cerca lorem ipsum
grep -r "lorem ipsum" src/ --include="*.tsx"

# Cerca placeholder.svg
grep -r "placeholder" src/ --include="*.tsx"

# Cerca colori Tailwind hardcoded (segnale)
grep -rn "bg-blue-\|text-blue-\|bg-gray-\|text-gray-" src/components/ --include="*.tsx" | head -20

# Cerca font-sans non configurato
grep -r "font-sans" src/ --include="*.tsx"
```
