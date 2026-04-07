---
name: omega-wizard
description: Use when starting a new project (empty folder), resuming an existing project for the first time with omega, or when a BLUEPRINT.md exists and documents need to be generated. Handles MODALITÀ A (8-question wizard), B-RIPRENDI, B-NUOVO, and C (blueprint bypass). Generates MVP.md, PRD.md, design-system.md, roadmap.md.
user-invocable: false
---

# omega-wizard — Wizard + Generazione Documenti

**Lingua:** Sempre italiano.

---

## MODALITÀ C — BLUEPRINT (priorità massima)

Se esiste `BLUEPRINT.md` nella root: il wizard è saltato completamente.

1. Leggi `BLUEPRINT.md` per intero — fonte di verità assoluta
2. Estrai: obiettivo, utenti, stack, schema DB, moduli, UX patterns, design system, scope
3. Genera direttamente tutti i documenti omega **senza fare domande** su cose già definite:
   - `omega/MVP.md` — da sezione obiettivo/scope
   - `omega/PRD.md` — da sezione moduli/spec
   - `omega/design-system.md` — copia esattamente il design system dal blueprint, non inventare
   - `omega/roadmap.md` — da sezione fasi/roadmap
4. Mostra anteprima → chiedi approvazione → poi inizia codice

**Regola:** Design system definito nel blueprint → copialo esattamente, zero domande di conferma sullo stile.

---

## MODALITÀ A — NUOVO PROGETTO (wizard 8 domande)

### Domanda 1 — Descrizione
> Descrivimi il progetto in 2-3 frasi. Cosa risolve, per chi, perché.

### Domanda 2 — Utenti
> Chi usa l'app?
> [A] Solo io (tool personale) · [B] Utenti con account separati · [C] Team/organizzazioni · [D] Mix

### Domanda 3 — Modello business
> [A] Gratis/uso interno · [B] Freemium · [C] Abbonamento · [D] E-commerce · [E] Non deciso

### Domanda 4 — Database esistente
> [A] No, da zero · [B] Sì — DB esistente (chiedi: che sistema? quante tabelle circa?)
> [C] Sì — dati in Excel/CSV/CRM (chiedi dettagli)
>
> Se B o C: "Il DB originale non verrà mai modificato — solo lettura per analisi. Lavoriamo su un DB nuovo."

### Domanda 5 — Stile UI
Proponi tu basandoti sul tipo rilevato:
- Gestionale/ERP/tool interno → **Funzionale** (chiarezza, velocità, zero effetti decorativi)
- SaaS B2C con competitor → **Moderno e curato** (differenziazione UX)
- Landing/marketing → **Marketing-first** (conversione, impatto visivo)
- E-commerce → **Bilanciato** (fiducia + conversione)
- API pura → **N/A** (salta questa domanda)

> "In base al progetto sceglierei **[stile]** perché **[motivo in 1 riga]**. Confermi?"

### Domanda 6 — Stack
Proponi senza chiedere se l'utente non ha preferenze.

| Tipo | Stack consigliato | Note |
|---|---|---|
| SaaS/Gestionale (CRUD) | Next.js · PostgreSQL · Prisma · NextAuth · Resend | ORM per CRUD semplice |
| SaaS con Supabase | Next.js · Supabase · NextAuth · Resend | Solo se team conosce Supabase o serve realtime/RLS |
| Gestionale/ERP (tabelle crescono) | Next.js · PostgreSQL · **pg diretto** · NextAuth · Nodemailer | Controllo totale query |
| Landing / Blog | Astro · Tailwind · Resend | Zero JS inutile |
| E-commerce | Next.js · PostgreSQL · Stripe · Algolia · Resend | Pagamenti + ricerca |
| API pura | Hono/Express · PostgreSQL · pg diretto · OpenAPI | No frontend |
| Mobile | Expo (React Native) · Supabase | Cross-platform |

> "Ti consiglio **[stack]**. Confermi o hai preferenze diverse?"

**Quando usare `pg` diretto invece di Prisma:**
- Tabelle append-only che crescono senza limite (movimenti, log, audit)
- Aggregazioni complesse (GROUP BY, window functions)
- Performance critica su query calde

### Domanda 7 — Deploy
> [A] Vercel (Next.js/Astro — raccomandato) · [B] Railway/Render · [C] VPS/Docker · [D] Non deciso

### Domanda 8 — Vincoli e preferenze
> Cosa vuoi assolutamente avere? Cosa odi? Vincoli di performance o UX specifici?
> (es. "crea richiesta in < 3 click", "no dark mode", "supporto mobile obbligatorio")

---

## MODALITÀ B-RIPRENDI

Hai già letto i documenti nel STEP 0. Fai max 5 domande mirate:
1. "Dall'ultimo log ([data]) ad oggi, cosa è cambiato?"
2. "Ci sono problemi aperti o bug noti?"
3. "L'obiettivo è ancora [da MVP.md] o è cambiato?"
4. Se trovi feature non documentate nel codice: "Ho trovato [X] — è una nuova feature? La documento nel PRD?"
5. "Cosa vuoi fare in questa sessione?"

---

## MODALITÀ B-NUOVO (progetto esistente senza omega/)

Conduci il wizard ma:
- Non chiedere cose deducibili dal codice (stack, struttura, feature presenti)
- Invece di "Descrivimi il progetto" → "Dal codice vedo [X, Y, Z]. È corretto? Cosa manca?"
- Design system: analizza CSS/Tailwind esistente → proponi formalizzazione di quello che c'è
- Genera tutti i documenti omega basandoti sul codice reale

---

## GENERAZIONE DOCUMENTI

Genera in sequenza. Mostra anteprima di ognuno prima di passare al successivo.

### `omega/MVP.md`
```markdown
# MVP — [nome progetto]
Generato: [timestamp]

## Obiettivo
[1-2 frasi sull'obiettivo core]

## Utente target
[chi è, cosa vuole, cosa odia]

## Feature MVP (Fase 1)
✅ [feature obbligatoria]
✅ [feature obbligatoria]

## Fuori scope MVP
❌ [cosa non si fa ora]

## Criterio di successo
[come misuri che l'MVP ha funzionato]

## Vincoli espliciti
- [da domanda 8]
```

### `omega/PRD.md`
```markdown
# PRD — [nome progetto]
Generato: [timestamp]

## Requisiti funzionali
### [modulo 1]
- RF-001: [requisito]
- RF-002: [requisito]

## Requisiti non funzionali
- RNF-001: Performance — [target]
- RNF-002: Sicurezza — [livello]
- RNF-003: Accessibilità — WCAG 2.1 AA

## Flussi utente principali
### Flusso 1: [nome]
1. [step]
2. [step]

## Integrazioni richieste
- [servizio]: [perché]

## Rischi
- [rischio]: [mitigation]
```

### `omega/design-system.md`
```markdown
# Design System — [nome]
Generato: [timestamp]
Stile: [funzionale / moderno / marketing / bilanciato]

## Palette colori
| Token | Hex | Uso |
|---|---|---|
| primary | #2563eb | CTA, link, focus |
| success | #16a34a | Confermato, evaso |
| warning | #d97706 | Bozza, in attesa |
| danger | #dc2626 | Errore, annullato |
| surface | #f9fafb | Background card |
| border | #e5e7eb | Bordi |

## Tipografia
Font: [nome] — fallback system-ui — base 14px per tabelle dense

## Componenti base
[Button, Input, Card, Badge, Table, Form, Modal, Toast — pattern Tailwind/shadcn]

## Regole assolute
- NO gradients, NO animazioni complesse, NO glassmorphism
- Tabelle sempre leggibili su sfondo bianco
- Badge stato sempre colorati con testo
```

### `omega/roadmap.md`
```markdown
# Roadmap — [nome]
Generata: [timestamp]

## Fase 1 — FONDAMENTA
- [ ] Scaffolding progetto
- [ ] DB setup + migration
- [ ] Auth base
- [ ] Layout + sidebar

## Fase 2 — COSTRUZIONE MVP
- [ ] [feature MVP 1]
- [ ] [feature MVP 2]

## Fase 3 — PRE-LANCIO
- [ ] Staging + verifica
- [ ] Audit sicurezza
- [ ] Performance

## Fase 4 — LANCIO
- [ ] Deploy produzione
- [ ] Smoke test

## Fase 5 — POST-LANCIO
- [ ] Monitoring
- [ ] Feedback iterazione

## Backlog (post-MVP)
- [ ] [feature futura]
```

### `README.md`
```markdown
# [Nome Progetto]

[Descrizione 2 righe]

## Stack
[tecnologie principali]

## Avvio rapido
npm install && npm run dev

## Struttura
[struttura cartelle root]

## Documentazione omega
- [omega/MVP.md](omega/MVP.md)
- [omega/PRD.md](omega/PRD.md)
- [omega/design-system.md](omega/design-system.md)
- [omega/roadmap.md](omega/roadmap.md)

## Stato
Fase attuale: ① FONDAMENTA — Ultimo aggiornamento: [data]
```

---

## APPROVAZIONE

```
╔═══════════════════════════════════════════════╗
║  Documenti generati. Cosa vuoi fare?          ║
║                                               ║
║  [OK] Approva tutto → inizia Fase 1           ║
║  [M]  Modifica → dimmi cosa cambiare          ║
║  [R]  Rigenera → ti do più contesto           ║
╚═══════════════════════════════════════════════╝
```

Su approvazione → logga in `omega/log.md` + aggiorna `omega/state.md` + inizia **Fase 1 FONDAMENTA**.
