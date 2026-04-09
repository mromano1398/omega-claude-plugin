---
name: omega-audit-ui
description: Use to detect AI-slop UI patterns — generic fonts, default Tailwind colors, cookie-cutter layouts, lorem ipsum, placeholder metrics. Triggered by [AUDIT-UI] or automatically at the end of Phase 2 construction.
user-invocable: false
---

# omega-audit-ui — Audit Anti-Slop UI

**Lingua:** Sempre italiano.
**Principio:** Ogni progetto omega deve avere un'identità visiva riconoscibile. L'AI-slop è il nemico: UI generiche, colori di default, layout cookie-cutter, contenuti placeholder.

---

## 6 AREE DI CONTROLLO

### 1. FONT
Controlla che il progetto NON usi:
- `font-sans` di default Tailwind senza configurazione custom
- `Arial`, `Helvetica` come font principale senza scelta consapevole
- Font non caricati con `next/font` (Flash of Unstyled Text)
- Nessuna gerarchia tipografica (tutti i testi stessa dimensione)

Verifica positiva:
- Font dichiarato in `tailwind.config.ts` → `fontFamily`
- Import in `app/layout.tsx` con `next/font/google` o `next/font/local`
- Almeno 2 font-weight usati (400 + 600/700)

### 2. COLORI
Controlla che il progetto NON usi:
- `text-blue-500`, `bg-blue-600` direttamente senza CSS variables
- Palette Tailwind di default non personalizzata
- `text-gray-500` come unico colore testo secondario
- Nessun colore brand definito

Verifica positiva:
- CSS variables definite in `globals.css` (`--color-primary`, ecc.)
- `tailwind.config.ts` con colori custom che puntano a CSS variables
- Almeno 5 token semantici definiti (primary, secondary, surface, border, accent)

### 3. LAYOUT
Controlla che il progetto NON abbia:
- Sidebar identica a ogni altro Next.js gestionale (stessa struttura senza identità)
- Hero section con solo "Titolo, Sottotitolo, CTA" senza differenziazione
- Grid 3 colonne con icona+titolo+testo per features (il pattern più abusato)
- Footer con 4 colonne link identico a tutti

Verifica positiva:
- Layout ha almeno 1 elemento visivo distintivo
- Spacing e proporzioni coerenti con design-system.md
- Breakpoints rispettati (mobile-first o desktop-first coerente con tier)

### 4. CONTENUTI
Controlla che il progetto NON contenga:
- "Lorem ipsum" in qualsiasi forma
- Numeri placeholder: "1234", "99%", "+500 clienti", "€ 0,00"
- Nomi placeholder: "Mario Rossi", "Utente Test", "John Doe"
- Descrizioni generiche: "La nostra azienda offre soluzioni innovative"
- Immagini `/placeholder.svg` o `picsum.photos` in produzione
- "Coming soon" su feature non implementate senza spiegazione

Verifica positiva:
- Tutti i testi sono specifici del dominio del progetto
- Numeri sono reali o dichiaratamente mock con commento `// TODO: dati reali`
- Immagini sono asset reali o hanno alt text descrittivo

### 5. COMPONENTI
Controlla che il progetto NON abbia:
- Tutti i bottoni identici `rounded-md bg-primary` senza varianti
- Cards tutte uguali senza differenziazione per tipo
- Badge con solo colore grigio (nessuna semantica)
- Icone miste da librerie diverse (Lucide + Heroicons + Font Awesome insieme)
- Hover state mancanti su elementi interattivi

Verifica positiva:
- Almeno 3 varianti di button definite (primary/secondary/ghost)
- Hover states su tutti i link e bottoni
- Icone da una sola libreria (preferibilmente Lucide)
- Empty states presenti per liste vuote

### 6. ANIMAZIONI
Controlla coerenza con il tier dichiarato:
- Tier 1: verifica che NON ci siano animazioni aggiunte
- Tier 2: verifica che Framer Motion sia installato e usato (non solo CSS transitions)
- Tier 3: verifica che GSAP + Lenis siano presenti e funzionanti
- Tier 4: verifica presence check WebGL + fallback 2D

---

## 3 VERDETTI

**UNICO** — Il design ha identità riconoscibile, nessun pattern slop rilevato, coerente col tier scelto.

**GENERICO** — Il design funziona ma manca di identità. Presenza di pattern comuni ma non flagranti. Raccomandati miglioramenti specifici.

**SLOP** — Pattern AI-slop rilevati. Richiede intervento prima del deploy. Lista problemi critici.

---

## OUTPUT REPORT

```
╔══════════════════════════════════════════════════╗
║           omega-audit-ui — Report                ║
╚══════════════════════════════════════════════════╝

VERDETTO GLOBALE: [UNICO / GENERICO / SLOP]

FONT        [✅ OK / ⚠ ATTENZIONE / ❌ SLOP]
  → [dettaglio]

COLORI      [✅ OK / ⚠ ATTENZIONE / ❌ SLOP]
  → [dettaglio]

LAYOUT      [✅ OK / ⚠ ATTENZIONE / ❌ SLOP]
  → [dettaglio]

CONTENUTI   [✅ OK / ⚠ ATTENZIONE / ❌ SLOP]
  → [dettaglio]

COMPONENTI  [✅ OK / ⚠ ATTENZIONE / ❌ SLOP]
  → [dettaglio]

ANIMAZIONI  [✅ OK / ⚠ ATTENZIONE / ❌ SLOP]
  → [dettaglio]

══════════════════════════════════════════════════
AZIONI RICHIESTE:
1. [azione specifica con file da modificare]
2. [azione specifica con file da modificare]
══════════════════════════════════════════════════
```

---

## AZIONI POST-AUDIT

- **UNICO**: Nessuna azione. Documenta il design in omega/design-system.md.
- **GENERICO**: Proponi 2-3 miglioramenti specifici. Chiedi all'utente se vuole procedere.
- **SLOP**: STOP. Lista tutti i problemi critici. Risolvi prima di continuare.

## REFERENCES
- [references/anti-slop-checklist.md] — Checklist dettagliata con esempi di codice slop e fix
