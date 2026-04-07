---
name: omega-autopilot-engine
description: Use when the user activates Autopilot mode ([AP]) or Full Autopilot ([AP FULL]). This is the autonomous execution engine — it decides what to do next, calls the right sub-skills, and drives the project to a complete, deployed, working product with minimal human intervention. Only stops at mandatory gates.
user-invocable: false
---

# omega-autopilot-engine — Esecutore Autonomo End-to-End

**Lingua:** Sempre italiano.
**Principio:** L'autopilot non chiede, non esita, non si ferma per conferme a meno che non sia un GATE OBBLIGATORIO. Esegue, verifica, avanza. Il prodotto finale è l'unico obiettivo.

---

## DIFFERENZA AUTOPILOT BASE vs FULL AUTOPILOT

| | Autopilot Base [AP] | Full Autopilot [AP FULL] |
|---|---|---|
| Stop per approvazione piano | Sì | No (genera e inizia) |
| Stop per review documenti | Sì | No |
| Stop per ogni feature | Ogni feature | Solo ai gate obbligatori |
| Obiettivo dichiarato | Fase corrente | Prodotto completo in produzione |
| Quando usarlo | Vuoi controllare ogni step | Fidati di omega — portami al risultato |

---

## I 4 GATE OBBLIGATORI — Gli unici stop dell'autopilot

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
```

Tutto il resto? L'autopilot lo decide e lo esegue autonomamente.

---

## MAPPA DI DECISIONE — Cosa fare in ogni stato

```
STATO ATTUALE                    →  PROSSIMA AZIONE AUTOMATICA
─────────────────────────────────────────────────────────────────
Nessun omega/                    →  /omega:omega-wizard (wizard completo)
omega/ presente, PRD mancante    →  Completa documenti mancanti
PRD presente, nessun piano       →  Crea piano FONDAMENTA
Fase FONDAMENTA in corso         →  Esegui steps in ordine:
                                     1. Scaffolding + env
                                     2. DB schema + migration
                                     3. Auth
                                     4. Layout base + componenti
                                     5. Build verde
Fase FONDAMENTA completa         →  Crea piano COSTRUZIONE per RF-001 del PRD
COSTRUZIONE: feature in corso    →  Implementa RF corrente fino a build verde
COSTRUZIONE: feature completa    →  Prossima RF del PRD
COSTRUZIONE: tutte RF completate →  Avvia audit → /omega:omega-security
Audit completato                 →  Fix critici → /omega:omega-testing (test suite)
Test suite verde                 →  /omega:omega-devops (staging deploy)
Staging OK                       →  GATE 1 → Deploy produzione
Produzione OK                    →  Configura monitoring → PRODOTTO COMPLETO
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

## SEQUENZA FONDAMENTA — Automatica per ogni tipo progetto

### Web App (Next.js)
```
Step 1: package.json + tsconfig + next.config.ts + .env.example
Step 2: prisma/schema.prisma (o supabase/migrations/) + migration iniziale
Step 3: lib/auth.ts + app/login/page.tsx + middleware.ts
Step 4: app/layout.tsx + components/layout/Sidebar.tsx (o Header.tsx)
Step 5: npm run build → DEVE essere verde prima di procedere
```

### API (Hono/Express/FastAPI)
```
Step 1: package.json + tsconfig + src/index.ts + .env.example
Step 2: DB schema + migration
Step 3: Middleware (auth, logger, cors, rate-limit)
Step 4: Health check endpoint /api/health
Step 5: OpenAPI spec generation
Step 6: npm run build → verde
```

### Mobile (Expo)
```
Step 1: npx create-expo-app + configurazione
Step 2: expo-router setup + _layout.tsx
Step 3: Auth setup (Clerk o Supabase)
Step 4: Navigazione principale (tabs o stack)
Step 5: npx expo export → build test
```

### CLI (Node.js)
```
Step 1: package.json (bin field) + tsconfig + src/index.ts
Step 2: Commander setup + help strings
Step 3: Config file handling
Step 4: Error handling + exit codes
Step 5: npm pack → test locale
```

### Python (FastAPI)
```
Step 1: pyproject.toml + requirements.txt + main.py + .env.example
Step 2: Alembic init + prima migration
Step 3: Middleware (auth, cors, logging)
Step 4: Health check /health
Step 5: python -m pytest → verde
```

---

## COSTRUZIONE — Implementazione RF dal PRD

Per ogni RF nel PRD (in ordine di priorità):

```
1. Leggi la RF: cosa deve fare, quali dati, quali endpoint/pagine
2. Identifica file da creare/modificare
3. Crea piano RF con checkbox
4. Implementa: DB → logica business → API/action → UI → test
5. Build verde
6. Log entry in omega/log.md
7. Segna RF come completata nell'autopilot-state.md
8. Prossima RF
```

**Regola ferro:** Mai passare alla RF successiva con build rotta.

### Ordine implementazione consigliato per ogni RF

```
DB first → Business logic → Server action/API → UI → Test
```

Non il contrario (UI first porta a re-scritture quando il DB non supporta quello che serve).

---

## GESTIONE ERRORI — Recovery automatico

Quando qualcosa va storto, l'autopilot:

1. **TypeScript error**: legge l'errore, corregge, ricompila — non chiede
2. **Test fallito**: legge il motivo, corregge il codice o il test (se il test è sbagliato) — non chiede
3. **Build rotta**: diagnostica → fix → build → se OK continua, se KO dopo 3 tentativi → GATE 4 (chiede)
4. **Migration fallita**: rollback automatico → propone soluzione → GATE 2 prima di riprovare
5. **Dependency missing**: `npm install [package]` → continua — non chiede

---

## PROGRESS REPORT — Ogni 5 step

Dopo ogni 5 step completati, mostra un report sintetico:

```
📊 Autopilot Progress — [timestamp]
✅ Completati: [N] step · RF implementate: [N]/[M]
🔄 Step corrente: [descrizione]
⏳ Stima rimanente: ~[N] step (basato su PRD)
🎯 Prossimo checkpoint: [FONDAMENTA / prima RF / audit / staging / prod]
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
- [ ] Tutte le schermate del PRD implementate
- [ ] Auth funzionante
- [ ] Build Expo production OK
- [ ] Testato su iOS simulator + Android emulator
- [ ] App store assets preparati (icona, screenshot)
- [ ] Submission checklist completata

### CLI Tool
- [ ] Tutti i comandi del PRD implementati
- [ ] `--help` chiaro per ogni comando
- [ ] Gestione errori con exit codes corretti
- [ ] Test OK
- [ ] `npm publish` (dry-run OK)
- [ ] README con esempi

### Python Script/API
- [ ] Logica implementata
- [ ] Test pytest OK
- [ ] requirements.txt aggiornato
- [ ] Docker funzionante
- [ ] Deploy OK

---

## COMUNICAZIONE AUTOPILOT

**Tono:** Diretto, senza fronzoli. L'autopilot parla solo quando necessario.

**Formato aggiornamento step:**
```
✓ [azione completata] — [file/risultato]
→ [prossima azione]
```

**Formato gate:**
```
⛔ GATE [N]: [descrizione sintetica]
[domanda o opzioni]
```

**Formato progress:**
```
📊 [N]/[M] RF complete · [N] step completati · Build: ✅
```

**NON usare:**
- Frasi come "Procedo con..." "Ora farò..." "Come richiesto..."
- Riepiloghi di quello che si è appena fatto
- Domande che non siano gate obbligatori

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
🤖 FULL AUTOPILOT avviato.
Obiettivo: [nome progetto] — [N] RF da implementare → staging → produzione.
Gate: deploy prod, migration prod, costi, ambiguità.
Inizio da: [prossima azione determinata dall'analisi].
```
Poi inizia subito.
