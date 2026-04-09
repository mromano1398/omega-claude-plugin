---
name: omega-autopilot-engine
description: Use when the user activates Autopilot mode ([AP]) or Full Autopilot ([AP FULL]). Autonomous execution engine that drives the project from current state to complete deployed product. Integrates omega-build-checker (every 3 files + end of plan), omega-audit-ui (end of Phase 2), and omega-context-updater (after each completed plan). Only stops at 6 mandatory gates.
user-invocable: false
---

# omega-autopilot-engine — Esecutore Autonomo End-to-End v4.0

**Lingua:** Sempre italiano.
**Principio:** L'autopilot non chiede, non esita, non si ferma per conferme a meno che non sia un GATE OBBLIGATORIO. Esegue, verifica, avanza. Il prodotto finale è l'unico obiettivo.

---

## DIFFERENZA AUTOPILOT BASE vs FULL vs FAST

| | Base [AP] | Full [AP FULL] | Fast [AP FAST] |
|---|---|---|---|
| Stop per approvazione piano | Sì | No (genera e inizia) | No |
| Stop per review documenti | Sì | No | No |
| Stop per ogni feature | Ogni feature | Solo ai gate obbligatori | Solo ai 2 gate critici |
| Gate obbligatori | Tutti e 6 | Tutti e 6 | Solo GATE 1 (prod deploy) + GATE 2 (migration prod) |
| Domande intermedie | In-line durante esecuzione | Solo ai gate | Raccolte in batch a fine piano |
| Non saltabile mai | — | OWASP · build verde | OWASP · build verde · giacenze negative |
| Obiettivo dichiarato | Fase corrente | Prodotto completo in produzione | Prodotto completo — velocità max |
| Quando usarlo | Vuoi controllare ogni step | Fidati di omega | Fidati completamente — max velocità |

**FAST MODE — Comportamento specifico:**
- Raccoglie TUTTE le domande ambigue in una lista e le presenta in batch DOPO il piano (non interrompe durante)
- Gate 3 (costi), Gate 4 (ambiguità), Gate 5 (breaking change API), Gate 6 (migration staging) → si accumulate come batch, non bloccano il flow
- Blocchi non negoziabili anche in FAST: OWASP sicurezza Fase 1, build verde, giacenze mai negative
- Attivazione: `[AP FAST]` dal menu o dalla proposta wizard

---

## I 6 GATE OBBLIGATORI — Gli unici stop dell'autopilot

```
GATE 1 — DEPLOY IN PRODUZIONE
  "Sto per deployare in produzione. Confermi?"
  → Aspetta risposta. Senza conferma, non tocca il prod.

GATE 2 — MIGRATION DB SU DATI REALI
  "Sto per eseguire una migration che modifica tabelle con dati reali.
   Ho fatto backup? Confermo la migration?"
  → Aspetta risposta. Non esegue mai migration prod senza conferma.

GATE 3 — COSTI SIGNIFICATIVI
  "Questa azione comporta costi: [descrizione + stima].
   Es: API esterna a pagamento, worker cloud, CDN premium."
  → Aspetta risposta.

GATE 4 — REQUISITO AMBIGUO
  "Non riesco a determinare autonomamente [cosa]. Ho bisogno di una decisione:
   [A] Opzione A — [descrizione]
   [B] Opzione B — [descrizione]"
  → Aspetta risposta. Poi riparte immediatamente senza ulteriori domande.

GATE 5 — BREAKING CHANGE SU API PUBBLICA
  Trigger: modifica che rompe retrocompatibilità di un endpoint/contratto pubblico
  Messaggio: "Sto per modificare [endpoint/campo/schema] in modo non retrocompatibile.
              Questo può rompere client esistenti. Confermo il breaking change?"
  → Stop obbligatorio. Non procede senza conferma esplicita.

GATE 6 — MIGRATION DISTRUTTIVA SU STAGING
  Trigger: DROP COLUMN, DROP TABLE, NOT NULL senza default, rimozione vincoli su staging
  Messaggio: "Sto per eseguire una migration che elimina/altera dati su staging:
              [operazione]. Backup fatto? Confermo?"
  → Stop obbligatorio.
```

Tutto il resto? L'autopilot lo decide e lo esegue autonomamente.

---

## SCHEMA `omega/autopilot-state.md`

Questo file è la fonte di verità per lo stato dell'autopilot. Deve essere creato all'avvio e aggiornato dopo ogni gate/step.

```markdown
# AUTOPILOT STATE
Autopilot: ACTIVE | PAUSED | COMPLETE
Modalità: BASE | FULL | FAST
Avviato: [YYYY-MM-DD HH:MM]
Ultimo aggiornamento: [YYYY-MM-DD HH:MM]

## Fase corrente
Fase: [N — nome]
Step corrente: [N/M]
Piano attivo: omega/plans/[nome-piano].md

## Gate attraversati
- [timestamp] GATE [N] — [descrizione] — CONFERMATO
- [timestamp] GATE [N] — [descrizione] — IN ATTESA

## Metriche sessione
File modificati: [N]
Build checker invocato: [N] volte
Errori TS risolti: [N]
Check audit-ui: [esito / non ancora eseguito]
```

**Regola:** l'hook SessionStart legge questo file per rilevare un autopilot attivo.
Formato della riga `Autopilot:` deve essere esattamente `Autopilot: ACTIVE` (maiuscolo, senza testo extra sulla stessa riga).

---

## MAPPA DI DECISIONE — Cosa fare in ogni stato

```
STATO ATTUALE                    →  PROSSIMA AZIONE AUTOMATICA
─────────────────────────────────────────────────────────────────────
Nessun omega/                    →  /omega:omega-wizard (include product-strategy)
omega/ presente, STRATEGY.md
  assente                        →  /omega:omega-product-strategy (business canvas prima del codice)
omega/ presente, CLAUDE.md
  assente o senza Design System  →  /omega:omega-doc-generator (rigenera CLAUDE.md)
omega/ presente, PRD mancante    →  Completa documenti mancanti
PRD presente, nessun piano       →  Crea piano FONDAMENTA con sicurezza default
Fase FONDAMENTA in corso         →  Esegui steps in ordine:
                                     1. Scaffolding + env
                                     2. DB schema + migration
                                     3. Auth
                                     4. Layout base + componenti
                                     5. Sicurezza Fase 1 (AUTOMATICA):
                                        → security headers
                                        → .env in .gitignore
                                        → rate limiting auth
                                        → Zod su ogni input server
                                        → IDOR protection su ogni query
                                     6. Build verde → /omega:omega-build-checker
Fase FONDAMENTA completa         →  /omega:omega-context-updater + crea piano COSTRUZIONE
COSTRUZIONE: ogni 3 file         →  /omega:omega-build-checker (automatico)
COSTRUZIONE: fine piano          →  /omega:omega-build-checker + /omega:omega-context-updater
COSTRUZIONE: tutte RF completate →  /omega:omega-audit-ui (fine Fase 2)
Audit UI SLOP/GENERICO           →  Fix automatico prima di procedere
Audit UI completato              →  /omega:omega-security (obbligatorio — indipendente dall'esito di audit-ui)
Audit completato                 →  Fix critici → /omega:omega-testing (test suite)
Test suite verde                 →  /omega:omega-devops (staging deploy)
Staging OK                       →  GATE 1 → Deploy produzione
Produzione OK                    →  Configura monitoring → /omega:omega-context-updater finale
                                     → PRODOTTO COMPLETO
```

---

## `omega/autopilot-state.md` — Stato autopilot (separato da state.md)

L'autopilot mantiene il suo file di stato per il resume automatico.

```markdown
# Autopilot State
Modalità: FULL / BASE
Obiettivo: [descrizione in una riga del prodotto finito]
Avviato: [timestamp]
Aggiornato: [timestamp]

## Stato corrente
Fase: [FONDAMENTA/COSTRUZIONE/SICUREZZA/STAGING/PROD]
Step corrente: [descrizione precisa — es. "Implementazione RF-003: lista clienti con filtri"]
Sub-skill attiva: [omega-devops / omega-testing / omega-security / nessuna]

## Prossima azione
Tipo: [ESEGUI / GATE]
Azione: [descrizione precisa]
Sub-skill da chiamare: [se applicabile]

## Gate superati
- [x] GATE 1 - Deploy prod: [data]
- [ ] GATE 2 - Migration prod: non ancora
- [x] GATE 3 - Costi: nessun costo rilevato
- [x] GATE 4 - Ambiguità: nessuna

## Progress RF (dal PRD)
| RF | Titolo | Stato |
|---|---|---|
| RF-001 | [titolo] | ✅ Completato |
| RF-002 | [titolo] | 🔄 In corso |
| RF-003 | [titolo] | ⬜ Da fare |

## Blocchi risolti
- [timestamp]: [problema] → [soluzione applicata]

## Blocchi attivi
- [nessuno]
```

---

## SESSION RESUME — Come riprendere dopo una pausa

All'inizio di ogni sessione con autopilot attivo, il hook SessionStart stampa l'autopilot-state.md.

Claude deve leggere la sezione "Prossima azione" e:
1. **NON mostrare il menu**
2. **NON fare domande**
3. Annunciare in una riga: "Autopilot attivo — riprendo da: [azione]"
4. Eseguire immediatamente

Esempio output corretto:
```
🤖 Autopilot FULL attivo — riprendo da: Implementazione RF-003 (filtro clienti per zona)
```
Poi inizia subito a lavorare.

---

## SEQUENZA FONDAMENTA — Include sicurezza default

### Web App (Next.js)
```
Step 1: package.json + tsconfig + next.config.ts + .env.example
Step 2: prisma/schema.prisma (o supabase/migrations/) + migration iniziale
Step 3: lib/auth.ts + app/login/page.tsx + middleware.ts
Step 4: app/layout.tsx + components/layout/ + componenti UI base (tier scelto)
Step 5: SICUREZZA FASE 1 (automatica, non opt-in):
        - Security headers in next.config.ts
        - Rate limiting su /api/auth (5 tentativi/15min)
        - IDOR protection template in lib/action-utils.ts
        - .env in .gitignore verificato
        - Zod schema per ogni form principale
Step 6: /omega:omega-build-checker → DEVE essere verde prima di procedere
Step 7: /omega:omega-context-updater (primo aggiornamento CLAUDE.md)
```

### API (Hono/Express/FastAPI)
```
Step 1: package.json + tsconfig + src/index.ts + .env.example
Step 2: DB schema + migration
Step 3: Middleware (auth, logger, cors, rate-limit)
Step 4: Health check endpoint /api/health
Step 5: SICUREZZA FASE 1 (automatica): Helmet/security headers,
        rate limiting auth, Zod/Joi su ogni input, .env in .gitignore
Step 6: OpenAPI spec + /omega:omega-build-checker → verde
Step 7: /omega:omega-context-updater
```

### Mobile (Expo)
```
Step 1: npx create-expo-app + expo-router setup + _layout.tsx
Step 2: Auth setup (Clerk o Supabase) + navigazione principale
Step 3: SICUREZZA FASE 1 (automatica): SecureStore per token,
        .env in .gitignore, validazione input su ogni form
Step 4: npx expo export → build test
Step 5: /omega:omega-context-updater
```

### CLI (Node.js)
```
Step 1: package.json (bin) + tsconfig + src/index.ts
Step 2: Commander setup + help strings + config handling + exit codes
Step 3: .env in .gitignore verificato
Step 4: npm pack → test locale + /omega:omega-context-updater
```

### Python (FastAPI)
```
Step 1: pyproject.toml + requirements.txt + main.py + .env.example
Step 2: Alembic init + prima migration
Step 3: Middleware (auth, cors, logging) + health check /health
Step 4: SICUREZZA FASE 1 (automatica): security headers (starlette),
        slowapi rate limiting, Pydantic su ogni schema, .env verificato
Step 5: python -m pytest → verde + /omega:omega-context-updater
```

---

## COSTRUZIONE — Flusso aggiornato con build-checker integrato

Per ogni RF nel PRD (in ordine di priorità):

```
1. Leggi la RF: cosa deve fare, quali dati, quali endpoint/pagine
2. Identifica file da creare/modificare
3. Crea piano RF con checkbox
4. Implementa: DB → logica business → API/action → UI → test
5. Ogni 3 file modificati → /omega:omega-build-checker (automatico)
   OPPURE immediatamente se modificato un file critico:
   `schema.prisma` / `*.sql` / migration / `middleware.ts` / `next.config.ts` /
   `next.config.js` / `vite.config.ts` / `package.json` (nuove dipendenze) /
   `tsconfig.json` / `tsconfig.*.json` / `auth.ts` / `auth.config.ts` / `.env.example`
6. Build verde
7. /omega:omega-context-updater (aggiorna CLAUDE.md)
8. Log entry in omega/log.md
9. Segna RF come completata nell'autopilot-state.md
10. Prossima RF

Fine Fase 2 (tutte RF completate):
→ /omega:omega-build-checker (build completo finale)
→ /omega:omega-audit-ui (obbligatorio)
  → Se SLOP/GENERICO: fix automatico → /omega:omega-build-checker → riprendi
→ /omega:omega-security (obbligatorio — indipendente dall'esito di audit-ui)
→ /omega:omega-context-updater
```

**Regola ferro:** Mai passare alla RF successiva con build rotta.

**Ordine implementazione per ogni RF:**
```
DB first → Business logic → Server action/API → UI → Test
```
Non il contrario (UI first porta a re-scritture quando il DB non supporta quello che serve).

---

## GESTIONE ERRORI — Recovery automatico

| Errore | Azione autopilot |
|---|---|
| TypeScript error | Legge, corregge, ricompila — non chiede |
| Test fallito | Corregge codice o test — non chiede |
| Build rotta | Diagnostica → fix → se KO dopo 3 tentativi → GATE 4 |
| Migration fallita | Rollback automatico → GATE 2 prima di riprovare |
| Dependency missing | `npm install [package]` → continua |

---

## PROGRESS REPORT — Ogni 5 step

```
📊 Autopilot Progress — [timestamp]
✅ Completati: [N] step · RF implementate: [N]/[M]
🔄 Step corrente: [descrizione]
🎯 Prossimo checkpoint: [FONDAMENTA / audit / staging / prod]
```

---

## DEFINIZIONE DI COMPLETO — Per tipo progetto

Il prodotto è **COMPLETO** quando:

### Web App (SaaS/Gestionale)
- [ ] Tutte le RF del PRD implementate
- [ ] Build verde
- [ ] Audit sicurezza: zero critici aperti
- [ ] Test suite verde (unit + integration)
- [ ] E2E flusso principale OK
- [ ] Staging deploy OK
- [ ] Deploy produzione OK
- [ ] Monitoring attivo (uptime check)
- [ ] Backup DB configurato

### API
- [ ] Tutti gli endpoint del PRD implementati
- [ ] OpenAPI spec generata e valida
- [ ] Auth funzionante
- [ ] Rate limiting configurato
- [ ] Contract test OK
- [ ] Deploy produzione OK
- [ ] Health check `/health` risponde 200

### Mobile App
- [ ] Tutte le schermate del PRD implementate · Auth funzionante
- [ ] Build Expo production OK · Testato su iOS + Android emulator
- [ ] App store assets pronti · Submission checklist completata

### CLI Tool
- [ ] Tutti i comandi del PRD · `--help` chiaro · Exit codes corretti
- [ ] Test OK · `npm publish` dry-run OK · README con esempi

### Python Script/API
- [ ] Logica + test pytest OK · requirements.txt aggiornato
- [ ] Docker funzionante · Deploy OK

---

## COMUNICAZIONE AUTOPILOT

**Tono:** Diretto, senza fronzoli. L'autopilot parla solo quando necessario.

```
✓ [azione completata] — [file/risultato]      → step completato
→ [prossima azione]

⛔ GATE [N]: [descrizione] [domanda/opzioni]   → stop obbligatorio

📊 [N]/[M] RF complete · [N] step · Build: ✅  → progress ogni 5 step
```

**NON usare:** "Procedo con..." "Ora farò..." riepiloghi, domande non-gate.

---

## AVVIO AUTOPILOT

Quando l'utente digita `[AP]` o `[AP FULL]`:

1. Leggi `omega/state.md`, `omega/PRD.md`, `omega/roadmap.md`
2. Determina il tipo di autopilot (BASE o FULL)
3. Crea `omega/autopilot-state.md` con stato iniziale
4. Logga in `omega/log.md`: `[timestamp] AUTOPILOT | Avviato modalità [BASE/FULL] | obiettivo: [N RF da implementare]`
5. **FULL:** Non mostrare menu — inizia immediatamente dalla fase corrente
6. **BASE:** Mostra il piano → aspetta "OK" → poi avvia

**FULL AUTOPILOT output di avvio:**
```
🤖 FULL AUTOPILOT v4.0 avviato.
Obiettivo: [nome progetto] — [N] RF da implementare → staging → produzione.
Gate: deploy prod, migration prod, costi, ambiguità.
Integrati: omega-build-checker (ogni 3 file + fine piano), omega-audit-ui (fine Fase 2), omega-context-updater (dopo ogni piano completato).
Inizio da: [prossima azione determinata dall'analisi].
```
Poi inizia subito.
