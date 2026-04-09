# Test Report — Flusso End-to-End omega
Data: 2026-04-09
Scenario: SaaS B2C nuovo progetto, DEV, Tier 2
Progetto simulato: tool di project management con team e abbonamento mensile (Next.js)

---

## Flusso tracciato

1. **omega/SKILL.md — STEP 0 + STEP 1** — Orientamento silenzioso: cartella vuota rilevata → nessun BLUEPRINT.md, nessun omega/, nessun CLAUDE.md → percorso MODALITÀ A (NUOVO)
2. **omega/SKILL.md — PERCORSO A** — Attiva catena: wizard → tier-system → blueprints → doc-generator → COSTRUZIONE
3. **omega-wizard/SKILL.md — PERCORSO: PROGETTO NUOVO** — Step 0: cartella vuota confermata. Step 1: descrizione progetto raccolta. Step 2: tier scelto (Tier 2 PROFESSIONALE). Step 3: domande adattive (max 4 per DEV). Step 3.5: stack-advisor. Step 4: proposta unica. Step 5: blueprints + doc-generator.
4. **omega-tier-system/SKILL.md** — Configurazione Tier 2 PROFESSIONALE (shadcn + Framer Motion, palette personalizzata)
5. **omega-stack-advisor/SKILL.md + references/recommendations.md (sezione SaaS B2C)** — Stack consigliato: Next.js + Supabase + Prisma + Stripe + Resend + Vercel
6. **omega-blueprints/SKILL.md + references/saas.md** — Blueprint SaaS B2C selezionato: struttura cartelle, schema DB multi-tenant, Stripe integration, onboarding flow
7. **omega-doc-generator/SKILL.md** — Generazione: CLAUDE.md → MVP.md → PRD.md → design-system.md → roadmap.md → state.md → README.md
8. **omega/SKILL.md — FASE 1 FONDAMENTA** — Scaffolding + sicurezza automatica embedded (security headers, rate limiting auth, Zod, IDOR protection)
9. **omega-security/SKILL.md (prime 60 righe)** — Verifica integrazione: sicurezza Fase 1 è automatica (non richiede invocazione manuale); omega-security completo viene invocato in Fase 3

---

## Problemi trovati

### BLOCCANTE — 2 trovati

**BLOCCANTE-1: Riferimento a sezione inesistente in omega/SKILL.md**
- File: `skills/omega/SKILL.md`, riga 224
- Testo esatto: `"Poi genera la pagina modello: src/app/(dashboard)/esempio/page.tsx (vedi sezione GENERAZIONE DOCUMENTI in omega-wizard)."`
- Problema: La sezione "GENERAZIONE DOCUMENTI" **non esiste** in `omega-wizard/SKILL.md`. Il file wizard non contiene alcuna sezione con quel titolo. Claude cercherebbe questa sezione, non la troverebbe, e rimarrebbe bloccato o genererebbe il componente in modo arbitrario.
- Impatto: Lo step [E] di FONDAMENTA (Layout + componenti base) non può essere completato correttamente.

**BLOCCANTE-2: omega-stack-advisor assente da PERCORSO A in omega/SKILL.md**
- File: `skills/omega/SKILL.md`, righe 106-113
- Il PERCORSO A elenca 4 step: wizard → tier-system → blueprints → doc-generator
- omega-stack-advisor **non compare in PERCORSO A** nonostante sia un passaggio obbligatorio (Step 3.5) in omega-wizard
- Problema: Un utente che legge il PERCORSO A pensa che lo stack advisor sia opzionale o non esista nella pipeline. Un'implementazione che segue solo PERCORSO A salta lo stack advisor e consegna una proposta senza raccomandazione motivata.
- Impatto: Il PERCORSO A in omega.SKILL.md e il flusso interno di omega-wizard sono disallineati. Se Claude segue omega come punto di autorità e non legge per intero omega-wizard, lo stack advisor viene saltato.

---

### AMBIGUO — 4 trovati

**AMBIGUO-1: Trigger multi-tenant per "SaaS con team" è ambiguo per B2C**
- File: `skills/omega-wizard/SKILL.md`, righe 97-106
- Il trigger automatico multi-tenant si attiva se l'utente menziona "più aziende" / "clienti diversi" / "organizzazioni" / "B2B"
- Il nostro scenario è "SaaS B2C con team" — team è citato nella richiesta utente, ma non è una delle keyword trigger
- Il blueprint `saas.md` include però già `settings/team/page.tsx`, `TeamInvite`, `memberships` table con `organization_id` — cioè il blueprint SaaS B2C è già multi-tenant di fatto
- Problema: non è chiaro se un SaaS B2C con "gestione team" (es. workspace condivisi tra utenti) debba attivare omega-multitenant o no. La distinzione "organizzazioni B2B" vs "workspace B2C con team" non è documentata.
- Impatto: comportamento dipendente dall'interpretazione del modello — alcuni Claude attiverebbero MT, altri no.

**AMBIGUO-2: omega-tier-system fa 3 domande, omega-wizard mostra 1 sola scelta**
- File: `skills/omega-tier-system/SKILL.md`, righe 23-26 (3 domande esplicite)
- File: `skills/omega-wizard/SKILL.md`, righe 68-83 (mostra 4 opzioni come menu, poi "Chiama omega-tier-system per configurazione completa")
- Problema: il wizard mostra una UI a 4 opzioni e poi dice di "chiamare" omega-tier-system — ma omega-tier-system ha 3 domande proprie. Non è chiaro se le 3 domande vengono poste DOPO che l'utente ha già scelto dal menu del wizard (doppio questionario ridondante) o se le 3 domande del tier-system SOSTITUISCONO la scelta nel wizard.
- Impatto: un utente potrebbe rispondere 2 volte alle stesse domande, o il modello potrebbe saltare una delle due fasi.

**AMBIGUO-3: Ordine di invocazione blueprints vs doc-generator non coerente tra omega e wizard**
- File: `skills/omega/SKILL.md`, riga 249: "FASE 1 — Invoca /omega:omega-blueprints per la struttura base del tipo progetto"
- File: `skills/omega-wizard/SKILL.md`, righe 148-150: Step 5 = "1. Chiama blueprints, 2. Chiama doc-generator → COSTRUZIONE"
- File: `skills/omega/SKILL.md`, PERCORSO A, righe 106-113: Step 3 = blueprints, Step 4 = doc-generator, Step 5 = COSTRUZIONE (quindi blueprints PRIMA di doc-generator)
- Ma in FASE 1 FONDAMENTA (riga 249) blueprints viene invocato DI NUOVO come primo atto della costruzione
- Problema: blueprints viene chiamato due volte? Una volta nel wizard (Step 5) e una volta di nuovo all'inizio di FASE 1? Nessuno dei due file lo chiarisce. Un'implementazione naive chiamerebbe blueprints due volte.

**AMBIGUO-4: Sicurezza Fase 1 "automatica" — cosa significa concretamente**
- File: `skills/omega/SKILL.md`, righe 252-263: elenca 6 elementi di sicurezza come "AUTOMATICA, NON OPT-IN"
- File: `skills/omega-security/SKILL.md`: descrive omega-security come uno skill separato, con flusso audit a 4 assi, checklist pre-lancio, e viene invocato in FASE 3
- Problema: i 6 elementi della Fase 1 (security headers, rate limiting, Zod, IDOR) sono implementazioni di codice concrete che richiedono istruzioni specifiche su DOVE metterle (quale file, quale pattern). La tabella in omega/SKILL.md le elenca ma non spiega come implementarle per Next.js App Router specificamente. Non c'è un riferimento a `security-defaults.md` nel corpo della Fase 1 (c'è solo una riga nella tabella riferimenti a fine file, riga 654).
- Impatto: "automatica" suggerisce che il modello sa cosa fare, ma senza istruzioni concrete potrebbe implementare i security headers nel posto sbagliato (es. in `page.tsx` invece di `next.config.js` o `middleware.ts`).

---

### MANCANTE — 5 trovati

**MANCANTE-1: Nessuna domanda su Stripe/abbonamento nel wizard per SaaS con pagamenti**
- File: `skills/omega-wizard/SKILL.md`, righe 85-105 (domande Step 3)
- Le domande disponibili includono "Modello business?" con opzione "Abbonamento" ma non ci sono domande di follow-up su: piani (quanti? quali limiti?), trial period, seat-based vs flat, necessità Customer Portal.
- Per il nostro scenario (tool SaaS con abbonamento mensile) queste informazioni sono critiche per generare MVP.md e PRD.md corretti. Andrebbero raccolte nel wizard, non lasciate all'omega-payments che viene invocato solo durante COSTRUZIONE.
- Impatto: i documenti omega vengono generati senza specifiche di pricing/piano → PRD incompleto → sprint di sviluppo senza chiarezza sui piani.

**MANCANTE-2: Nessuna menzione di omega-payments nel PERCORSO A o in wizard per SaaS**
- File: `skills/omega/SKILL.md`, PERCORSO A (righe 106-113) e FASE 1-5
- Il blueprint `saas.md` contiene codice Stripe ed è esplicitamente incluso. Le recommendations.md per SaaS B2C elencano Stripe. Ma omega-payments non viene mai invocato automaticamente nel percorso.
- L'utente deve sapere da solo che esiste `[PAY]` dal menu principale.
- Impatto: su un progetto con abbonamento mensile (il nostro scenario esatto), il wizard non segnala mai proattivamente che servirà omega-payments.

**MANCANTE-3: La sezione "pagina modello" manca un template o riferimento reale**
- File: `skills/omega/SKILL.md`, riga 224
- Il sistema chiede di generare `src/app/(dashboard)/esempio/page.tsx` ma non fornisce il contenuto né un template. Il riferimento è a "sezione GENERAZIONE DOCUMENTI in omega-wizard" che non esiste (vedi BLOCCANTE-1). Non c'è neanche un riferimento a `omega-doc-generator/references/templates.md` per questo file.
- Impatto: ogni Claude genererebbe una pagina modello diversa — inconsistenza tra progetti.

**MANCANTE-4: Nessun rollback plan per la cartella omega/ se il wizard viene interrotto**
- File: `skills/omega-doc-generator/SKILL.md`
- Il processo di generazione documenti non specifica cosa fare se l'utente interrompe a metà generazione: `omega/` esiste parzialmente, alcuni documenti ci sono, altri no.
- Problema: alla prossima invocazione di `/omega`, il RILEVAMENTO PERCORSO troverebbe `omega/` esistente ma senza `state.md` → nessun percorso copre questo caso ibrido (non è NUOVO, non è RIPRENDI).
- Impatto: stato inconsistente non gestito.

**MANCANTE-5: Nessuna indicazione su come gestire "team" nella descrizione SaaS B2C**
- Il blueprint `saas.md` ha `settings/team/page.tsx` e `TeamInvite` component, ma non chiarisce la relazione tra "team" B2C (utenti all'interno dello stesso workspace) e "organization" multi-tenant B2B.
- Il nostro scenario (project management con team) potrebbe essere sia un SaaS B2C con workspace condivisi (ogni utente invita colleghi nello stesso account) sia un SaaS B2B con organizzazioni separate.
- Nessun file spiega la distinzione o fa una domanda esplicita al riguardo.

---

### MINORE — 4 trovati

**MINORE-1: OWASP Top 10:2025 — la versione 2025 non è ancora ufficialmente pubblicata**
- File: `skills/omega-security/SKILL.md`, righe 10 e 25
- Il link punta a `https://owasp.org/Top10/2025` — OWASP 2025 è ancora in draft alla data del test. L'URL potrebbe non esistere o restituire contenuto provvisorio.
- Impatto basso ma potrebbe causare confusione se Claude tenta di fetch-docs su questo URL.

**MINORE-2: Il formato proposta in omega-wizard (Step 4) elenca "Sicurezza" come campo fisso**
- File: `skills/omega-wizard/SKILL.md`, riga 139: `║  Sicurezza: [livello — sempre inclusa in Fase 1]          ║`
- Non c'è un elenco di possibili valori per "[livello]" — ogni Claude scriverà qualcosa di diverso (es. "base", "standard", "OWASP", "inclusa"). Non è un campo con valori definiti.
- Impatto: inconsistenza estetica minore.

**MINORE-3: `omega/state.md` — formato data `last_updated` non specificato**
- File: `skills/omega-doc-generator/SKILL.md`, riga: "omega/state.md deve avere sempre un campo `last_updated` valido"
- Il template in `references/templates.md` usa `[timestamp]` ma non specifica il formato (ISO 8601? data italiana? con/senza timezone?).
- Impatto: inconsistenza tra sessioni se Claude cambia formato.

**MINORE-4: La raccomandazione SaaS B2C usa Supabase Auth, ma il wizard non chiede se l'utente ha già un account Supabase**
- File: `skills/omega-stack-advisor/references/recommendations.md`, sezione SaaS B2C
- La raccomandazione assume Supabase ma non raccoglie la preferenza "hai già un account Supabase?" nelle domande del wizard.
- Le domande disponibili (Step 3) includono "Tecnologie che già conosci" ma questa è generica.
- Impatto: se l'utente non ha Supabase, la proposta impone un onboarding a una nuova piattaforma senza avvisarlo.

---

## Cosa funziona bene

1. **Architettura modulare chiara**: il sistema di sub-skills è ben organizzato — ogni skill ha una responsabilità definita e i trigger sono espliciti. Un DEV capisce immediatamente la struttura.

2. **Blueprint SaaS B2C è completo e production-ready**: `references/saas.md` contiene struttura cartelle, schema DB, codice Stripe, feature gates, trial management, onboarding flow — tutto ciò che serve per partire. È il documento più ricco e utile del sistema.

3. **Sicurezza Fase 1 automatica è una scelta eccellente**: incorporare security headers, rate limiting e IDOR protection di default (non opt-in) è la decisione più importante del sistema. Elimina la classe più comune di errori per principianti e intermedi.

4. **Separazione PERCORSO A/B/C/D**: il sistema di rilevamento del contesto (cartella vuota vs progetto esistente vs riprendi) è logico e gestisce tutti i casi reali. La tabella di corrispondenza omega ↔ omega-wizard è utile.

5. **BEGINNER detection proattiva**: il rilevamento automatico del linguaggio non tecnico prima di ogni altra cosa è una safety net importante — impedisce che un non-developer venga sommisso da flusso DEV completo.

6. **omega-stack-advisor con raccomandazioni per tipo**: la separazione tra SaaS B2C, B2B, Gestionale, Mobile ecc. con stack diversi e pattern critici specifici è corretta e utile. La nota RLS/Prisma in recommendations.md è particolarmente preziosa.

7. **Sistema piani e log**: il formato `omega/plans/` con checkbox, rollback e stato IN_PROGRESS/COMPLETE è un ottimo sistema di tracciabilità — dà continuità tra sessioni.

8. **Automazioni build-checker obbligatorie**: la regola "ogni 3 file modificati + immediatamente su file critici" è chiara e prevenirà build rotti silenziosi.

---

## Raccomandazioni prioritizzate

### Priorità 1 — Fix bloccanti (da fare prima di qualsiasi test reale)

1. **Rimuovere o correggere il riferimento a "sezione GENERAZIONE DOCUMENTI in omega-wizard"** (omega/SKILL.md, riga 224): o creare la sezione in omega-wizard con il template della pagina modello, o sostituire il riferimento con un link a `omega-doc-generator/references/templates.md`.

2. **Aggiungere omega-stack-advisor al PERCORSO A** (omega/SKILL.md, riga 106-113): inserire come Step 1.5 o come sub-step di wizard, e allineare la descrizione con quanto già fa omega-wizard internamente.

### Priorità 2 — Chiarire ambiguità strutturali

3. **Chiarire il doppio invocazione di omega-blueprints**: specificare esplicitamente che il blueprints in wizard Step 5 è per la definizione architetturale nella documentazione, e che in FASE 1 il blueprints viene usato per la struttura del codice — oppure unificare i due punti in uno.

4. **Risolvere la sovrapposizione tier-system/wizard Step 2**: specificare che le 3 domande di omega-tier-system sono le domande che il wizard già fa — cioè omega-tier-system non va ri-interrogato separatamente ma è già embedato nel wizard. Oppure dire esplicitamente che il wizard fa solo la scelta rapida e tier-system fa il deep dive.

5. **Chiarire trigger multi-tenant per SaaS B2C con "team"**: aggiungere alla lista di keyword trigger anche "workspace condiviso" / "team nella stessa app" con una nota che chiarisca: B2C con team → usa saas.md blueprint (già incluso), B2B multi-tenant → attiva omega-multitenant.

### Priorità 3 — Colmare i mancanti

6. **Aggiungere omega-payments al PERCORSO A per tipo SaaS**: se tipo=SaaS e modello business include abbonamento, segnalare proattivamente nel wizard Step 3 che sarà necessario omega-payments e raccogliere info minime (piani, trial period).

7. **Gestire lo stato parziale omega/**: aggiungere al doc-generator una regola per il caso in cui omega/ esiste ma state.md non esiste — proporre di completare la generazione documenti mancanti o ricominciare.

8. **Aggiungere domanda esplicita "workspace team B2C vs organizzazioni B2B"**: è la distinzione più importante per un SaaS con team e influenza tutta l'architettura. Va raccolta nel wizard Step 3 per tutti i progetti di tipo SaaS.

### Priorità 4 — Migliorie minori

9. **Creare template per pagina modello** `src/app/(dashboard)/esempio/page.tsx` in `omega-doc-generator/references/templates.md` — almeno uno scheletro standard con layout, Breadcrumbs, DataTable e un form.

10. **Definire valori possibili per il campo "Sicurezza" nella proposta Step 4** — es. "Base (Fase 1 automatica)" / "Avanzata (OWASP Fase 3)" / "Enterprise (GDPR + audit log)" — per rendere il campo informativo anziché decorativo.

11. **Verificare e aggiornare il link OWASP Top 10:2025** una volta che la versione ufficiale è pubblicata, o usare il link stabile 2021 nel frattempo.

12. **Aggiungere formato data esplicito per `last_updated`** in state.md — raccomandato ISO 8601 con timezone UTC.
