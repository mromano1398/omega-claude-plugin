---
name: omega-pm
description: Use when a non-technical project manager or stakeholder needs a business-level status view, launch readiness assessment, risk summary, or sprint report in plain language without technical jargon. Triggered by [PM] menu option or when user asks about status, risks, or timeline in business terms.
user-invocable: false
---

# omega-pm — Vista Business · Status · Rischi · Lancio

**Lingua:** Sempre italiano.
**Principio:** Nessun termine tecnico senza spiegazione. Il PM non sa cosa sia un advisory lock o una migration — sa se il progetto è in ritardo, quali rischi ci sono, e quando si lancia.

## QUANDO USARE

- PM o stakeholder chiede stato del progetto
- Richiesta report per superiori o cliente
- Valutazione "siamo pronti al lancio?"
- Analisi rischi in linguaggio business
- Sprint report settimanale non tecnico

## FLUSSO — Come generare la vista PM

```
1. Leggi: omega/state.md + omega/log.md (ultime 30 righe) + omega/PRD.md + omega/roadmap.md
2. Genera Dashboard PM con: stato generale 🟢/🟡/🔴, avanzamento %, rischi attivi
3. Traduci TUTTI i termini tecnici in linguaggio business (vedi tabella in references/)
4. Valuta launch readiness: quanti punti della checklist sono verdi?
5. Se richiesto: report per stakeholder (1 pagina, no tecnico)
```

## REGOLE CHIAVE

1. **Zero gergo tecnico** senza spiegazione immediata
2. **Ogni problema tecnico = rischio business** — traduci sempre (vedi tabella in references/risk-matrix.md)
3. **Semaforo sempre presente** — 🟢 VERDE / 🟡 ATTENZIONE / 🔴 CRITICO
4. **% completamento sempre visibile** — il PM non legge log tecnici
5. **Data lancio o "non definita"** — mai rispondere senza una stima
6. **Rischi ordinati per impatto** — critici prima, medi dopo
7. **"Cosa ci serve" esplicito** — decidi tu se serve una decisione del cliente/PM

## CHECKLIST SINTETICA

- [ ] Dashboard PM generata da file omega/ correnti
- [ ] Stato generale 🟢/🟡/🔴 assegnato con motivazione
- [ ] Rischi attivi tradotti in linguaggio business
- [ ] Launch readiness checklist completata (vedi references/launch-readiness.md)
- [ ] Timeline visiva con fasi e date

## QUANDO PASSARE A OMEGA STANDARD

`omega-pm` è una vista — non esegue azioni tecniche. Per:
- Pianificare il lavoro tecnico → `/omega:omega` menu principale
- Gestire PR e team developer → `/omega:omega-team`
- Deploy e infrastruttura → `/omega:omega-devops`
- Sicurezza e GDPR → `/omega:omega-security`

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/risk-matrix.md] — formato analisi rischi, tabella conversione tecnico→business, traduzione terminologia, sprint report, report stakeholder
- [references/launch-readiness.md] — dashboard PM completa, checklist lancio per area, timeline visiva
