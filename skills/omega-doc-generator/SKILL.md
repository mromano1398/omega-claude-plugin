---
name: omega-doc-generator
description: Use to generate or regenerate all omega project documents — CLAUDE.md, design-system.md, MVP.md, PRD.md, roadmap.md, state.md, README.md. Called by omega-wizard (first generation) or by omega-reskin and omega-context-updater for partial regeneration.
user-invocable: false
---

# omega-doc-generator — Generazione Documenti Progetto

**Lingua:** Sempre italiano.
**Principio:** I documenti omega sono la fonte di verità del progetto. Generali una volta sola all'inizio, poi mantienili aggiornati con omega-context-updater. NON rigenerare dall'inizio se già esistono — aggiorna solo le sezioni cambiate.

---

## DOCUMENTI GENERATI

| File | Posizione | Quando |
|------|-----------|--------|
| CLAUDE.md | root/ | Sempre (obbligatorio) |
| omega/STRATEGY.md | omega/ | Generato da omega-product-strategy (non rigenerare qui) |
| omega/MVP.md | omega/ | Nuovo progetto — usa STRATEGY.md come input per scope |
| omega/PRD.md | omega/ | Nuovo progetto — usa STRATEGY.md per feature list |
| omega/design-system.md | omega/ | Nuovo progetto o reskin |
| omega/roadmap.md | omega/ | Nuovo progetto |
| omega/state.md | omega/ | Nuovo progetto |
| README.md | root/ | Nuovo progetto |

**Nota STRATEGY.md:** Se esiste `omega/STRATEGY.md`, leggilo prima di generare MVP.md e PRD.md.
Le feature selezionate nella strategy diventano RF- nel PRD. Il North Star va nel MVP.md obiettivi.

---

## MODALITÀ: GENERA vs RIGENERA

### GENERA (prima volta — omega-wizard)

**REGOLA CLAUDE.md:** Se `CLAUDE.md` esiste già ed è stato modificato manualmente
(contiene sezioni non generate da omega), NON sovrascrivere silenziosamente.
Mostra un diff delle sezioni che verranno cambiate e chiedi conferma esplicita
prima di procedere. In caso di dubbio, preferisci RIGENERA al posto di GENERA.

- Nessun documento omega esiste ancora
- Crea la cartella `omega/` se non esiste
- Genera tutti i documenti usando i template in references/templates.md
- Chiedi approvazione con `[OK]` prima di iniziare il codice
- Ordine generazione: CLAUDE.md → MVP.md → PRD.md → design-system.md → roadmap.md → state.md → README.md

### RIGENERA (documenti esistenti)
- Leggi prima i documenti esistenti
- Aggiorna SOLO le sezioni pertinenti alla modifica
- MAI sovrascrivere decisioni architetturali esistenti senza chiedere
- Mostra diff delle modifiche proposte prima di applicare
- Usa omega-context-updater per aggiornamenti di routine

---

## MODALITÀ PARZIALE

Chiama omega-doc-generator in modalità parziale quando:

**Dopo reskin (omega-reskin):**
- Rigenera solo `omega/design-system.md`
- Aggiorna sezione [DESIGN SYSTEM] in CLAUDE.md

**Dopo nuovo modulo:**
- Aggiorna sezione [MODULI IMPLEMENTATI] in CLAUDE.md
- Aggiorna `omega/state.md` sezione completed_modules
- Aggiorna `omega/roadmap.md` se il modulo era in roadmap

**Dopo cambio scope:**
- Rigenera `omega/MVP.md` con nuovo scope
- Aggiorna `omega/PRD.md` sezione features
- Aggiorna `omega/roadmap.md` con nuove fasi
- Mostra diff completo all'utente prima di applicare

---

## PROCESSO APPROVAZIONE

Dopo la generazione, mostra anteprima e chiedi:

```
Documenti generati — anteprima:

📄 CLAUDE.md — [N righe]
  → Stack: Next.js 15, PostgreSQL, shadcn/ui
  → Tier: 2 (PROFESSIONALE)
  → Moduli: [lista]

📄 omega/MVP.md — [N righe]
  → Scope definito: [X funzionalità]

📄 omega/design-system.md — [N righe]
  → Tier 2, palette [colori]

[OK] → Procedi con il codice
[M]  → Modifica [specifica sezione]
[R]  → Rigenera da capo con nuove info
```

**[OK]** — Approva tutto, inizia il codice
**[M]** — L'utente indica cosa modificare, rigenera solo quella sezione
**[R]** — Scarta tutto, rifai con nuove informazioni

---

## REGOLE

- CLAUDE.md è il documento più importante. Senza CLAUDE.md valido non si inizia il codice.
- Ogni sezione in CLAUDE.md ha commenti `<!-- istruzioni per Claude -->` che guidano il comportamento.
- omega/state.md deve avere sempre un campo `last_updated` valido.
- design-system.md deve essere coerente con il tier scelto (non includere info GSAP se tier = 1).
- README.md deve essere leggibile da un developer che non conosce omega.

## REFERENCES
- [references/templates.md] — Template completi per tutti i documenti
