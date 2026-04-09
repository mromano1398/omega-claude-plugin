# Question Trees — Per Tipo Progetto

Domande specifiche per ogni tipo di progetto. Massimo 6 totali incluse le domande base.
Adatta in base a ciò che l'utente ha già detto nella descrizione.

---

## SAAS B2C (tool consumer, produttività personale)

**Domanda tipo-specifica (#6):**
"Il tuo prodotto funziona meglio se usato da soli o se si porta altri amici/colleghi?"
→ Solo: focalizza su onboarding rapido e "aha moment" entro 5 minuti
→ Con altri: product-led virality — ogni utente è un canale di acquisizione

**Domande aggiuntive se non già chiare:**
- "Modello: free trial (X giorni), freemium (piano gratis per sempre), o solo paid?"
  → Trial: definisci cosa sblocca il trial, quando scade, cosa succede dopo
  → Freemium: definisci i limiti del piano free (volume, feature gate)
- "Qual è il 'momento aha' — quando l'utente capisce il valore del prodotto?"
  → Questo diventa il target dell'onboarding
- "Hai già una lista email, community, o follower da cui partire?"
  → Se sì: lancio soft ai beta user → feedback loop prima del pubblico

**Feature da suggerire proattivamente:**
- Onboarding guidato (template, wizard, checklist primo utilizzo)
- Dashboard "empty state" motivante (non pagine bianche)
- Email di attivazione D1/D3/D7 (gli utenti dimenticano)
- Upgrade prompt contestuale (mostra al momento giusto, non subito)
- Referral integrato ("invita un amico, ottieni X")
- Public roadmap (costruisce community + riduce churn)
- Trial-to-paid flow ottimizzato (feature gate visibile, non muro)

**North Star suggerita:** MRR (Monthly Recurring Revenue) o Weekly Active Users

---

## SAAS B2B / ENTERPRISE

**Domanda tipo-specifica (#6):**
"Chi firma l'acquisto nella tua azienda cliente — il singolo utente o un responsabile/CFO?"
→ Self-serve (utente paga): PLG, trial immediato, upgrade da app
→ Sales-assisted (manager decide): demo flow, case study, pricing su richiesta

**Domande aggiuntive:**
- "Quanti utenti ha tipicamente un'azienda cliente tua? (1-5 / 5-50 / 50+)"
  → Determina: seat-based pricing vs flat rate vs usage-based
- "Il tuo cliente ha bisogno di login con il suo account aziendale (SSO/Google Workspace)?"
  → Sì: Auth.js con SAML, Clerk, o WorkOS — non costruirlo da zero
- "I dati di ogni cliente devono essere separati dagli altri?"
  → Row-level security (Supabase RLS o schema per tenant)

**Feature da suggerire proattivamente:**
- Trial 14 giorni con onboarding email sequence (5 email, non 1)
- Demo mode con dati fittizi (permette sales demo senza account reale)
- Invito team in-app (ogni seat aggiunto = revenue + riduzione churn)
- Admin panel per il manager dell'azienda (visibilità team, billing, SSO)
- Changelog pubblico (mostra che il prodotto evolve — riduce churn)
- SLA page e status page (uptime.betterstack.com — gratis)
- Certificazioni compliance visibili (SOC2, GDPR badge — aumenta conversione enterprise)

**North Star suggerita:** ARR (Annual Recurring Revenue) o NRR (Net Revenue Retention)

---

## E-COMMERCE

**Domanda tipo-specifica (#6):**
"Qual è il tuo AOV (valore medio ordine) stimato e il tuo margine?"
→ AOV basso (<€30): focus su volume, upsell, abbonamento
→ AOV alto (>€100): focus su trust, social proof, assistenza pre-acquisto

**Domande aggiuntive:**
- "Quanti prodotti hai? (1-10 / 10-100 / 100+)"
  → 1-10: landing prodotto con storytelling profondo
  → 100+: ricerca, filtri, SEO prodotto, catalog management
- "Vendi già in altri canali? (Instagram, Amazon, negozio fisico)"
  → Determina: omnichannel inventory, feed prodotti, pixel tracking
- "Hai già una lista email o follower?"
  → Email list > 1k: lancia con offerta early bird
  → Nessuna: strategia acquisizione organica first (SEO + contenuto)

**Feature da suggerire proattivamente:**
- Checkout ottimizzato: 1-page checkout (riduce abbandono del 20-30%)
- Abandoned cart email (70% degli utenti abbandona — recuperane il 15-20%)
- Prodotti correlati / "Spesso comprato insieme" (aumenta AOV +20%)
- Recensioni prodotto con foto (aumenta conversione +15-25%)
- Trust signals: badge sicurezza, garanzia reso, spedizione stimata
- Wishlist con notifica "torna disponibile" o "in sconto"
- Bundle / pack deal (aumenta AOV)
- Loyalty program (aumenta LTV e frequenza riacquisto)
- Instagram/TikTok shop feed (acquisto senza uscire dall'app)
- Chatbot pre-acquisto per domande frequenti (riduce abbandono)

**North Star suggerita:** GMV (Gross Merchandise Volume) o Revenue per Visitor

**CRO checklist obbligatoria (aggiungi al PRD):**
- Immagini prodotto: almeno 4, zoom, video se possibile
- Headline prodotto: beneficio, non solo nome
- CTA: "Aggiungi al carrello" — mai "Compra ora" come primo CTA
- Social proof above the fold: stelle, numero recensioni, "X persone stanno guardando"
- Urgency/scarcity: "Ultimi 3 disponibili" (solo se vero)
- Spedizione gratuita threshold visibile sempre

---

## LANDING PAGE / MARKETING

**Domanda tipo-specifica (#6):**
"Qual è la ONE action che vuoi che il visitatore faccia? (iscriviti / prenota demo / compra / scarica)"
→ Questo è il CTA principale — tutto il resto è rumore da eliminare

**Domande aggiuntive:**
- "Da dove arriverà il traffico? (SEO, ads paid, social, referral, direct)"
  → SEO: keyword research obbligatoria, blog integrato
  → Ads paid: landing dedicata per ogni ad group, tracking pixel da giorno 1
  → Social: Open Graph curato, condivisibilità
- "Hai già testimonianze, case study, o numeri di successo?"
  → Sì: mettili above the fold, non nel footer
  → No: raccoglili prima del lancio (beta user, interviste)
- "È per un lancio (waitlist) o prodotto già disponibile?"
  → Waitlist: countdown + "X persone già iscritte" (social proof)
  → Disponibile: demo video / trial gratuito come CTA secondario

**Feature/sezioni da suggerire proattivamente:**
- Hero: headline formula AIDA o PAS (vedi sotto)
- Social proof immediately visible: loghi clienti, stelle, numero utenti
- Video demo (aumenta conversione del 80% se ben fatto)
- FAQ sezione (riduce l'obiezione più comune)
- Pricing trasparente (nasconderlo riduce le conversioni)
- CTA ripetuto ogni scroll-screen
- Exit intent popup con offer (cattura chi sta uscendo)
- Live chat o chatbot (risponde a obiezioni real-time)
- Blog/contenuto SEO per traffico organico continuo

**Headline formulas (aggiungi a STRATEGY.md):**
- AIDA: Attenzione → Interesse → Desiderio → Azione
  Es: "Stop perdere ore in [problema]. [Prodotto] ti fa [beneficio] in [tempo]."
- PAS: Problema → Agitazione → Soluzione
  Es: "[Problema] ti costa [conseguenza]. Ecco perché [X aziende] usano [prodotto]."
- StoryBrand: Eroe (cliente) ha problema → incontri guida (tu) → piano → successo
  Es: "Come [persona target] ha [beneficio] senza [dolore] usando [prodotto]"

**North Star suggerita:** Conversion Rate (%) o Costo per Lead (CPL)

---

## APP MOBILE (iOS + Android)

**Domanda tipo-specifica (#6):**
"Come monetizzi? Free con ads / Freemium con IAP / Abbonamento mensile/annuale / Paid upfront"
→ Ads: DAU è la metrica, monetizzazione passiva
→ IAP: "aha moment" prima del paywall, non subito
→ Abbonamento: D7 retention è critica — se non rimangono 7 giorni non pagano

**Domande aggiuntive:**
- "Solo iOS, solo Android, o entrambi? Hai preferenza React Native o nativo?"
  → Entrambi con team piccolo: Expo (React Native) — stesso codice
  → Performance critica (giochi, AR): considera nativo
- "Qual è l'onboarding ideale — quanti step prima di vedere il valore?"
  → Regola: max 3 step prima dell'"aha moment"
  → Chiedi solo permessi quando servono (non tutti subito)
- "Push notifications: solo informative o parte del loop di engagement?"
  → Engagement: timing è tutto — studia i pattern di uso prima di inviare

**Feature da suggerire proattivamente:**
- Onboarding: max 3 schermate, skip visibile, valore immediato
- Permessi: chiedi fotocamera/notifiche DOPO che l'utente ha visto il valore
- Offerta paywall: annuale prominente (LTV 2-3x), mensile come fallback
- Widget iOS/Android (aumenta retention e DAU)
- Condivisione in-app (screenshot share, risultati, achievements)
- Deep link (link esterni che aprono direttamente una schermata)
- Offline mode (anche parziale — differenziatore forte)
- App rating prompt: chiedi DOPO successo (non al primo avvio)
- Referral: "Invita amico, entrambi ottengono X"
- Notifiche push ottimizzate: personalizzate per comportamento, non broadcast

**ASO (App Store Optimization) — aggiungi al PRD:**
- Title: keyword principale + brand name
- Subtitle: benefit secondario
- Screenshot: mostrano il valore, non l'UI astratta
- Preview video: primi 3 secondi decidono
- Keywords: ricerca su AppFollow o Sensor Tower

**North Star suggerita:** DAU/MAU ratio (engagement) o MRR (subscription)

---

## GESTIONALE / ERP

**Domanda tipo-specifica (#6):**
"Questo gestionale è per uso interno (un'azienda sola) o lo venderai a più aziende clienti?"
→ Interno: nessun multi-tenant, RBAC semplice, focus su efficienza operativa
→ Più clienti: multi-tenant obbligatorio → attiva omega-multitenant [MT]

**Domande aggiuntive:**
- "Quanti utenti contemporanei massimo? Quali reparti/ruoli?"
  → Determina: RBAC granulare, permessi per sezione
- "Ci sono flussi di approvazione? (es. ordine → approvazione manager → invio)"
  → Sì: workflow engine, notifiche in-app, audit trail
- "Quali dati sono critici? Cosa non può mai andare perso o sbagliare?"
  → Determina: backup strategy, advisory lock, transazioni ACID
- "Si integra con altri sistemi? (fatturazione, ERP esterno, API fornitore)"
  → Sì: valuta API layer separato, webhook in/out, mapping dati

**Feature da suggerire proattivamente:**
- Dashboard KPI con numeri real-time (non solo tabelle)
- Export CSV/Excel/PDF per ogni lista (richiesta universale)
- Ricerca globale (ctrl+K → fuzzy search su tutto)
- Log attività: chi ha fatto cosa e quando (audit trail)
- Notifiche in-app (approvazioni pendenti, scadenze)
- Accesso mobile (anche solo lettura — responsive o PWA)
- Backup esportabile (l'azienda vuole i "suoi" dati)
- Multi-sede / multi-magazzino (se rilevante)
- Report preconfigurati (mensile, annuale, per categoria)
- Permessi granulari per sezione e per azione (view/edit/delete)

**North Star suggerita:** Efficienza operativa (% task completati in meno tempo) o NPS interno

---

## API REST / BACKEND PURO

**Domanda tipo-specifica (#6):**
"Chi consuma questa API? Frontend interno / App mobile / Sviluppatori terzi / M2M (machine-to-machine)"
→ Frontend interno: autenticazione session o JWT, documenti non prioritari
→ Sviluppatori terzi: OpenAPI spec obbligatoria, API keys, rate limiting, changelog versioni
→ M2M: API key + IP whitelist, webhook outbound, SLA uptime

**Feature da suggerire proattivamente:**
- OpenAPI spec + Scalar UI (developer experience)
- API versioning `/v1/` da subito (non aggiungerlo dopo)
- Rate limiting per IP + per API key (sicurezza + monetizzazione)
- Webhooks (push event al client invece di polling)
- SDK client (TypeScript/Python) se API pubblica
- Status page (uptime.betterstack.com)
- Sandbox/testing endpoint (dati fittizi per sviluppatori)
- Usage dashboard per API key holder

**North Star suggerita:** API calls/mese o latenza p99

---

## PORTFOLIO / SHOWCASE

**Domanda tipo-specifica (#6):**
"Qual è l'obiettivo principale: trovare lavoro / acquisire clienti freelance / mostrare progetti open source?"
→ Lavoro: sezione "about" forte, link GitHub, case study con risultati
→ Freelance: portfolio con proof of results, testimonianze, CTA contatto chiaro
→ Open source: README curato, stats GitHub, contributi visibili

**Feature da suggerire proattivamente:**
- Case study dettagliati (problema → approccio → risultato con numeri)
- Blog tecnico (SEO + posizionamento expertise)
- Dark/light mode toggle (impressa tecnica)
- Contatto: form + calendly/cal.com per call diretta
- Analytics: quante persone guardano quali progetti (Plausible)
- Open Graph personalizzato per ogni progetto (condivisibilità)

**North Star suggerita:** Contatti ricevuti/mese o Interview invite rate

---

## CLI / BOT / SCRIPT

**Domanda tipo-specifica (#6):**
"Distribuisci a sviluppatori (npm/pip publish) o uso interno/privato?"
→ Pubblico: README eccellente, versioning semver, CHANGELOG, badge CI
→ Privato: documentazione interna, .env example, setup guide

**Feature da suggerire proattivamente:**
- `--help` completo con esempi per ogni subcommand
- `--dry-run` flag (esecuzione sicura senza effetti)
- Configurazione via file `.toolrc` o `config.json`
- Output colorato (chalk/kleur) con livelli log `--verbose`/`--silent`
- Update check automatico (semver check a ogni run)
- CI/CD per test automatici su push

**North Star suggerita:** Downloads/settimana (npm) o Active installations

---

## PYTHON / DATA / AI

**Domanda tipo-specifica (#6):**
"Questo progetto è: processing batch (esegue su schedule) / API real-time / pipeline dati continua / applicazione AI interattiva?"
→ Batch: ottimizza throughput, scheduling (cron/Celery), logging strutturato
→ API real-time: FastAPI async, latenza <200ms target, caching
→ Pipeline dati: reliability > velocità, checkpoint/resume, monitoring
→ AI interattiva: streaming response, context management, fallback provider

**Feature da suggerire proattivamente (AI):**
- Streaming response (l'utente vede l'output mentre arriva)
- Fallback provider (se Claude down → GPT-4, se OpenAI down → Claude)
- Caching risposte identiche (riduce costi LLM del 40-60%)
- Rate limiting per utente (non bruciare budget API in secondi)
- Logging prompt/response (debugging + fine-tuning futuro)
- Feedback loop (thumbs up/down → migliora il prodotto)
- Token counting prima della chiamata (evita errori context limit)

**North Star suggerita:** API p99 latency o Jobs processed/hour
