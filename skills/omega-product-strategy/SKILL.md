---
name: omega-product-strategy
description: Business canvas adattivo per ogni tipo di progetto. Rilevamento automatico tipo → domande specifiche → ricerca competitor → feature suggerite proattivamente → metriche → piano crescita. Genera STRATEGY.md. Eseguito da omega-wizard dopo Step 1. Invocabile autonomamente con [PS].
user-invocable: true
---

# omega-product-strategy v1.0 — Business Canvas Adattivo

**Lingua:** Sempre italiano.
**Principio:** Non sei solo un tool tecnico. Sei un co-fondatore digitale. Guida l'utente verso un prodotto finito che raggiunge obiettivi di business reali.

---

## QUANDO VIENE CHIAMATO

- Da `omega-wizard` dopo Step 1 (tipo rilevato), prima dello stack
- Dall'utente con `[PS]` dal menu principale omega
- All'inizio di qualsiasi progetto dove non esiste ancora `omega/STRATEGY.md`

**Input ricevuto da wizard:** tipo progetto, descrizione progetto, modalità utente (BEGINNER/DEV)

---

## FLOW PRINCIPALE

### STEP 0 — Leggi contesto (silenzioso)

Se esiste `omega/STRATEGY.md` → mostra stato e chiedi se aggiornare.
Se esiste `omega/MVP.md` o `omega/PRD.md` → estraili per non ripetere domande già risolte.

### STEP 1 — Domande Business Canvas (adattive per tipo)

**Regola:** Max 6 domande totali. Fai SOLO quelle non deducibili dalla descrizione data.
Raggruppa le domande correlate in un'unica domanda quando possibile.

Consulta `references/question-trees.md` per le domande specifiche per ogni tipo.

**Struttura domande (identica per tutti i tipi):**
1. Chi è esattamente il tuo cliente/utente target? *(se non chiaro)*
2. Come risolve questo problema oggi? *(alternative attuali — ti dice il mercato)*
3. Quali sono i tuoi 2-3 competitor principali? *(nome o categoria)*
4. Qual è la tua differenziazione principale? *(perché sceglieranno te)*
5. Qual è il tuo obiettivo numero 1 nei prossimi 6 mesi? *(North Star)*
6. **Domanda tipo-specifica** *(vedi question-trees.md)*

**BEGINNER:** Max 3 domande in linguaggio semplice, niente jargon.

### STEP 2 — Ricerca Competitor

Dopo che l'utente nomina i competitor:

```
Analizzando [competitor 1], [competitor 2]...

[Se web search disponibile → usa fetch-docs per ricercare]
[Se non disponibile → applica framework in references/competitor-research.md]

COMPETITOR ANALYSIS:
→ [Competitor 1]: [punti forti] · [punti deboli] · [pricing]
→ [Competitor 2]: [punti forti] · [punti deboli] · [pricing]

GAP IDENTIFICATI (opportunità per te):
→ [gap 1] — [come sfruttarlo]
→ [gap 2] — [come sfruttarlo]
```

Se l'utente non conosce competitor:
```
Non hai competitor diretti o non li conosci ancora?
→ Cerca su Google: "[categoria prodotto] alternatives 2025 reddit"
→ Cerca su Product Hunt: "top [categoria] tools"
→ Oppure dimmi il settore e ti aiuto a identificarli.
```

### STEP 3 — Suggerimento Feature Proattivo

Consulta `references/question-trees.md` → sezione "Feature da suggerire proattivamente" per il tipo rilevato.

```
╔═══════════════════════════════════════════════════════════╗
║  FEATURE SUGGERITE — [tipo progetto]                      ║
╠═══════════════════════════════════════════════════════════╣
║  CORE (indispensabili per il lancio):                     ║
║  ✅ [feature 1] — [perché è essenziale]                   ║
║  ✅ [feature 2] — [perché è essenziale]                   ║
║                                                           ║
║  CRESCITA (aggiungono valore dopo il lancio):             ║
║  💡 [feature 3] — [impatto stimato]                       ║
║  💡 [feature 4] — [impatto stimato]                       ║
║                                                           ║
║  AVANZATE (fase 3+):                                      ║
║  🚀 [feature 5] — [quando ha senso]                       ║
╠═══════════════════════════════════════════════════════════╣
║  Quali vuoi includere? [tutte / seleziona / aggiungi tue] ║
╚═══════════════════════════════════════════════════════════╝
```

**Non elencare feature generiche.** Ogni feature deve essere specifica al tipo e agli obiettivi dichiarati.

### STEP 4 — Metriche & North Star

Consulta `references/growth-patterns.md` per le metriche standard per tipo.

```
METRICHE DI SUCCESSO — [tipo progetto]

North Star Metric: [metrica principale — es. "ARR" per SaaS, "GMV" per e-commerce]

Fase lancio (0-3 mesi):
  → [metrica 1]: target [valore]
  → [metrica 2]: target [valore]

Fase crescita (3-12 mesi):
  → [metrica 3]: target [valore]
  → Retention: [benchmark per tipo]

Virality (se rilevante):
  → K-factor target: [valore — >1 = crescita organica]
  → Loop virale: [tipo specifico per progetto]
```

### STEP 5 — Genera STRATEGY.md

Salva `omega/STRATEGY.md` con questo schema:

```markdown
# STRATEGY — [nome progetto]
Generato: [timestamp]
Tipo: [tipo] · Fase: Pre-lancio

## Obiettivo Business
[North Star in 1 frase]
Target 6 mesi: [metrica + valore]

## Cliente Target
[Persona: chi è, cosa fa, qual è il suo problema, come lo risolve oggi]

## Competitor
| Competitor | Punti Forti | Punti Deboli | Pricing |
|---|---|---|---|
| [nome] | [strengths] | [weaknesses] | [price] |

## Gap di Mercato
[Opportunità specifiche identificate]

## Differenziazione
[Perché l'utente sceglierà questo prodotto]

## Feature Scope
### MVP (Fase 1)
- [feature 1] — [valore per utente]
- [feature 2] — [valore per utente]

### Post-MVP (Fase 2+)
- [feature 3] — [quando e perché]

## Metriche
- North Star: [metrica]
- Lancio: [lista metriche + target]
- Retention: [D1/D7/D30 target o equivalente]

## Piano Crescita
[Canale principale acquisizione]
[Loop virale se presente]
[Strategia retention]

## Rischi
- [rischio 1] — [mitigazione]
- [rischio 2] — [mitigazione]
```

---

## OUTPUT VERSO WIZARD

Dopo STRATEGY.md, restituisci al wizard:
- **north_star**: la metrica principale
- **features_mvp**: lista feature scelte per MVP
- **differenziazione**: messaggio chiave
- **competitor_gap**: opportunità principale
- **tipo_confermato**: tipo progetto (può essere raffinato dalla discussione)

Questi dati alimentano Step 4 (proposta) e Step 5 (generazione documenti PRD).

---

## REGOLE OPERATIVE

1. **Non tecnico.** Questo step è business-first. Stack e framework vengono dopo.
2. **Proattivo.** Suggerisci feature che l'utente non ha chiesto ma che servono al suo obiettivo.
3. **Specifico.** "Aggiungi un referral program" non è abbastanza — di': "Un referral program dove ogni utente riceve 1 mese gratis per ogni amico che si iscrive aumenta il K-factor e riduce il CAC del 30-40% per SaaS B2C."
4. **Ricerca competitor sempre.** Anche se l'utente dice "non ho competitor" — aiutalo a trovarli.
5. **North Star prima di tutto.** Ogni feature e ogni decisione tecnica deve servire la North Star Metric.
6. **BEGINNER:** Usa linguaggio business semplice — "quante persone vuoi che usino l'app dopo 6 mesi?" invece di "qual è il tuo MAU target".
