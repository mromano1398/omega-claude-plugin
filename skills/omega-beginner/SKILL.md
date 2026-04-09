---
name: omega-beginner
description: Use when the user is not a developer or has no technical background. Triggered by vague language ("voglio fare un sito", "ho un'idea", "non so da dove partire"), confusion at technical terms, or explicit "non so programmare". Replaces the standard wizard with a 3-question flow and pre-built profiles.
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

## FLUSSO BEGINNER (3 domande, NON 8)

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
[C] I miei clienti — persone esterne che si registrano
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

## SCELTA TIER SEMPLIFICATA

Dopo le 3 domande, omega propone automaticamente un tier in linguaggio semplice:

```
Che aspetto vuoi per il tuo [sito/app]?

[SEMPLICE] — Pulito e chiaro. Funziona bene, zero fronzoli.
             (es. strumenti gestionali, lavoro interno)

[BELLO] — Curato e moderno. Piacevole da usare su telefono.
          (es. app per clienti, vetrina professionale)

[WOW] — Impatto visivo forte. Animazioni, stile cinematografico.
        (es. portfolio, landing page premium)

[3D] — Esperienza interattiva immersiva. Grafica tridimensionale.
       (es. showcase di prodotti, esperienze creative)
```

**Mappa interna:** SEMPLICE→Tier1, BELLO→Tier2, WOW→Tier3, 3D→Tier4

---

## STRATEGY.md — Generazione semplificata (NON chiama omega-product-strategy)

omega-beginner NON chiama omega-product-strategy (troppo tecnico per principianti).
Dopo le 3 domande e la scelta tier, genera direttamente `omega/STRATEGY.md` con formato semplificato:

```markdown
# STRATEGY — [nome progetto]
Generato da: omega-beginner

## Obiettivo
[risposta domanda 1 — cosa vuoi costruire]

## Utenti
[risposta domanda 2 — chi lo usa]

## Requisiti Essenziali
[risposta domanda 3 — cosa deve fare per forza]

## Profilo Scelto
[Profilo X — nome] · Stack: [stack] · Costo: [range]

## Note
Strategia business da approfondire in futuro con `[PS]`.
```

Questo garantisce che doc-generator abbia STRATEGY.md disponibile come input.

---

## PROFILI PRECONFEZIONATI — omega sceglie automaticamente

In base alle risposte alle 3 domande, omega sceglie automaticamente uno di questi profili:

### Profilo A — "Sito vetrina"
**Quando:** pubblico, nessuna registrazione, presentare un'attività/prodotto
**Stack:** Astro + Tailwind + Vercel
**Blueprint:** `landing` (chiama `/omega:omega-blueprints` con tipo=landing)
**Costi:** Gratis (Vercel free tier)
**Include:** Home, Chi siamo, Servizi, Contatti, form email, ottimizzazione Google

### Profilo B — "App per la mia attività"
**Quando:** gestionale interno, team piccolo, login richiesto
**Stack:** Next.js + Supabase + Vercel
**Blueprint:** `gestionale` (chiama `/omega:omega-blueprints` con tipo=gestionale)
**Costi:** €0-25/mese
**Include:** login sicuro, gestione utenti, dashboard, dati nel cloud

### Profilo C — "Negozio online"
**Quando:** vendita prodotti/servizi, pagamenti online, clienti esterni
**Stack:** Next.js + Stripe + Supabase + Vercel
**Blueprint:** `e-commerce` (chiama `/omega:omega-blueprints` con tipo=e-commerce)
**Costi:** €0-25/mese + commissioni Stripe (1.5-2.9% + €0.25 per transazione)
**Include:** catalogo, carrello, checkout sicuro, email conferma ordine

### Profilo D — "App mobile"
**Quando:** deve essere su iPhone/Android, usabile ovunque con notifiche push
**Stack:** Expo (React Native) + Supabase
**Blueprint:** `mobile` (chiama `/omega:omega-blueprints` con tipo=mobile)
**Costi:** €99/anno (App Store Apple) + €25 una tantum (Google Play)
**Include:** app iOS + Android, login, dati nel cloud, notifiche push

### Profilo E — "Tool solo per me"
**Quando:** uso personale, nessun utente esterno
**Stack:** Next.js locale o script Python
**Blueprint:** `gestionale` (versione semplificata, singolo utente)
**Costi:** Gratis (gira sul tuo computer) o ~€5/mese (Vercel)
**Include:** interfaccia semplice, dati locali o nel cloud

### Profilo F — "Portfolio / Showcase"
**Quando:** portfolio professionale, showcase progetti, CV interattivo
**Stack:** Astro o Next.js + animazioni (Framer Motion o GSAP) + Vercel
**Blueprint:** `landing` (con sezioni portfolio/gallery)
**Costi:** Gratis
**Include:** gallery lavori, about, contatti, animazioni curate, ottimizzazione SEO

---

## PRESENTAZIONE PIANO — Formato beginner

In modalità beginner, i piani si mostrano così (NON con checkbox tecnici):

```
COSA FAREMO — [nome progetto]

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
Ho creato la pagina iniziale — puoi già vederla qui: [link staging]

Sto lavorando su: il sistema di login per i tuoi utenti

Prossimo passo: la pagina dove visualizzi i tuoi clienti

Ho trovato un piccolo problema con il modulo di contatto
(il pulsante "Invia" non funzionava su telefono).
L'ho già corretto — tutto ok ora.
```

---

## GLOSSARIO INLINE

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
| SSL/HTTPS | il lucchetto di sicurezza nella barra del browser |

---

## DOMANDE FREQUENTI BEGINNER

**"Quanto mi costerà?"**
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

## SCELTA STACK (interna, non mostrata al beginner)

Dopo la scelta del profilo, omega chiama internamente `/omega:omega-stack-advisor` per raffinare lo stack del profilo in base a eventuali vincoli dichiarati alla Domanda 3.

**Il BEGINNER NON vede il menu [ALT] né [CUSTOM]** di omega-stack-advisor — vede solo il profilo preconfezionato con linguaggio semplice (es. "uso Supabase per salvare i tuoi dati nel cloud").

---

## GENERAZIONE DOCUMENTI

Dopo le 3 domande + scelta tier + scelta profilo:
→ Chiama `/omega:omega-doc-generator` per generare `CLAUDE.md` + documenti `omega/`

Il `CLAUDE.md` generato mantiene tutte le sezioni tecniche (serve a Claude Code per lavorare correttamente) ma usa linguaggio semplificato.

---

## PASSAGGIO A MODALITÀ STANDARD

Se durante il progetto l'utente mostra competenza tecnica crescente, omega può offrire:

```
Vedo che ti stai familiarizzando con il progetto.
Vuoi vedere i dettagli tecnici di quello che stiamo costruendo?

[Sì, mostrami tutto] → passa a omega standard
[No grazie, continua così] → rimani in beginner mode
```
