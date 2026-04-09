# Growth Patterns — Per Tipo Progetto

Dati di crescita, metriche benchmark, loop virali, e strategie CRO per ogni tipo.
Usa questi dati per popolare STRATEGY.md e guidare le decisioni di prodotto.

---

## METRICHE UNIVERSALI — AARRR FUNNEL

| Fase | Metrica | Formula | Benchmark medio |
|------|---------|---------|-----------------|
| Acquisition | CAC | Spesa marketing / nuovi utenti | varia per settore |
| Activation | Activation Rate | Utenti che completano onboarding / totale | >40% è buono |
| Retention | D1 / D7 / D30 | Utenti attivi dopo N giorni / totale | vedi per tipo |
| Referral | K-factor | Inviti inviati × tasso conversione invito | >1 = crescita organica |
| Revenue | LTV/CAC | Lifetime Value / Costo acquisizione | >3x è sano |

**Formula K-factor:**
```
K = i × c
i = inviti inviati per utente attivo (media)
c = tasso conversione invito (%)
Esempio: utente invia 5 inviti, 20% si iscrive → K = 5 × 0.20 = 1.0
K > 1 = crescita esponenziale (raro ma possibile con product-led virality)
K 0.5-1 = crescita sana con supporto marketing
K < 0.3 = crescita dipende solo da canali paid
```

---

## SAAS B2C — Benchmark e Pattern

### Retention Benchmark
| Periodo | Ottimo | Buono | Da migliorare |
|---------|--------|-------|---------------|
| D1 (giorno dopo signup) | >60% | 40-60% | <40% |
| D7 | >30% | 20-30% | <20% |
| D30 | >15% | 10-15% | <10% |
| M3 | >10% | 5-10% | <5% |

### Trial-to-Paid Conversion
- Media industria SaaS: 2-5%
- Buono: 8-12%
- Eccellente: >15%
- **Leva principale:** "aha moment" entro le prime 24h aumenta conversione 3x

### Email Sequences Obbligatorie
1. **D0 — Welcome:** "Ecco come iniziare" (link tutorial, template)
2. **D1 — Activation:** "Hai completato [X]?" (se non ha fatto l'aha moment)
3. **D3 — Value:** "X utenti hanno fatto [risultato] questa settimana"
4. **D7 — Check-in:** "Come stai andando? Hai bisogno di aiuto?"
5. **D14 — Feature discovery:** "Sapevi che puoi fare [feature nascosta]?"
6. **D21 — Trial end (se trial):** "Il tuo trial scade tra 7 giorni — [upgrade CTA]"
7. **D30 — Retention:** "Il tuo recap mensile" (usage summary)

### Viral Loop SaaS B2C
**Loop 1 — Sharing output:** L'utente crea qualcosa con il tool → condivide → chi vede vuole il tool
→ Aggiungi watermark/badge "Creato con [prodotto]" ai file esportati (opt-out, non opt-in)

**Loop 2 — Invito collaborativo:** Feature di collaborazione richiede invito → invitato scopre il prodotto
→ Limitazione free: "per collaborare, invita il tuo team"

**Loop 3 — Referral monetizzato:** Invita X amici → ottieni Y gratis
→ Dropbox crescita: +60% utenti da referral con 250MB extra per entrambi

### Pricing Psychology
- Piano annuale: mostra risparmio % (es. "Risparmia 40% — €8/mese fatturato annualmente")
- Piano più popolare: badge "Più scelto" sul piano mid-tier
- Decoy pricing: 3 piani dove il secondo sembra il migliore rapporto qualità/prezzo
- Free trial senza carta: 2-3x più conversioni, poi chiedi carta all'upgrade

---

## E-COMMERCE — Benchmark e Pattern

### Conversion Rate Benchmark
| Tipo | Buono | Eccellente |
|------|-------|------------|
| Desktop | 2-3% | >4% |
| Mobile | 1-2% | >3% |
| Email traffico | 3-5% | >6% |
| Social media | 0.5-1% | >2% |

### Cart Abandonment Recovery
- **Tasso abbandono medio:** 70-75%
- **Recovery potenziale con email:** 15-20% degli abbandonati
- Sequenza ottimale:
  1. **+1h:** "Hai lasciato qualcosa" (no sconto — stai testando intento)
  2. **+24h:** "Il tuo carrello scade presto" (urgency — mostra immagine prodotto)
  3. **+72h:** "Ecco un piccolo regalo: -10%" (sconto come ultima leva)

### AOV Optimization (Average Order Value)
- **Bundle/pack:** +20-35% AOV
- "Spesso comprato insieme": +15-25%
- Soglia spedizione gratis: "Aggiungi €X per spedizione gratuita" → +18% AOV medio
- Upsell al checkout: mostra un upgrade al prodotto scelto (non aggiuntivo)
- Order bump: checkbox pre-selezionato con add-on (€5-15) al checkout

### Viral Loop E-commerce
**Loop 1 — Review + foto:** Acquisto → email post-delivery → review con foto → SEO + social proof
**Loop 2 — Share discount:** "Condividi con un amico, ricevi 10% sconto sul prossimo ordine"
**Loop 3 — UGC:** Challenge o hashtag (funziona specialmente per fashion, food, beauty)
**Loop 4 — Gifting:** "Manda in regalo" + messaggio personalizzato → recipient diventa cliente

### Pixel e Tracking Obbligatori (MVP)
- Meta Pixel (Facebook/Instagram) — retargeting
- Google Analytics 4 — funnel analysis
- Google Tag Manager — gestione tag senza deploy
- Conversions API (Meta) — server-side per iOS 14.5+ privacy

### Social Proof Engineering
- Recensioni: mostra punteggio + numero recensioni above the fold
- "Persone che guardano ora": +10-15% urgency (solo se non falso)
- "Ultimi X disponibili": +20% conversione (solo se reale)
- "X venduti questa settimana": prova di popularità
- Badge trust: pagamento sicuro, reso gratuito, spedizione veloce — above fold

---

## MOBILE APP — Benchmark e Pattern

### Retention Benchmark Mobile
| Periodo | Ottimo | Buono | Da migliorare |
|---------|--------|-------|---------------|
| D1 | >40% | 25-40% | <25% |
| D7 | >20% | 12-20% | <12% |
| D30 | >10% | 5-10% | <5% |

### Paywall Optimization
- Non mostrare il paywall al primo avvio — mostralo dopo l'"aha moment"
- **Annuale prominente:** LTV 2.5-3x rispetto al mensile
- Pricing test: prova €4.99/mese, €9.99/mese, €19.99/mese — il mercato decide
- Trial gratuito (7 giorni) senza carta: +150% conversioni rispetto a paywall immediato
- Il momento migliore per il paywall: quando l'utente ha completato un'azione di valore

### Push Notification Strategy
- Permission request: chiedi DOPO un'azione positiva (completamento, successo)
- Tasso accettazione medio: 50-60% iOS, 75-80% Android
- **Non spam:** max 1 push al giorno, personalizzata per comportamento
- Re-engagement: "Non ti vediamo da 7 giorni" (solo utenti inattivi)
- Timing: studio del pattern d'uso → invia quando l'utente è tipicamente attivo

### ASO (App Store Optimization)
- **Title:** keyword primaria + brand (es. "Todo List — Task Manager by AppName")
- **Subtitle:** keyword secondaria + benefit
- **Screenshots:** prima schermata mostra il risultato finale, non l'home screen
- **Preview video:** primi 3 secondi mostrano il beneficio principale
- **Rating:** punta a >4.5 stelle — chiedi rating dopo successo, non dopo install
- **Keyword field:** non ripetere parole già nel title/subtitle

### Viral Loop Mobile
**Loop 1 — Share risultato:** Fitness → condividi progresso → amico scarica l'app
**Loop 2 — Sfida amico:** "Sfida un amico" → entrambi vincono qualcosa
**Loop 3 — Referral codice:** Codice univoco per utente → entrambi ottengono X
**Loop 4 — Widget visibile:** Widget iOS/Android su home screen → visibilità costante → amici vedono

---

## LANDING PAGE — Benchmark e Pattern

### Conversion Rate Benchmark
| Tipo landing | Media | Buono | Eccellente |
|--------------|-------|-------|------------|
| Lead gen (email) | 5-10% | 15-25% | >35% |
| Waitlist | 20-30% | 40-50% | >60% |
| Demo booking | 2-5% | 8-12% | >15% |
| Vendita diretta | 1-3% | 5-8% | >10% |

### Struttura Ottimale Above-the-Fold
1. **Headline:** beneficio principale in 8 parole max
2. **Subheadline:** espansione headline, chi è per chi, come funziona
3. **Social proof immediato:** "Usato da X aziende" o "★★★★★ 200+ recensioni"
4. **CTA primario:** verbo d'azione + beneficio (es. "Inizia gratis — nessuna carta")
5. **Visual:** screenshot/mockup/video che mostra il prodotto in azione

### Elementi di Conversione Obbligatori
- Video demo (aumenta conversione +80% se >30 secondi, >60% completamento)
- FAQ (risponde alle obiezioni più comuni — riducono rimbalzo)
- Pricing trasparente (nasconderlo riduce conversioni del 40%)
- Testimonianze con foto reale + nome + azienda (non initials anonime)
- Garanzia / no-risk promise (es. "30 giorni soddisfatti o rimborsati")

### SEO per Landing
- Target keyword: 1 keyword principale per pagina + 3-5 varianti LSI
- Title tag: keyword + brand + benefit (<60 caratteri)
- Meta description: CTA + keyword + benefit (<160 caratteri)
- H1: uguale o variante del title tag
- Schema.org: Organization, Product, FAQ, Review aggregati
- Core Web Vitals target: LCP <2.5s, CLS <0.1, INP <200ms

### Waitlist Strategy
- Show number: "Già 1.247 persone in lista" (social proof dinamico)
- Referral per salire in lista: "Invita 3 amici → passa da posto #500 a #50"
- Email di conferma + sequenza di nurturing (3 email in 2 settimane)
- Mostra progresso: "Sei il numero 234 in lista"

---

## GESTIONALE / ERP — Pattern Specifici

### Adoption Rate
- Setup time target: < 30 minuti per iniziare a usare il core
- First value: l'utente deve fare la prima operazione reale entro il primo giorno
- Training: video tutorial per ogni modulo principale (<5 min ciascuno)

### Feature Adoption
- Dashboard: feature più usate visible subito — quelle avanzate con progressive disclosure
- Tooltip contestuali: aiuto dove serve, senza manuali
- Import dati: supporta Excel/CSV — la migrazione da vecchio sistema è il bottleneck principale

---

## CROSS-CUTTING — Growth Patterns Universali

### Il Momento "Aha" — Trova il Tuo
Il momento in cui l'utente capisce il valore. Ottimizza tutto l'onboarding per arrivarci prima.

Esempi:
- Facebook: "7 amici in 10 giorni" → retention esplodeva
- Slack: "2.000 messaggi inviati nel team" → difficile lasciarlo
- Dropbox: "primo file sincronizzato" → valore immediato tangibile
- Airbnb: "prima prenotazione completata" → fiducia nel sistema

**Come trovare il tuo:** analizza chi rimane a D30 — cosa ha fatto nei primi 3 giorni che gli altri non hanno fatto?

### North Star Metric — Come Sceglierla
La North Star è il numero che, se cresce, significa che il prodotto funziona.

| Tipo | North Star candidata |
|------|---------------------|
| SaaS produttività | Weekly Active Users (WAU) o tasks completed/week |
| SaaS comunicazione | Messages sent/week |
| E-commerce | GMV (Gross Merchandise Value) |
| Marketplace | Transazioni completate/mese |
| Media/content | Monthly reading time |
| Social | DAU/MAU ratio |
| Fintech | $ transato/mese |
| Gestionale | Operazioni completate/giorno |

### Event Tracking — Lista Minima dal Giorno 1
Non tracciare tutto. Traccia questi eventi critici:

**Acquisition:**
- `signup_started` — utente inizia registrazione
- `signup_completed` — registrazione completata
- `signup_source` — canale di acquisizione (utm_source)

**Activation:**
- `onboarding_started` / `onboarding_step_N_completed` / `onboarding_completed`
- `aha_moment` — evento specifico per il tuo prodotto (es. first_file_uploaded)

**Engagement:**
- `feature_X_used` — per ogni feature core
- `session_started` / `session_duration`

**Revenue:**
- `upgrade_clicked` — dove nell'app
- `plan_selected` — quale piano
- `payment_completed` / `payment_failed`
- `subscription_cancelled` — con reason

**Referral:**
- `invite_sent` / `invite_accepted`
- `share_clicked` — quale tipo di sharing

### Caching Strategy (Performance = Conversione)
- Bundle size +100KB → conversione -1% (studio Google)
- LCP >3s → +32% bounce rate
- Mobile LCP >4s → conversione dimezzata

Caching layers da implementare dall'inizio:
1. **HTTP Cache-Control** per assets statici (max-age=31536000)
2. **CDN** per assets (Vercel Edge Network incluso)
3. **ISR/SSG** per pagine SEO con dati che cambiano raramente
4. **SWR/React Query** per dati UI che si aggiornano spesso
5. **Redis** per session, rate limiting, query costose (da fase 3)

### Product Hunt Launch Checklist
- **T-30 giorni:** costruisci hunter community, trova un hunter famoso
- **T-7 giorni:** prepara tutti gli asset (logo 120px, gallery, video demo 60s, tagline)
- **T-1 giorno:** schedula per mezzanotte PST (01:00 CET invernale)
- **Launch day:** post in community rilevanti (Reddit, Twitter, newsletter)
- **Risposta commenti:** ogni commento riceve risposta entro 1h nelle prime 8h

### AI/LLM Growth — Personalizzazione
Livelli di personalizzazione AI (implementa in progressione):

1. **L1 — Contesto base:** l'AI conosce il tipo di utente e le sue preferenze esplicite
2. **L2 — Storico comportamento:** l'AI adatta le risposte in base alle azioni passate
3. **L3 — Pattern predittivo:** l'AI anticipa la prossima azione e la suggerisce
4. **L4 — Generativa:** l'AI genera UI/contenuto personalizzato per l'utente specifico

### Social Login — Impatto Conversione
- Social login (Google/GitHub) vs form email: +20-35% signup completion
- Ordine consigliato: Google > GitHub > Apple > Email/Password
- Dati ottenuti: email, nome, foto profilo (no carta di credito necessaria)
- Sicurezza: valida sempre che l'email sia verified provider-side

### UTM Tracking — Setup Obbligatorio
Ogni link condiviso deve avere UTM parameters. Template:
```
?utm_source=[canale]&utm_medium=[tipo]&utm_campaign=[nome]&utm_content=[variante]
```
Esempi:
- Newsletter: utm_source=newsletter&utm_medium=email&utm_campaign=launch
- Twitter: utm_source=twitter&utm_medium=social&utm_campaign=organic
- ProductHunt: utm_source=producthunt&utm_medium=referral&utm_campaign=launch-day
