# Competitor Research — Framework e Metodi

Come analizzare i competitor sistematicamente. Usato da omega-product-strategy Step 2.

---

## METODO 1 — RICERCA RAPIDA (5 minuti, nessun tool esterno)

### Step 1: Trova i competitor
Ricerche Google da fare:
```
"[categoria prodotto] alternatives"
"[categoria prodotto] vs [nome tool noto]"
"best [categoria prodotto] 2025 reddit"
"[problema che risolvi] software"
```

Product Hunt:
```
producthunt.com/search?q=[categoria]
→ Filtra per: Top → All time o This year
→ Nota: upvotes, commenti, data lancio
```

G2 / Capterra (per B2B):
```
g2.com/categories/[categoria]
→ Vedi: rating, numero review, prezzo, feature comparate
```

App Store / Play Store (per mobile):
```
Cerca: [categoria] → guarda Top Free / Top Paid
→ Nota: rating, numero review, aggiornamento recente, descrizione
```

### Step 2: Per ogni competitor, raccogli
- **Pricing:** free? trial? range prezzi
- **Target:** chi serve principalmente
- **Punti forti:** cosa dicono le recensioni positive
- **Punti deboli:** cosa dicono le recensioni negative (G2, Trustpilot, Reddit)
- **Feature principali:** cosa pubblicizzano nella homepage
- **Missing:** cosa gli utenti chiedono e non trovano (forum, subreddit, tweets)

### Step 3: Reddit Research (gold per gap features)
```
reddit.com/r/[settore] → cerca "[nome competitor] problems" o "[nome competitor] alternative"
reddit.com/search?q=[competitor]+alternative
```
Reddit mostra le frustrazioni reali che le recensioni ufficiali nascondono.

### Step 4: Analisi della homepage
Per ogni competitor, guarda:
- Headline: che promessa fanno?
- Social proof: numeri, loghi, testimonianze
- Pricing: trasparente o "contattaci"?
- CTA principale: trial, demo, freemium?
- Cosa NON mostrano (punti deboli nascosti)

---

## METODO 2 — ANALISI APPROFONDITA (con web search)

Se web search è disponibile, esegui queste ricerche:

```
1. "[competitor] pricing 2025" → trova pricing aggiornato
2. "[competitor] alternatives reddit" → frustrazioni utenti reali
3. "[competitor] review" site:g2.com OR site:capterra.com → review strutturate
4. "[competitor] changelog" → velocità di sviluppo, direzione prodotto
5. "[competitor] API" → se hanno API pubblica (differenziatore potenziale)
```

---

## TEMPLATE ANALISI COMPETITOR

Per ogni competitor rilevante:

```markdown
## [Nome Competitor]

**URL:** [url]
**Tipo:** [SaaS / App / Marketplace / ...]
**Target principale:** [chi serve]
**Pricing:** [free / freemium / trial / paid da X€/mese]

### Punti Forti
- [forza 1] — evidenza: [dove l'hai visto]
- [forza 2]

### Punti Deboli
- [debolezza 1] — fonte: [G2/Reddit/review]
- [debolezza 2]

### Feature Principali
- [feature 1]
- [feature 2]

### Gap (cosa manca / utenti chiedono)
- [gap 1] — frequenza richiesta: [alta/media/bassa]
- [gap 2]

### Come si posiziona vs noi
[Il nostro prodotto differisce perché...]
```

---

## MATRICE DI POSIZIONAMENTO

Dopo aver analizzato 2-5 competitor, crea questa matrice:

```
          Feature Complete
                ↑
[Competitor A]  |    [Competitor B]
                |
Costoso --------+-------- Economico
                |
                |    [TUO PRODOTTO qui?]
[Competitor C]  |
                ↓
          Feature Limited
```

Identifica lo spazio vuoto — dove posizionare il prodotto.

**Assi comuni per tipo progetto:**
- SaaS tool: Semplicità vs Potenza / Prezzo vs Feature
- E-commerce: Nicchia vs Generalista / Premium vs Budget
- Mobile: Consumer vs Professional / Simple vs Feature-rich

---

## COMPETITIVE ADVANTAGE FRAMEWORK

Dopo l'analisi, identifica il tipo di vantaggio competitivo:

| Tipo vantaggio | Esempio | Come costruirlo |
|---------------|---------|-----------------|
| **Prezzo** | 3x più economico | Efficienza operativa, meno overhead |
| **Velocità** | Più veloce da imparare/usare | UX migliore, onboarding curato |
| **Nicchia** | Solo per [settore specifico] | Verticale con feature su misura |
| **Integrazione** | Si integra con X che gli altri non fanno | Partner ecosystem |
| **Network effect** | Più utenti = più valore | Feature collaborative, marketplace |
| **Data moat** | I tuoi dati rendono il prodotto più smart | AI personalizzazione, benchmark |
| **Brand** | Trust, design, community | Consistenza nel tempo |

**Regola:** un solo vantaggio competitivo comunicato chiaramente > molti vaghi.

---

## POSITIONING STATEMENT TEMPLATE

Dopo l'analisi competitor, scrivi questo per STRATEGY.md:

```
Per [target principale]
che [problema che hanno]
il nostro prodotto è [categoria]
che [beneficio principale]
a differenza di [competitor principale]
che [loro debolezza principale].
```

Esempio:
```
Per piccole aziende (5-50 persone)
che gestiscono progetti con Excel e email
il nostro prodotto è un gestionale progetti
che si impara in un pomeriggio e funziona su mobile
a differenza di Jira e Asana
che richiedono settimane di setup e sono pensati per aziende grandi.
```

---

## FONTI DI INTELLIGENCE COMPETITIVA (bookmark)

| Fonte | Uso |
|-------|-----|
| G2.com | Review B2B, comparazioni feature, pricing |
| Capterra.com | Idem G2, più piccole imprese |
| Product Hunt | Lanci nuovi, community feedback, upvotes |
| Reddit | Frustrazioni reali, discussioni honest |
| Twitter/X | Feedback real-time, thread fondatori |
| HackerNews | Commenti tecnici, show HN post competitor |
| App Store reviews | Mobile: feedback dettagliati |
| SimilarWeb (free) | Traffico stimato competitor web |
| Wayback Machine | Come è cambiato il competitor nel tempo |
| LinkedIn | Chi assumono (direzione prodotto) |
| Changelog/blog | Velocità sviluppo, roadmap trasparente |
