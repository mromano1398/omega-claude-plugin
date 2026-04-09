# Stitch Guide — Guida Import Design Esterno

## Metodo 1: DESIGN.md

Il metodo più efficiente. L'utente prepara un file strutturato con tutte le info del design.

### Formato DESIGN.md consigliato:
```markdown
# Design Reference

## Stile Generale
[minimal / bold / corporate / playful / dark / light / ...]

## Colori
- Primary: #2563eb (bottoni principali, link attivi)
- Secondary: #64748b (testo secondario, icone)
- Background: #f8fafc (pagina) / #ffffff (card)
- Accent: #7c3aed (highlight, badge speciali)
- Border: #e2e8f0
- Danger: #ef4444
- Success: #22c55e

## Font
- Heading: Space Grotesk (Google Fonts), weight 600-700
- Body: Inter (Google Fonts), weight 400-500
- Monospace: JetBrains Mono (per codice/ID)

## Caratteristiche Visive
- Border radius: rounded-xl (12px) su cards, rounded-lg (8px) su input
- Ombre: shadow-sm su cards, shadow-lg su modali
- Animazioni: microinterazioni hover, transizioni pagina 200ms
- Stile: flat design, no glassmorphism

## Riferimenti
- Sito simile: [URL]
- Screenshot allegato: [nome file]
```

### Come leggere DESIGN.md:
1. Estrai TUTTI i valori hex
2. Mappa ai token omega: primary/secondary/surface/border/accent/danger/warning/success
3. Verifica contrasto WCAG AA: usa `contrast-ratio.com` mentalmente (testo su sfondo)
4. Se mancano colori semantici (danger, warning), derivali dalla palette (rosso/arancio coerenti)
5. Identifica tier: nessuna animazione → Tier 1, microinterazioni → Tier 2, GSAP → Tier 3

---

## Metodo 2: URL / Screenshot

### Come analizzare un URL di riferimento:
1. **Palette:** Identifica colore dominante, colore CTA, colore background
2. **Contrasto:** Verifica che testo sia leggibile (scuro su chiaro o viceversa)
3. **Font:** Cerca il font nell'HTML (DevTools → Elements → body font-family) se hai accesso
4. **Stile:** Classifica in minimal/bold/corporate/dark
5. **Tier:** Valuta complessità animazioni visibili

### Estrazione approssimativa (senza DevTools):
- Usa descrizione visiva: "azzurro vivace, circa #0284c7"
- Proponi un hex simile e chiedi conferma: "Ho estratto approximately #0ea5e9 come primary — è corretto?"
- Per font: descrivi lo stile visivo e suggerisci alternative Google Fonts

### Template output dopo URL/screenshot:
```markdown
## Estrazione da [URL / Screenshot nome-file]

Colori estratti (approx — confermare con utente):
- Primary: ~#0284c7 (azzurro CTA)
- Background: ~#f0f9ff (azzurro molto chiaro)
- Testo: ~#0f172a (quasi nero)
- Accent: ~#7c3aed (viola — da bottoni secondari)

Font rilevato (visivamente): Geometrico sans-serif — suggerito: Plus Jakarta Sans

Tier stimato: 2 — PROFESSIONALE (animazioni subtle, mobile-first)

⚠ Valori approssimativi — confermare i hex con l'utente prima di procedere
```

---

## Metodo 3: Descrizione Testuale

### Domande da fare all'utente (in ordine):

**Round 1 — Direzione generale:**
1. "Preferisci uno stile chiaro (sfondo bianco) o scuro (sfondo nero/dark)?"
2. "Che settore/industria è il progetto?" (influenza il tono — serio/corporate vs creativo)
3. "C'è un colore brand già definito? (logo, materiali esistenti)"

**Round 2 — Colori specifici:**
4. "Che colore vuoi per il bottone principale? (puoi dire un colore, un hex, o un'ispirazione)"
5. "Vuoi accenti vibranti o tonalità sobrie?"

**Round 3 — Tipografia:**
6. "Font preferito? (o stile: classico, moderno, geometrico, umanista)"
7. "Hai già un font nel logo o materiali aziendali?"

**Round 4 — Animazioni:**
8. "Vuoi animazioni? [1] No, solo funzionale → [2] Microinterazioni hover → [3] Animazioni scroll → [4] Effetti 3D"

### Come trasformare la descrizione in token:
```
"Voglio qualcosa di professionale, colori aziendali blu e grigio, minimal"
→ primary: #1e40af (blue-800, istituzionale)
→ secondary: #64748b (slate-500, grigio neutro)
→ surface: #ffffff
→ bg: #f8fafc (slate-50)
→ Font: Inter o DM Sans
→ Tier: 1-2
```

---

## Metodo 4: MCP Google Stitch

### Prerequisiti
- MCP Stitch server attivo nel progetto Claude Code
- Utente ha accesso al progetto Stitch

### Processo:
```
1. Verifica disponibilità: controlla se tool MCP Stitch è disponibile
2. Richiedi URL o ID progetto Stitch all'utente
3. Usa mcp__stitch per caricare il progetto
4. Estrai design tokens dal JSON Stitch
5. Converti in formato omega
```

### Mapping Stitch → Omega:
```
Stitch: colors.brand.500 → omega: primary
Stitch: colors.neutral.50 → omega: surface
Stitch: colors.neutral.200 → omega: border
Stitch: typography.fontFamily.sans → omega: font-body
Stitch: typography.fontFamily.display → omega: font-display
```

### Nota importante:
Il MCP Stitch potrebbe non essere disponibile o potrebbe avere API cambiate.
Se non funziona, usa Metodo 1 (DESIGN.md) o Metodo 3 (descrizione testuale).
Non bloccare il lavoro aspettando Stitch — è un'opzione, non un requisito.

---

## Come Adattare Design Esterno al Contesto Specifico

### Principio di adattamento
Il design esterno è ispirazione, non copiatura. Il design system omega deve essere:
1. **Coerente con il blueprint** — un gestionale non adotta il dark theme di uno showcase
2. **Accessibile** — contrasto WCAG AA obbligatorio
3. **Implementabile** — usa font/librerie disponibili

### Adattamenti comuni:
| Situazione | Adattamento |
|-----------|-------------|
| Design dark su gestionale | Converti in light con accenti del brand dark |
| Font non su Google Fonts | Trova alternativa Google Fonts simile |
| Colori basso contrasto | Scurisci/schiarisci per WCAG AA |
| Design Tier 4 su SaaS | Abbassa a Tier 2-3, mantieni palette |
| Troppi colori nel design | Semplifica a 2-3 colori + semantici |

### Documenta le deviazioni:
Ogni adattamento va documentato in design-system.md:
```markdown
## NOTE ADATTAMENTO
- Font "Circular" non disponibile su Google Fonts → sostituito con "Plus Jakarta Sans" (simile geometrico)
- Dark theme originale → convertito a light per usabilità gestionale (dark come opzione futura)
- Colore accent originale #FFD700 (giallo) → scurito a #CA8A04 per contrasto WCAG AA su sfondo bianco
```
