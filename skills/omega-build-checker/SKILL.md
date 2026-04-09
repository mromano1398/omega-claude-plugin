---
name: omega-build-checker
description: Use after every 3 modified files, at the end of each plan, after each page during reskin, or before any proposed commit. Runs build, TypeScript check, tests, and lint. Triggered automatically by omega-autopilot-engine or manually with [CHECK].
user-invocable: false
---

# omega-build-checker — Verifica Build e Qualità

**Lingua:** Sempre italiano.
**Principio:** MAI proporre un commit o dichiarare completato un task senza aver verificato la build. Ogni errore va risolto prima di continuare.

---

## AZIONI IN ORDINE

Esegui questi comandi SEMPRE in sequenza (non saltare):

### 1. Build
```bash
npm run build
# oppure:
next build          # Next.js
expo export         # Expo
tsc --noEmit       # Solo type check senza build
cargo build        # Rust
python -m py_compile src/**/*.py  # Python
```

### 2. TypeScript Check
```bash
npx tsc --noEmit
```
Esegui anche se il build è passato — il build può avere `ignoreBuildErrors: true`.

### 3. Test
```bash
npm test            # Jest / Vitest default
npm run test:unit   # Se separati
npx vitest run      # Vitest
pytest              # Python
cargo test          # Rust
```
Se non ci sono test: segnala all'utente ma NON bloccare.

### 4. Lint
```bash
npm run lint        # ESLint
npx eslint src/ --ext .ts,.tsx
```

---

## FORMATO OUTPUT

```
╔══════════════════════════════════╗
║      omega-build-checker         ║
╚══════════════════════════════════╝

Build      ✅ OK  (o ❌ ERRORE: [messaggio])
TypeScript ✅ OK  (o ❌ N errori: [lista])
Test       ✅ OK  (o ❌ N falliti / ⚠ Nessun test)
Lint       ✅ OK  (o ⚠ N warning / ❌ N errori)

RISULTATO: ✅ TUTTO OK — puoi procedere
           ❌ BLOCCO — risolvi errori prima di continuare
```

---

## MODALITÀ BASELINE — Progetti con errori TS pre-esistenti

**Attivazione automatica:** Prima run su un progetto che ha già errori TypeScript (rilevati da `tsc --noEmit`).
**Attivazione manuale:** L'utente digita `[BASELINE]`.

**Comportamento:**
1. Prima esecuzione: conta tutti gli errori TS esistenti → salva in `omega/baseline-errors.md`:
   ```
   # TypeScript Baseline
   Data: [YYYY-MM-DD]
   Errori totali al momento del baseline: [N]
   Stato: BASELINE_ATTIVO
   ```
2. Check successivi: segnala SOLO i nuovi errori introdotti (delta rispetto al baseline)
3. Il workflow NON si blocca se gli errori totali sono ≤ baseline
4. Se il totale scende: aggiorna il baseline al nuovo valore (miglioramento)
5. Il BLOCCO scatta solo se il numero di errori SUPERA il baseline

**Note sul baseline:**
- Non è un'esenzione permanente: l'obiettivo è azzerare gli errori gradualmente
- Ogni piano dovrebbe includere almeno 1 step di riduzione errori TS
- Avvisa sempre quanti errori legacy rimangono: "[N] errori TS pre-esistenti nel baseline"

---

## QUANDO VIENE CHIAMATO

**Automaticamente (da omega-autopilot-engine):**
- Dopo ogni 3 file modificati
- Al termine di ogni piano di lavoro
- Prima di proporre qualsiasi commit
- Dopo ogni pagina durante omega-reskin

**Manualmente:**
- L'utente scrive `[CHECK]`
- L'utente scrive "verifica build" o "controlla errori"
- Alla fine di ogni Phase nel piano omega

---

## GESTIONE ERRORI

### Errore TypeScript
1. Leggi il messaggio di errore completo
2. Identifica file e riga
3. Correggi l'errore
4. Riesegui tsc --noEmit
5. Max 3 tentativi per errore poi → STOP e chiedi all'utente

### Errore Build Next.js
1. Controlla se è errore di tipo o runtime
2. Cerca import circolari o missing exports
3. Controlla `next.config.js` per configurazioni errate
4. Max 3 tentativi poi → STOP

### Test Falliti
1. Leggi output completo del test
2. Correggi il codice (NON il test, salvo se test è sbagliato)
3. Riesegui solo il test fallito: `npx vitest run path/to/test`
4. Max 3 tentativi poi → STOP e segnala all'utente

### STOP Protocol
Dopo 3 tentativi falliti:
```
⛔ omega-build-checker: STOP
Errore persistente dopo 3 tentativi:
[tipo errore]
[messaggio errore]
[file:riga]

Azione richiesta: risoluzione manuale da parte tua.
Cosa ho provato: [lista tentativi]
```

---

## CHECK AGGIUNTIVI (opzionali ma consigliati)

### Bundle Size Check
```bash
# Dopo next build, analizza il bundle:
npx @next/bundle-analyzer  # richiede ANALYZE=true next.config.ts configurato

# Soglie di default omega:
# WARNING:  chunk > 100KB (dopo gzip)
# ERROR:    chunk > 250KB (dopo gzip)
# Per configurare: aggiungi in CLAUDE.md → ## Bundle Budget
```
**Quando attivare:** aggiunto quando si installano nuove dipendenze pesanti (chart libraries, PDF generators, video players).

### Accessibility Check (axe-core)
```bash
# Check rapido su pagine chiave:
npx playwright test --grep @a11y

# Configurazione base in playwright.config.ts:
# import { checkA11y } from 'axe-playwright'
# await checkA11y(page, undefined, { runOnly: ['wcag2a', 'wcag2aa'] })
```
**Quando attivare:** prima di ogni lancio, o dopo la creazione di nuovi form/modal/tabelle.

### npm Audit
```bash
npm audit --audit-level=high
# Blocca su vulnerabilità HIGH e CRITICAL
# MODERATE: segnala ma non blocca
```
**Integrazione nel flusso:**
- Aggiungilo alla checklist pre-lancio `[9]`
- In autopilot: eseguito automaticamente alla fine di FASE 3 (PRE-LANCIO)
- Non eseguirlo ogni 3 file — solo a inizio sessione e prima del deploy

### Performance Budget Lighthouse CI (configurazione suggerita)
```javascript
// .lighthouserc.js — da creare nella root se vuoi CI automatico
module.exports = {
  ci: {
    collect: { url: ['http://localhost:3000'] },
    assert: {
      assertions: {
        'categories:performance':    ['warn', { minScore: 0.8 }],
        'categories:accessibility':  ['error', { minScore: 0.9 }],
        'first-contentful-paint':    ['warn', { maxNumericValue: 2000 }],
        'cumulative-layout-shift':   ['error', { maxNumericValue: 0.1 }],
        'largest-contentful-paint':  ['warn', { maxNumericValue: 2500 }],
      },
    },
  },
}
```
Installa: `npm install -D @lhci/cli`

---

## TABELLA COMANDI PER STACK

| Stack | Build | TypeScript | Test | Lint |
|-------|-------|------------|------|------|
| Next.js | `next build` | `tsc --noEmit` | `vitest run` | `next lint` |
| Vite/React | `vite build` | `tsc --noEmit` | `vitest run` | `eslint src/` |
| Expo | `expo export` | `tsc --noEmit` | `jest --ci` | `eslint .` |
| Node.js CLI | `tsc` | `tsc --noEmit` | `jest --ci` | `eslint src/` |
| Python | `python -m py_compile` | `mypy src/` | `pytest` | `ruff check` |
| Astro | `astro build` | `tsc --noEmit` | `vitest run` | `eslint src/` |

---

## REGOLA AUREA

**Mai dichiarare "fatto" senza build verde.**
Se la build non passa → non si va avanti, non si propone commit, non si chiude il task.
