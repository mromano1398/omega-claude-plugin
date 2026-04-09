---
name: omega-stitch
description: Use when the user wants to import an external design — from Google Stitch, URL, screenshot, or DESIGN.md file. Optional integration called by omega-wizard or omega-reskin. Never mandatory.
user-invocable: false
---

# omega-stitch — Import Design Esterno

**Lingua:** Sempre italiano.
**Principio:** MAI obbligatorio. Usalo solo quando l'utente ha un design esterno da importare. L'output è sempre `omega/design-system.md` aggiornato con i token del design importato.

---

## QUANDO USARLO

Chiama omega-stitch quando:
- L'utente dice "ho un design su Figma/Stitch", "ho uno screenshot del sito", "ho un file di design"
- omega-wizard chiede "hai già un design?" e l'utente risponde sì
- omega-reskin ha bisogno di un nuovo design system basato su fonte esterna

Non chiamarlo se:
- L'utente vuole scegliere un tier e palette da zero (usa omega-tier-system direttamente)
- Non c'è nessun design esterno di riferimento
- L'utente è soddisfatto del design attuale

---

## 4 OPZIONI DI IMPORT

### Opzione 1: DESIGN.md (preferita)
L'utente ha preparato un file `DESIGN.md` nella root con la descrizione del design.

**Processo:**
1. Leggi `DESIGN.md` per intero
2. Estrai: colori (hex), font, spacing, stile generale, componenti specifici
3. Mappa ai token semantici omega (primary, secondary, surface, border, ecc.)
4. Identifica il tier più vicino al design descritto
5. Genera `omega/design-system.md` con i dati estratti

### Opzione 2: URL o Screenshot
L'utente fornisce un URL o screenshot di un sito di riferimento.

**Processo:**
1. Analizza visivamente l'URL/screenshot
2. Estrai palette colori dominante (primary, background, accent, testo)
3. Identifica font (se leggibili) o font simili disponibili su Google Fonts
4. Valuta il tier in base alla complessità visiva
5. Documenta le estrazioni in `omega/design-system.md`
6. Nota: l'estrazione è approssimativa — conferma sempre i colori hex con l'utente

### Opzione 3: Descrizione Testuale
L'utente descrive il design a parole.

**Processo:**
1. Fai domande specifiche per raccogliere tutti i token necessari:
   - "Che colore vuoi per il bottone principale?" → hex o nome colore
   - "Sfondo chiaro o scuro?" → light/dark
   - "Font preferito?" → nome font o stile (moderno, serif, geometrico)
   - "Stile generale?" → minimal, corporate, bold, playful
2. Proponi una palette concreta basata sulla descrizione
3. Chiedi conferma prima di generare il design system

### Opzione 4: MCP Stitch (Google Stitch)
Se il MCP server di Google Stitch è disponibile nell'ambiente.

**Processo:**
1. Usa il tool MCP per accedere al progetto Stitch
2. Estrai i token di design dal file Stitch (colori, font, spaziatura)
3. Converti i token Stitch in token semantici omega
4. Genera `omega/design-system.md`

**Nota:** Il MCP Stitch è opzionale e potrebbe non essere disponibile. Se non lo è, usa una delle altre opzioni.

### Opzione 5: Figma Token Export (W3C Design Tokens JSON)

Figma esporta design token tramite plugin come "Tokens Studio" in formato JSON standard.

**Processo:**
1. L'utente incolla o fornisce il JSON dei token (formato W3C Design Token Community Group)
2. omega-stitch mappa le categorie standard:
   - `color` → palette omega (primary, secondary, surface, border, ecc.)
   - `typography` → tipografia (font family, sizes, weights)
   - `spacing` → scala spaziatura
   - `borderRadius` → border radius tokens
3. Genera `omega/design-system.md` con i valori estratti
4. Genera anche variabili CSS in `src/styles/tokens.css`:
   ```css
   :root {
     --color-primary: [valore];
     --color-surface: [valore];
     /* ... */
   }
   ```

**Formato JSON atteso (W3C DTCG):**
```json
{
  "color": {
    "primary": { "$value": "#3B82F6", "$type": "color" },
    "surface": { "$value": "#FFFFFF", "$type": "color" }
  },
  "typography": {
    "heading": { "$value": { "fontFamily": "Inter", "fontSize": "2rem" }, "$type": "typography" }
  }
}
```

---

### Opzione 6: CSS Custom Properties — Incolla direttamente

Se il designer fornisce già variabili CSS, omega-stitch le importa direttamente.

**Processo:**
1. L'utente incolla un blocco di CSS custom properties
2. omega-stitch identifica il pattern semantico (colori, spaziatura, font)
3. Mappa ai token semantici omega e genera `omega/design-system.md`
4. Salva le variabili originali in `src/styles/tokens.css` senza modificarle

**Esempio input:**
```css
:root {
  --color-brand: #E63946;
  --color-bg: #F1FAEE;
  --color-text: #1D3557;
  --font-main: 'Playfair Display', serif;
}
```

---

## OUTPUT: design-system.md

L'output di omega-stitch è sempre un `omega/design-system.md` aggiornato:

```markdown
# Design System — [NOME PROGETTO]
**Fonte:** [DESIGN.md / URL: xxx / Screenshot / Stitch / Descrizione utente]
**Tier:** [1-4] — [determinato dall'analisi]
**Aggiornato:** [DATA]

## PALETTE (estratta da design esterno)
| Token | Valore | Fonte |
|-------|--------|-------|
| primary | #[hex] | [da dove è stato estratto] |
| secondary | #[hex] | ... |
| surface | #[hex] | ... |
| ...

## TIPOGRAFIA
- Font: [nome] — [come importarlo]
- Heading: [size/weight]
- Body: [size/weight]

## NOTE ADATTAMENTO
[Elenco di adattamenti fatti rispetto al design originale e perché]
```

---

## PRINCIPIO "MAI OBBLIGATORIO"

omega-stitch non viene mai imposto all'utente. Se l'utente non ha un design esterno, si usa direttamente omega-tier-system per scegliere tier e palette da zero.

L'import di un design esterno è un acceleratore, non un requisito. Il workflow normale omega funziona perfettamente senza omega-stitch.

## REFERENCES
- [references/stitch-guide.md] — Guida dettagliata per ogni metodo di import
