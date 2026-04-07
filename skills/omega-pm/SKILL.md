---
name: omega-pm
description: Use when a non-technical project manager or stakeholder needs a business-level status view, launch readiness assessment, risk summary, or sprint report in plain language without technical jargon. Triggered by [PM] menu option or when user asks about status, risks, or timeline in business terms.
user-invocable: false
---

# omega-pm — Vista Business · Status · Rischi · Lancio

**Lingua:** Sempre italiano.
**Principio:** Nessun termine tecnico senza spiegazione. Il PM non sa cosa sia un advisory lock o una migration — sa se il progetto è in ritardo, quali rischi ci sono, e quando si lancia.

---

## DASHBOARD PM — Vista aggregata

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

---

## TRADUZIONE TECNICO → BUSINESS

Usa sempre queste traduzioni quando parli con un PM:

| Termine tecnico | Come dirlo al PM |
|---|---|
| Migration DB | Aggiornamento struttura dati (sicuro, reversibile) |
| Advisory lock | Protezione dalle operazioni doppie simultanee |
| Build fallita | Il sistema non si compila — blocca il deploy |
| TypeScript errors | Errori di codice che impediscono il funzionamento |
| Integration test | Verifica automatica che le funzionalità funzionino end-to-end |
| Audit sicurezza | Controllo vulnerabilità (come una verifica di sicurezza informatica) |
| OWASP | Standard internazionale di sicurezza web |
| Staging environment | Copia identica del sito reale usata per test finali |
| Server Action | Operazione che gira sul server (non visibile all'utente) |
| Race condition | Due utenti che fanno la stessa cosa simultaneamente → dati corrotti |
| N+1 query | Il sistema fa troppe chiamate al database → lentezza |
| Rollback | Torna alla versione precedente in caso di problemi |
| PR / Pull Request | Proposta di modifica codice che aspetta approvazione |
| Sprint | Periodo di lavoro a tempo (di solito 1-2 settimane) |
| Blocco / Blocker | Impedimento che ferma il lavoro — da risolvere con priorità |

---

## ANALISI RISCHI — Formato business

```markdown
## Rischi Progetto — [data]

### 🔴 CRITICI — Richiedono azione immediata
| Rischio | Impatto | Cosa fare |
|---|---|---|
| [descrizione business] | [conseguenza concreta] | [azione specifica] |

### 🟠 ALTI — Da monitorare questa settimana
| Rischio | Impatto | Chi risolve |
|---|---|---|
| [descrizione] | [conseguenza] | [persona/team] |

### 🟡 MEDI — Da tenere d'occhio
| Rischio | Probabilità | Mitigation |
|---|---|---|
| [descrizione] | [alta/media/bassa] | [cosa previene il rischio] |

### Note
- Ultimo controllo: [data]
- Prossima revisione rischi: [data]
```

### Conversione rischi tecnici → business

Quando omega rileva problemi tecnici, traducili così:

| Problema tecnico trovato | Rischio business |
|---|---|
| Nessun test automatico | Se cambiamo una funzione, non sappiamo se ne rompiamo un'altra → bug in produzione non rilevati |
| Audit sicurezza non fatto | Vulnerabilità non corrette → possibile accesso non autorizzato ai dati |
| Nessun staging environment | I test si fanno direttamente in produzione → utenti reali impattati da bug |
| Dipendenze non aggiornate (npm audit) | Componenti con falle di sicurezza note → conformità GDPR a rischio |
| Nessun backup automatico | Se il server va giù, i dati potrebbero essere persi |
| Build non verde | Il prodotto non funziona nel suo stato attuale — deploy bloccato |
| Advisory lock mancante | Due persone fanno la stessa operazione → dati duplicati o corrotti |
| File sensibili in cloud storage pubblico | Documenti privati accessibili da chiunque con il link |

---

## LAUNCH READINESS — Checklist PM

Prima del lancio, verifica con l'utente questi punti in linguaggio business:

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

---

## SPRINT REPORT — Formato PM

Genera questo report settimanale da `omega/team-state.md` (se esiste) e `omega/log.md`:

```markdown
## Report Settimana [N] — [data inizio] → [data fine]
Progetto: [nome]

### 📦 Consegnato questa settimana
- [feature o fix completata] — [impatto business: cosa può fare ora l'utente]
- [feature] — [impatto]

### 🔄 In corso
- [cosa si sta lavorando] — previsto completamento: [data]

### ⚠️ Problemi e ritardi
- [problema] → [impatto sul timeline] → [soluzione proposta]

### 📅 Prossima settimana
- [cosa prevediamo di completare]

### 🎯 Verso il lancio
Siamo a [N] settimane dal lancio previsto.
Funzionalità rimanenti: [N]
Ritardo stimato: [nessuno / N giorni]
```

---

## TIMELINE VISIVA

Quando il PM chiede "quando finiamo?", genera una timeline in linguaggio business:

```
TIMELINE — [nome progetto]
Oggi: [data]

[data passata] ●━━━━━━━━━━ ① FONDAMENTA ━━━━━━━━━━● [data] ✅
[data]         ●━━━━━━━━━━ ② COSTRUZIONE ━━━━━━━━━━━━━━━━━━● [data prevista]
                                          │ CI TROVIAMO QUI
[data prevista] ●━━━━━━━━━━ ③ TEST & VERIFICA ━━━━━━━━━━● [data prevista]
[data prevista] ● ④ LANCIO
```

---

## REPORT PER STAKEHOLDER

Quando il PM deve presentare lo stato ai superiori o al cliente:

```markdown
# Aggiornamento Progetto [nome] — [data]

## In una riga
[1 frase che descrive lo stato del progetto oggi]

## Progresso
Siamo al [N]% del completamento del MVP.
Funzionalità consegnate: [lista di 3-5 cose concrete che l'utente può già fare]

## Prossime milestone
- [milestone 1]: prevista [data]
- [milestone 2]: prevista [data]
- Lancio: previsto [data]

## Rischi da comunicare
[Solo i rischi critici, in linguaggio business, con lo stato corrente della mitigation]

## Cosa ci serve
[Decisioni o risorse che il PM/cliente deve fornire per non bloccare il lavoro]
```

---

## QUANDO PASSARE A OMEGA STANDARD

`omega-pm` è una vista — non esegue azioni tecniche. Per:
- Pianificare il lavoro tecnico → `/omega:omega` menu principale
- Gestire PR e team developer → `/omega:omega-team`
- Deploy e infrastruttura → `/omega:omega-devops`
- Sicurezza e GDPR → `/omega:omega-security`
