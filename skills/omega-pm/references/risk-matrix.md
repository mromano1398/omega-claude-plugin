# Risk Matrix — Analisi Rischi in Linguaggio Business

## Formato analisi rischi

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

## Conversione rischi tecnici → business

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

## Traduzione terminologia tecnica → business

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

## Report per stakeholder

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

## Sprint Report — Formato PM

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
