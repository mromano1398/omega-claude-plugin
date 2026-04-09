# Tier 3 — CINEMATIC: Definizione Tecnica Completa

## Principio
Design di impatto cinematografico. Ogni interazione è curata. Animazioni scroll-driven, tipografia display, dark theme come default. Adatto a landing premium, portfolio sviluppatore, siti agenzia, prodotti creativi.

## Palette Consigliata (personalizzare sempre)
- Dark theme default: bg `#0a0a0a` o `#09090b` (zinc-950)
- Accenti vibranti: es. indigo `#6366f1`, lime `#a3e635`, orange `#f97316`
- Surface card: `#111111` o `#18181b` (zinc-900)
- Border: `rgba(255,255,255,0.08)` o `#27272a` (zinc-800)
- Text primary: `#fafafa` (zinc-50)
- Text secondary: `#a1a1aa` (zinc-400)
- Glow accent: usa il colore primario con opacity bassa per effetti glow

## Font
**Font Display (per titoli hero e heading grandi):**
- `Geist` (Vercel) — moderno, pulito
- `Space Grotesk` — geometrico, tech
- `Plus Jakarta Sans` — elegante, versatile
- `Bricolage Grotesque` — espressivo

**Font Body (separato dal display):**
- `Inter` — standard
- `DM Sans` — friendly

**Setup Next.js:**
```tsx
import { Space_Grotesk, Inter } from 'next/font/google'
const display = Space_Grotesk({ subsets: ['latin'], variable: '--font-display' })
const body = Inter({ subsets: ['latin'], variable: '--font-body' })
```

**Sizing:**
- Hero H1: fluid `clamp(48px, 8vw, 96px)`
- H2 section: `clamp(32px, 5vw, 56px)`
- Body: 16-18px

## Animazioni (GSAP + Lenis)

**Installazione:**
```bash
npm install gsap lenis
```

**Lenis (smooth scrolling):**
```tsx
// lib/lenis.ts
import Lenis from 'lenis'
export function initLenis() {
  const lenis = new Lenis({ duration: 1.2, easing: (t) => 1 - Math.pow(1 - t, 3) })
  function raf(time: number) {
    lenis.raf(time)
    requestAnimationFrame(raf)
  }
  requestAnimationFrame(raf)
  return lenis
}
```

**GSAP ScrollTrigger (animazioni scroll):**
```tsx
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
gsap.registerPlugin(ScrollTrigger)

// Fade up entrance
gsap.fromTo(element, 
  { opacity: 0, y: 60 },
  { opacity: 1, y: 0, duration: 0.8, ease: 'power3.out',
    scrollTrigger: { trigger: element, start: 'top 85%' }
  }
)
```

**Animazioni Permesse:**
- Fade-up entrance su scroll (opacità + y transform)
- Scale-in su elementi card
- Parallax leggero su elementi background (max 20% velocità scroll)
- Stagger su liste/grid di elementi
- Hover cinematografico: scale(1.02) + glow shadow
- Transizioni pagina fluide (0.4-0.6s)
- Text reveal (clip-path animation)
- Cursor custom (opzionale)

## Dark Theme Setup
```css
/* globals.css */
:root {
  --bg: #0a0a0a;
  --surface: #111111;
  --border: rgba(255,255,255,0.08);
  --text-primary: #fafafa;
  --text-secondary: #a1a1aa;
  --accent: #6366f1; /* personalizzare */
}
```

## Componenti Specifici Tier 3
- `HeroSection`: fullscreen, font display giant, CTA con glow
- `ScrollReveal`: wrapper con GSAP entrance
- `ParallaxSection`: background a velocità differente
- `GlowCard`: card con glow hover effect
- `MarqueeText`: testo in scroll orizzontale continuo
- `StickyNav`: navbar che cambia stile su scroll

## Regole
- Dark theme di default (light opzionale con toggle)
- NO tabelle dense — usa card e list invece
- Font display SOLO per titoli (H1, H2), mai per body text
- Ogni sezione ha il proprio "momento" visivo
- Whitespace generoso: sezioni con py-24 o py-32
- NO glassmorphism eccessivo (max 1 elemento per pagina)

## PATTERN AVANZATI TIER 3

### Scroll-driven animations — CSS native (2026)
```css
/* Senza GSAP — nativo Chrome/Firefox moderno */
.hero-text {
  animation: fade-in linear both;
  animation-timeline: scroll(root);
  animation-range: entry 0% entry 30%;
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(30px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* View-based (appare quando l'elemento entra nel viewport) */
.card {
  animation: slide-up linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 40%;
}
```
**Note:** `animation-timeline: scroll()` è supportato in Chrome 115+, Firefox 110+. Per Safari/fallback usa GSAP ScrollTrigger.

---

### Text Splitting — pattern senza dipendenze pesanti
```typescript
// splitting.js (alternativa free a GSAP SplitText)
// npm install splitting
import 'splitting/dist/splitting.css'
import Splitting from 'splitting'

// Nel componente:
useEffect(() => {
  Splitting() // cerca elementi con data-splitting attribute
}, [])
```
```html
<!-- Nel JSX: -->
<h1 data-splitting>Titolo animato lettera per lettera</h1>
```
```css
.word { overflow: hidden; }
.char {
  display: inline-block;
  animation: char-reveal 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
  animation-delay: calc(var(--char-index) * 0.03s);
}
@keyframes char-reveal {
  from { transform: translateY(110%); opacity: 0; }
  to   { transform: translateY(0);    opacity: 1; }
}
```

---

### Page Transitions — Next.js App Router + Framer Motion
```typescript
// app/template.tsx (usa template.tsx non layout.tsx per le transizioni)
'use client'
import { motion } from 'framer-motion'

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -8 }}
      transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  )
}
```
**Nota:** `template.tsx` viene rimontato ad ogni navigazione (a differenza di `layout.tsx`).
Per transizioni più elaborate usa `AnimatePresence` con `mode="wait"`.

---

### Magnetic Cursor / Custom Cursor
```typescript
'use client'
import { useEffect, useRef } from 'react'

export function MagneticCursor() {
  const cursorRef = useRef<HTMLDivElement>(null)
  const pos = useRef({ x: 0, y: 0 })
  const target = useRef({ x: 0, y: 0 })

  useEffect(() => {
    const onMove = (e: MouseEvent) => {
      target.current = { x: e.clientX, y: e.clientY }
    }
    window.addEventListener('mousemove', onMove)

    let raf: number
    const lerp = (a: number, b: number, t: number) => a + (b - a) * t
    const tick = () => {
      pos.current.x = lerp(pos.current.x, target.current.x, 0.12)
      pos.current.y = lerp(pos.current.y, target.current.y, 0.12)
      if (cursorRef.current) {
        cursorRef.current.style.transform =
          `translate(${pos.current.x - 16}px, ${pos.current.y - 16}px)`
      }
      raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)
    return () => { window.removeEventListener('mousemove', onMove); cancelAnimationFrame(raf) }
  }, [])

  return (
    <div
      ref={cursorRef}
      className="pointer-events-none fixed top-0 left-0 z-[9999] w-8 h-8
                 rounded-full border-2 border-white mix-blend-difference"
      aria-hidden="true"
    />
  )
}
```
```css
/* Nascondi cursore nativo solo se JS è abilitato */
@media (hover: hover) { body:has(.magnetic-cursor-active) { cursor: none; } }
```
