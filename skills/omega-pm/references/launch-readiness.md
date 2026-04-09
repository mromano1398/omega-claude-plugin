# Launch Readiness — Checklist Pre-Lancio

## Dashboard PM — Vista aggregata

Quando invocata, leggi `omega/state.md`, `omega/log.md` (ultime 30 righe), `omega/PRD.md`, `omega/roadmap.md` e genera questo report:

```
╔══════════════════════════════════════════════════════════════╗
║  STATO PROGETTO — [nome]              Aggiornato: [data]     ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  🟢/🟡/🔴  STATO GENERALE: [VERDE / ATTENZIONE / CRITICO]   ║
║                                                              ║
║  📅 FASE CORRENTE: [nome fase in linguaggio business]        ║
║  🎯 OBIETTIVO FASE: [cosa stiamo cercando di completare]     ║
║  📆 DATA LANCIO PREVISTA: [data o "non definita"]           ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  📊 AVANZAMENTO                                              ║
║  ████████░░░░░░░░  [N]% completato                          ║
║                                                              ║
║  ✅ Completato: [lista feature completate in linguaggio biz] ║
║  🔄 In corso:   [cosa si sta costruendo ora]                 ║
║  ⏳ Da fare:    [cosa manca — fase 2, 3...]                  ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  ⚠️ RISCHI ATTIVI                                            ║
║  [N] rischi — vedi dettaglio sotto                           ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  🚀 PRONTO AL LANCIO?   [SÌ / NO — mancano N punti]         ║
╚══════════════════════════════════════════════════════════════╝
```

## Checklist Lancio Completa

```markdown
## Checklist Lancio — [nome progetto]
Data verifica: [data]

### ✅ FUNZIONALITÀ
- [ ] Tutte le funzionalità del MVP sono completate e testate
- [ ] Gli utenti beta/test hanno provato il sistema
- [ ] I flussi principali funzionano da inizio a fine
- [ ] I casi di errore mostrano messaggi comprensibili agli utenti

### ✅ DATI E SICUREZZA
- [ ] I dati degli utenti sono protetti (verifica sicurezza completata)
- [ ] Il sistema rispetta il GDPR (privacy policy, consenso cookie se necessario)
- [ ] Solo le persone autorizzate possono accedere alle sezioni riservate
- [ ] I backup automatici sono configurati e testati

### ✅ PERFORMANCE
- [ ] Il sito carica in meno di 3 secondi (pagina principale)
- [ ] Il sistema regge il numero previsto di utenti simultanei

### ✅ INFRASTRUTTURA
- [ ] Il dominio è configurato e punta al sistema corretto
- [ ] Il certificato SSL (lucchetto 🔒) è attivo
- [ ] C'è un sistema di monitoraggio che avvisa in caso di problemi
- [ ] È stato testato il piano di emergenza (cosa fare se il sito va giù)

### ✅ COMUNICAZIONE
- [ ] Il team di supporto sa come gestire le prime richieste utenti
- [ ] È pronto un piano di comunicazione per il lancio
- [ ] I changelog/note di rilascio sono scritti

### ✅ LEGALE/COMPLIANCE (se applicabile)
- [ ] Privacy policy aggiornata e accessibile
- [ ] Termini di servizio approvati dal legale
- [ ] Cookie banner configurato (se analytics/tracking)

## Risultato
Punti completati: [N]/[M]
Stato: 🟢 PRONTO / 🟡 QUASI PRONTO ([N] punti mancanti) / 🔴 NON PRONTO
```

## Timeline Visiva

```
TIMELINE — [nome progetto]
Oggi: [data]

[data passata] ●━━━━━━━━━━ ① FONDAMENTA ━━━━━━━━━━● [data] ✅
[data]         ●━━━━━━━━━━ ② COSTRUZIONE ━━━━━━━━━━━━━━━━━━● [data prevista]
                                          │ CI TROVIAMO QUI
[data prevista] ●━━━━━━━━━━ ③ TEST & VERIFICA ━━━━━━━━━━● [data prevista]
[data prevista] ● ④ LANCIO
```
