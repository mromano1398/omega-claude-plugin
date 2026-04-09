# Accessibilità — WCAG 2.1 AA Checklist Operativa

## Contrasto Colori

| Contesto | Rapporto minimo |
|---|---|
| Testo normale (< 18px) | 4.5:1 |
| Testo grande (≥ 18px o ≥ 14px bold) | 3:1 |
| Componenti UI e bordi | 3:1 |
| Testo decorativo / logo | Nessun requisito |

Tool: https://webaim.org/resources/contrastchecker/

## Navigazione Tastiera

- [ ] Tutti gli elementi interattivi raggiungibili con Tab
- [ ] Tab order logico (segue ordine visivo)
- [ ] Focus sempre visibile — mai `outline: none` senza alternativa
- [ ] Modali: focus trap attivo, Esc per chiudere
- [ ] Dropdown/menu: frecce direzionali per navigare le opzioni

```css
/* Focus visibile minimo */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

## Screen Reader

```tsx
// Pulsanti icon-only — sempre aria-label
<button aria-label="Chiudi dialogo">
  <XIcon />
</button>

// Descrizione aggiuntiva
<input
  aria-describedby="email-hint"
  type="email"
/>
<p id="email-hint">Usa il formato nome@esempio.it</p>

// Regioni landmark
<nav aria-label="Navigazione principale">
<main>
<aside aria-label="Filtri">

// Live region per aggiornamenti dinamici
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>
```

## Immagini

```tsx
// Immagine informativa — alt descrittivo
<Image src="/grafico.png" alt="Grafico vendite Q1: aumento 23%" />

// Immagine decorativa — alt vuoto
<Image src="/divider.svg" alt="" />

// Icone SVG inline
<svg aria-hidden="true" focusable="false">...</svg>
```

## Form

```tsx
// Label sempre associata — mai solo placeholder
<label htmlFor="nome">Nome completo</label>
<input id="nome" name="nome" type="text" required />

// Errori accessibili
<input
  id="email"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <p id="email-error" role="alert">
    Formato email non valido
  </p>
)}

// Campi obbligatori
<label htmlFor="tel">
  Telefono <span aria-hidden="true">*</span>
  <span className="sr-only">(obbligatorio)</span>
</label>
```

## Colori e Informazioni

- **Mai usare solo il colore** per trasmettere informazioni
- Affianca sempre: icona, testo, pattern o forma

```tsx
// SBAGLIATO — solo colore
<Badge color="red">Errore</Badge>

// CORRETTO — colore + icona + testo
<Badge variant="error">
  <ErrorIcon aria-hidden="true" /> Errore
</Badge>
```

## Link

```tsx
// SBAGLIATO
<a href="/prodotti">Clicca qui</a>

// CORRETTO — testo descrittivo
<a href="/prodotti">Vedi tutti i prodotti</a>

// Link che apre nuova tab — avvisa
<a href="https://..." target="_blank" rel="noopener noreferrer">
  Documentazione esterna
  <span className="sr-only">(apre in nuova scheda)</span>
</a>
```

## Classi Utility Tailwind

```tsx
// Visibile solo a screen reader
<span className="sr-only">Testo solo per screen reader</span>

// Nascosto a screen reader, visibile visivamente
<span aria-hidden="true">★★★★☆</span>
```

## Test Rapido

1. Naviga tutta la pagina usando solo Tab — tutto raggiungibile?
2. Testa con screen reader: NVDA (Windows), VoiceOver (Mac/iOS)
3. Zoom al 200% — layout non rotto?
4. Lighthouse Accessibility score ≥ 90
5. axe DevTools browser extension — zero violazioni critiche
