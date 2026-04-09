# Tier 1 — FUNZIONALE: Definizione Tecnica Completa

## Principio
Zero friction, massima leggibilità, velocità di caricamento prioritaria. Adatto a tool interni, ERP, gestionali dove la densità di informazioni è più importante dell'estetica.

## Palette Consigliata (personalizzare sempre)
- Primary: Blu professionale es. `#2563eb` (Tailwind blue-600) o simile azienda
- Secondary: Grigio neutro `#6b7280` (Tailwind gray-500)
- Surface: `#ffffff` (card/panel), `#f9fafb` (bg pagina)
- Border: `#e5e7eb` (Tailwind gray-200)
- Danger: `#dc2626` (red-600)
- Warning: `#d97706` (amber-600)
- Success: `#16a34a` (green-600)
- Text primary: `#111827` (gray-900)
- Text secondary: `#6b7280` (gray-500)

Nota: questi sono valori di riferimento. Adatta sempre al brand del cliente.

## Font
- Font unico: `Inter` (Google Fonts) o `system-ui` come fallback
- Heading: Inter 600-700, da 20px a 32px
- Body: Inter 400, 14px (denso) o 16px (standard)
- Monospace (per codice/ID): `JetBrains Mono` o `Fira Code`
- NO font display decorativi

## Spacing e Layout
- Base unit: 4px (Tailwind default)
- Container max-width: 1280px o full-width per dashboard
- Sidebar: 240-280px fissa
- Desktop-first: breakpoint principale `lg:` (1024px)
- Padding card: p-4 o p-6
- Gap tra elementi: gap-4 o gap-6

## Animazioni
- NESSUNA animazione — `transition: none !important` su elementi critici
- Al massimo: `transition-colors duration-150` su hover di bottoni
- NO framer-motion, NO GSAP, NO keyframes custom
- NO skeleton animati (usa skeleton statico se necessario)

## Regole Assolute
- NO gradienti (eccetto badge di stato monocolore)
- NO `rounded-full` su cards o container
- NO glassmorphism (`backdrop-blur`)
- NO ombre elaborate (solo `shadow-sm` al massimo)
- NO font decorativi o display
- NO animazioni di entrata (mount animations)
- NO parallax

## Componenti Starter (shadcn/ui base)
- `Button`: varianti default/outline/ghost/destructive
- `Input`: con label sopra, messaggio errore sotto
- `Card`: header + content + footer, niente ombre pesanti
- `Badge`: stato con colore semantico (success/warning/danger/neutral)
- `DataTable`: colonne sortabili, paginazione, filtro testo, selezione row
- `Modal`: confirm dialog, form modal — titolo + contenuto + azioni
- `Toast`: notifiche non-bloccanti, auto-dismiss 4s
- `Dropdown`: menu azioni su row tabella
- `Tabs`: navigazione sezioni in pagina
- `Skeleton`: placeholder statico per loading states

## Navigazione
- Sidebar fissa a sinistra (240px)
- Header top con breadcrumb + user menu
- NO hamburger menu su desktop
- Active state sidebar: bg-primary/10 + text-primary + border-l-2 border-primary

## DataTable Specifiche
- Font size: 14px (Tailwind `text-sm`)
- Row height: 48px (compact) o 56px (standard)
- Header: bg-gray-50, font-medium, text-gray-700
- Zebra stripes: opzionale, alternare bg-white / bg-gray-50/50
- Colonna azioni: allineata a destra, visibile solo su hover
- Paginazione: Previous/Next + numero pagina + items per page

## Sicurezza Default
- Ogni route protetta con session check
- Zod su ogni form input
- WHERE user_id su ogni query DB (mai esporre dati altrui)
