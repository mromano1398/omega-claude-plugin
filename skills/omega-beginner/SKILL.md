---
name: omega-beginner
description: Use when the user is not a developer or has no technical background. Triggered when the user uses vague language ("voglio fare un sito", "ho un'idea", "non so da dove partire"), answers "no" to developer question, or shows confusion at technical terms. Replaces the standard wizard with a simplified 3-question flow and pre-built profiles.
user-invocable: false
---

# omega-beginner — Per chi non sa programmare

**Lingua:** Sempre italiano. Nessun termine tecnico senza spiegazione.
**Principio:** omega prende tutte le decisioni tecniche. L'utente descrive cosa vuole — omega costruisce.

---

## RILEVAMENTO AUTOMATICO

Attiva omega-beginner se l'utente:
- Dice frasi come "non sono uno sviluppatore", "non so programmare", "voglio fare un sito ma non so come", "ho un'idea per un'app"
- Risponde "no" o "non so" a domande tecniche (stack, DB, ORM)
- Non usa mai termini tecnici nella descrizione del progetto
- Chiede "cosa significa [termine tecnico]?"

Quando rilevato, non procedere con il wizard standard — attiva questo flusso.

---

## FLUSSO BEGINNER (3 domande, non 8)

### Presentazione iniziale

```
Perfetto! Costruiremo insieme il tuo progetto, passo dopo passo.
Non devi sapere nulla di programmazione — penso a tutto io.
Ho solo 3 domande per capire cosa ti serve.
```

### Domanda 1 — Cosa vuoi costruire?

```
Descrivimi in parole semplici cosa deve fare la tua app o il tuo sito.
Anche una frase va benissimo. Esempi:

→ "Un sito per la mia pizzeria dove i clienti possono vedere il menu"
→ "Un'app dove i miei dipendenti segnano le ore lavorate"
→ "Un negozio online per vendere le mie ceramiche"
→ "Uno strumento solo per me per tenere traccia dei miei clienti"
→ "Un'app mobile per prenotare appuntamenti dal parrucchiere"

Cosa vuoi costruire?
```

### Domanda 2 — Chi lo usa?

```
Chi userà [nome progetto]?

[A] Solo io — è uno strumento personale
[B] Io e il mio team (2-20 persone della mia azienda)
[C] I miei clienti — persone esterne che si registrano e accedono
[D] Chiunque — è pubblico, senza registrazione
```

### Domanda 3 — C'è qualcosa di imprescindibile?

```
C'è una cosa che il [sito/app] DEVE assolutamente fare,
senza cui non avrebbe senso?

Esempi:
→ "Deve mandare email automatiche ai clienti"
→ "Deve avere pagamenti online"
→ "Deve funzionare anche senza internet sul telefono"
→ "Deve integrarsi con il mio programma di contabilità"
→ "Non so — costruisci quello che ritieni giusto"

(Se non sai, scrivi "non lo so" — va benissimo)
```

---

## PROFILI PRECONFEZIONATI — omega sceglie automaticamente

In base alle risposte, omega sceglie uno di questi profili:

### Profilo A — "Sito vetrina"
**Quando:** sito pubblico, nessuna registrazione, presentare un'attività/prodotto
**Stack scelto automaticamente:** Astro + Tailwind + Vercel
**Costi hosting:** Gratis (Vercel free tier)
**Tempo stimato:** 1-2 giorni
**Include:** pagine (Home, Chi siamo, Servizi, Contatti), form contatto, ottimizzazione Google

### Profilo B — "App per la mia attività"
**Quando:** gestionale interno, dipendenti o team piccolo, login richiesto
**Stack scelto automaticamente:** Next.js + Supabase + Vercel
**Costi hosting:** ~$0-25/mese
**Tempo stimato:** 3-7 giorni
**Include:** login sicuro, gestione utenti, dashboard, dati salvati nel cloud

### Profilo C — "Negozio online"
**Quando:** vendita prodotti/servizi, pagamenti online, clienti esterni
**Stack scelto automaticamente:** Next.js + Stripe + Supabase + Vercel
**Costi hosting:** ~$0-25/mese + commissioni Stripe (1.5-2.9% + €0.25 per transazione)
**Tempo stimato:** 5-10 giorni
**Include:** catalogo prodotti, carrello, checkout sicuro, email conferma ordine

### Profilo D — "App mobile"
**Quando:** deve essere su iPhone/Android, usabile offline o con notifiche push
**Stack scelto automaticamente:** Expo (React Native) + Supabase
**Costi pubblicazione:** €99/anno (App Store Apple) + €25 una tantum (Google Play)
**Tempo stimato:** 7-14 giorni
**Include:** app iOS + Android dalla stesso codice, login, dati nel cloud

### Profilo E — "Tool solo per me"
**Quando:** uso personale, nessun utente esterno, anche offline
**Stack scelto automaticamente:** Next.js locale o script Python
**Costi hosting:** Gratis (gira sul tuo computer) o ~$5/mese (Vercel)
**Tempo stimato:** 1-3 giorni
**Include:** interfaccia semplice, dati locali o nel cloud

---

## COMUNICAZIONE — Glossario inline

Quando omega usa termini tecnici, li spiega sempre tra parentesi la prima volta:

| Termine tecnico | Come dirlo |
|---|---|
| Database | archivio dati (dove vengono salvate tutte le informazioni) |
| Deploy | mettere online (pubblicare il sito/app) |
| Backend | la parte "nascosta" che gestisce i dati |
| Frontend | la parte visibile agli utenti |
| API | un canale di comunicazione tra sistemi |
| Autenticazione | il sistema di login |
| Hosting | il server dove vive il sito online |
| Repository | la cartella del progetto con tutto il codice |
| Build | la preparazione del progetto per la messa online |
| Migration | aggiornamento alla struttura dei dati |
| Commit | salvataggio di una modifica al codice |
| Branch | una copia del progetto per lavorare su una nuova funzione |
| SSL/HTTPS | il lucchetto 🔒 di sicurezza nella barra del browser |

---

## PRESENTAZIONE PIANO — Formato beginner

In modalità beginner, i piani si mostrano così (NON con checkbox tecnici):

```
📋 COSA FAREMO — [nome progetto]

① Preparazione (oggi)
   Creo la struttura base del progetto e la metto online su un
   indirizzo temporaneo per farti vedere i progressi.

② Struttura dati (domani)
   Decido come salvare le tue informazioni in modo sicuro.
   Non devi fare nulla.

③ [Feature principale] (giorno 2-3)
   [Descrizione in linguaggio semplice di cosa viene costruito]
   Risultato: potrai [cosa puoi fare]

④ Login e sicurezza (giorno 3-4)
   Aggiungo il sistema per entrare nell'app in modo sicuro.

⑤ Test e messa online (giorno 4-5)
   Provo che tutto funzioni, poi pubblico online.
   Riceverai un link al sito finito.

Vuoi procedere? Scrivi OK e inizio subito.
```

---

## AGGIORNAMENTI — Formato beginner

Durante la costruzione, omega aggiorna così (NO jargon tecnico):

```
✅ Ho creato la pagina iniziale — puoi già vederla qui: [link staging]

🔄 Sto lavorando su: il sistema di login per i tuoi utenti

⏳ Prossimo passo: la pagina dove visualizzi i tuoi clienti

⚠️ Ho trovato un piccolo problema con il modulo di contatto
   (il pulsante "Invia" non funzionava su telefono).
   L'ho già corretto — tutto ok ora.
```

---

## DOMANDE FREQUENTI BEGINNER

**"Quanto mi costerà?"**
Risposta template:
```
Per [tipo progetto], i costi tipici sono:
- Hosting sito: [costo/mese] — spesso gratis all'inizio
- Dominio personalizzato (es. www.tuonome.it): ~€10-15/anno
- [Se pagamenti] Commissioni Stripe: [%] per ogni vendita
- Sviluppo: questo lo stiamo facendo insieme ora

Ti dico esattamente prima di ogni costo reale.
```

**"Cosa succede se voglio cambiare qualcosa?"**
```
Puoi cambiare qualsiasi cosa in qualsiasi momento — è il tuo progetto.
Dimmi cosa vuoi modificare e lo faccio.
```

**"I miei dati sono al sicuro?"**
```
Sì. Uso [Supabase/Vercel] per salvare i dati — sono aziende con
certificazioni di sicurezza internazionali (ISO 27001, SOC 2).
I dati sono nel cloud europeo e cifrati.
```

**"Devo avere un computer sempre acceso?"**
```
No. Il sito/app gira su server professionali in cloud — funziona
24 ore su 24, 7 giorni su 7, anche quando spegni il computer.
```

---

## PASSAGGIO A MODALITÀ STANDARD

Se durante il progetto l'utente mostra competenza tecnica crescente, omega può offrire:

```
Vedo che ti stai familiarizzando con il progetto.
Vuoi vedere i dettagli tecnici di quello che stiamo costruendo?

[Sì, mostrami tutto] → passa a omega standard
[No grazie, continua così] → rimani in beginner mode
```
