---
name: omega-debug
description: Use when the omega project state is inconsistent, corrupted, or stuck — broken plans, state.md out of sync, build permanently red, autopilot blocked, or omega documents contradicting the actual code. Triggered by "omega non funziona", "piano bloccato", "stato inconsistente", "ricomincia da zero", "ripara omega", "debug omega".
user-invocable: true
---

# omega-debug — Recovery e diagnostica

**Lingua:** Sempre italiano.
**Principio:** Diagnostica prima, agisce dopo. Non cancella mai file senza conferma.

---

## QUANDO USARLO

Attiva omega-debug se:
- `omega/state.md` non esiste ma `omega/plans/` ha piani con step incompleti
- Il piano attivo ha tutti i checkbox `[x]` ma lo stato è ancora `IN_PROGRESS`
- `omega/log.md` è vuoto o ha contenuto non valido
- omega-build-checker è bloccato in loop (STOP protocol attivato più di 3 volte di fila)
- I documenti omega (MVP.md, PRD.md) descrivono funzionalità che non esistono nel codice
- L'utente dice "parti da zero" o "ricomincia" — verifica prima se c'è lavoro da preservare

---

## DIAGNOSTICA AUTOMATICA

Leggi in ordine (senza commentare durante la lettura):

1. `omega/state.md` — esiste? è valido? ha campi Fase, Score, Piano attivo?
2. `omega/log.md` — ultime 30 righe — cosa è stato fatto l'ultima volta?
3. `omega/plans/` — quanti piani esistono? quali sono IN_PROGRESS?
4. `omega/autopilot-state.md` — esiste? stato ACTIVE/PAUSED/COMPLETE?
5. Struttura `src/` o equivalente — quanti file esistono?
6. `package.json` — build funziona? (`npm run build` nel piano se necessario)

Poi mostra la diagnosi:

```
╔══════════════════════════════════════════════════════════╗
║  DIAGNOSI OMEGA                                          ║
╠══════════════════════════════════════════════════════════╣
║  state.md:    [✅ valido / ⚠️ parziale / ❌ mancante]    ║
║  log.md:      [✅ attivo / ⚠️ vuoto / ❌ mancante]       ║
║  Piani:       [N totali — N in progress — N completi]    ║
║  Autopilot:   [ACTIVE/PAUSED/COMPLETE/assente]           ║
║  Codice:      [N file in src/]                           ║
╠══════════════════════════════════════════════════════════╣
║  PROBLEMA RILEVATO: [descrizione problema principale]    ║
╠══════════════════════════════════════════════════════════╣
║  [R] Recovery automatica — omega propone fix             ║
║  [M] Manuale — mostrami i dettagli                       ║
║  [RESET] Reset completo omega/ (chiede conferma)         ║
╚══════════════════════════════════════════════════════════╝
```

---

## SCENARI DI RECOVERY

### Scenario A — state.md mancante o corrotto

```
Problema: omega/state.md non trovato o non leggibile.
Soluzione:
1. Leggi omega/PRD.md + omega/MVP.md per capire il progetto
2. Leggi omega/plans/ per capire la fase attuale
3. Ricostruisci omega/state.md dal contenuto disponibile
4. Mostra il file ricostruito e chiedi conferma prima di salvare
```

### Scenario B — Piano bloccato (step incompleti ma non avanzabili)

```
Problema: piano IN_PROGRESS con step [x] ma stato non aggiornato,
          oppure step [ ] che dipendono da codice non più esistente.
Soluzione:
1. Leggi il piano problematico per intero
2. Confronta ogni step con lo stato reale del codice
3. Proponi: marcare step come [x] se già implementati, oppure
            rimuovere step obsoleti con motivazione
4. Aggiorna stato piano → COMPLETE o crea nuovo piano da dove ci si era fermati
```

### Scenario C — Build rossa permanente (loop STOP)

```
Problema: build-checker STOP attivato, errori che non si risolvono.
Soluzione:
1. Leggi gli ultimi errori dal log
2. Identifica la categoria: TypeScript errors / import errors / runtime errors
3. Proponi approccio sistematico:
   - TypeScript: isola gli errori per file, risolvi dal più dipendente al meno
   - Import: verifica che i file referenziati esistano
   - Runtime: riduci al componente minimo che riproduce l'errore
4. NON usare `// @ts-ignore` come fix — risolvi il tipo reale
5. Se irrisolvibile: proponi modalità baseline (vedi omega-build-checker)
```

### Scenario D — Documenti omega disconnessi dal codice reale

```
Problema: MVP.md/PRD.md descrivono funzionalità che il codice non ha,
          o il codice ha feature non documentate.
Soluzione:
1. Leggi PRD.md per la lista RF (requisiti funzionali)
2. Cerca nel codice le implementazioni di ogni RF
3. Classifica: [IMPLEMENTATA / PARZIALE / MANCANTE / NON PIÙ NECESSARIA]
4. Proponi: aggiornare PRD.md per riflettere la realtà, oppure implementare le mancanti
5. Chiama omega-context-updater per sincronizzare state.md
```

### Scenario E — "Ricomincia da zero" (utente vuole reset)

```
ATTENZIONE: prima di cancellare qualsiasi cosa, verifica se c'è
lavoro che vale la pena preservare.

Mostra all'utente:
- Quanti file di codice esistono in src/ (con LoC approssimative)
- Quanti piani omega/ sono stati completati
- Ultima data di attività dal log

Chiedi:
[A] Reset solo omega/ (preserva il codice)
[B] Reset completo (omega/ + src/) — richiede doppia conferma
[C] Annulla

Per [A]: elimina omega/*.md e omega/plans/ ma NON omega/design-system.md
         (il design system è prezioso da mantenere)
Per [B]: solo con doppia conferma esplicita ("CONFERMO RESET COMPLETO")
```

---

## REGOLE ASSOLUTE

1. **Mai cancellare** file senza mostrare prima cosa verrà eliminato
2. **Mai riscrivere** documenti omega senza confronto con il codice reale
3. **Mai usare** `// @ts-ignore` o `any` come soluzione a errori TypeScript
4. **Sempre proporre** prima di agire — omega-debug mostra il piano, l'utente approva
5. Se il problema è irrisolvibile in autonomia → chiedi all'utente informazioni specifiche
