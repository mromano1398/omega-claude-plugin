# Tier 2 — PROFESSIONALE: Definizione Tecnica Completa

## Principio
Equilibrio tra estetica curata e funzionalità. Microinterazioni che migliorano l'UX senza distrarre. Mobile-first. Adatto a SaaS B2C, dashboard prodotto, app consumer.

## Palette Consigliata (personalizzare sempre)
- Personalizzata sul brand del cliente
- Esempio: brand color vibrante (es. violet `#7c3aed`) + toni neutri slate
- Surface: white o slate-50
- Border: slate-200 o slate-100
- Usa CSS variables per tema chiaro/scuro opzionale
- Token semantici in `globals.css` con `--color-primary`, `--color-secondary`, ecc.

## Font
- Font principale: `Inter` (Google Fonts)
- Heading: Inter 600-700, fluid typography con `clamp()`
- Body: Inter 400, 16px (mobile-first)
- Opzionale: secondo font per heading (es. `Cal Sans`, `DM Sans`)
- Font size mobile: 15-16px, desktop: 16px

## Spacing e Layout
- Mobile-first: `sm:` come breakpoint principale
- Max-width container: 1200px centrato
- Padding mobile: px-4, desktop: px-6 o px-8
- Card padding: p-5 o p-6
- Gap: gap-4 (mobile), gap-6 (desktop)
- Border radius: `rounded-lg` (8px) o `rounded-xl` (12px) — ok per cards

## Animazioni (Framer Motion)
Installazione: `npm install framer-motion`

**Transizioni di pagina (AnimatePresence):**
```tsx
<AnimatePresence mode="wait">
  <motion.div
    key={pathname}
    initial={{ opacity: 0, y: 8 }}
    animate={{ opacity: 1, y: 0 }}
    exit={{ opacity: 0, y: -8 }}
    transition={{ duration: 0.2 }}
  />
</AnimatePresence>
```

**Microinterazioni permesse:**
- Hover card: `whileHover={{ y: -2, boxShadow: "..." }}`
- Button press: `whileTap={{ scale: 0.97 }}`
- Focus input: border-color transition
- Dropdown: `AnimatePresence` + slide-down 150ms
- Toast: slide-in da destra

**Animazioni NON permesse:**
- NO GSAP, NO Three.js
- NO scroll-triggered animations
- NO animazioni più lunghe di 300ms
- NO stagger complessi

## Skeleton Loading States
```tsx
// Pattern standard
<Skeleton className="h-4 w-[250px]" />
<Skeleton className="h-4 w-[200px]" />
```
- Usa shimmer effect: `animate-pulse` Tailwind
- Skeleton deve rispecchiare la forma del contenuto reale
- Timeout: mostra skeleton dopo 200ms (evita flash)

## Empty States
- Ogni lista/tabella vuota deve avere:
  - Icona illustrativa (Lucide o custom SVG)
  - Titolo descrittivo ("Nessun progetto ancora")
  - Sottotitolo con azione ("Crea il tuo primo progetto →")
  - CTA button quando applicabile

## Componenti Aggiuntivi (rispetto a Tier 1)
- `Skeleton`: con shimmer animato
- `EmptyState`: con illustrazione + CTA
- `AnimatedCounter`: count-up su metriche dashboard
- `HoverCard`: preview info on hover
- `Command`: palette comandi (Cmd+K)
- `Combobox`: select ricercabile
- `DatePicker`: con calendar component

## Mobile-First Specifiche
- Touch targets: min 44px height
- Bottom navigation per app mobile-like
- Swipe gestures su cards (opzionale con framer)
- Keyboard mobile: considera padding-bottom per tastiera virtuale

## Ombre e Profondità
- Cards: `shadow-sm` o `shadow` (mai shadow-xl)
- Hover state: `shadow-md` con transizione
- Modal overlay: `bg-black/50`
- Dropdown: `shadow-lg`

### Grid System Responsive — Tier 2

```typescript
// Pattern grid standard per layout Tier 2 (dashboard / SaaS):

// Breakpoint Tailwind consigliati (non cambiare questi valori):
// sm: 640px | md: 768px | lg: 1024px | xl: 1280px | 2xl: 1536px

// Layout principale:
<div className="grid grid-cols-1 md:grid-cols-[240px_1fr] min-h-screen">
  <Sidebar className="hidden md:block" />
  <main className="flex flex-col">
    <Header />
    <div className="flex-1 p-4 md:p-6 lg:p-8">
      {children}
    </div>
  </main>
</div>

// Grid card/KPI (adattivo):
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  {kpis.map(kpi => <KpiCard key={kpi.id} {...kpi} />)}
</div>

// Grid form a 2 colonne (collassa su mobile):
<div className="grid grid-cols-1 md:grid-cols-2 gap-4">
  <FormField name="nome" />
  <FormField name="cognome" />
</div>

// Tabella → card su mobile (pattern alternativo a scroll orizzontale):
// Desktop: <table> standard
// Mobile: ogni riga diventa una <Card> con grid label/value
<div className="hidden md:block"><DataTable ... /></div>
<div className="md:hidden space-y-3">
  {rows.map(row => <MobileCard key={row.id} row={row} />)}
</div>
```

**Regole grid Tier 2:**
- Mobile-first: inizia da `grid-cols-1`, aggiungi colonne con prefissi `md:` e `lg:`
- Mai usare `grid-cols-3` su mobile senza `sm:` prefix
- Sidebar sempre nascosta su mobile (`hidden md:block`) con menu hamburger alternativo
- Form input: larghezza `w-full` sempre, container limita la larghezza (`max-w-2xl`)

## Accessibilità
- Contrasto WCAG AA minimo
- Focus visible su tutti gli elementi interattivi
- ARIA labels su icone senza testo
- Skip navigation link
