---
name: omega-context-updater
description: Use automatically after every completed plan to update CLAUDE.md and omega/state.md with current project knowledge. Ensures CLAUDE.md always reflects actual project state.
user-invocable: false
---

# omega-context-updater — Aggiornamento Contesto Progetto

**Lingua:** Sempre italiano.
**Principio:** CLAUDE.md e state.md sono la fonte di verità del progetto. Devono sempre riflettere lo stato attuale, non quello iniziale. MAI lasciare documentazione obsoleta.

---

## QUANDO VIENE CHIAMATO

**Automaticamente:**
- Alla fine di ogni piano di lavoro completato
- Dopo omega-reskin (design system cambiato)
- Dopo aggiunta di un nuovo modulo/dominio
- Dopo cambio di dipendenze significative (nuovo ORM, nuova auth, ecc.)
- Dopo ogni Phase completata in omega-autopilot-engine

**Manualmente:**
- L'utente scrive `[UPDATE-CONTEXT]`
- L'utente scrive "aggiorna la documentazione"

---

## AZIONI IN ORDINE

**REGOLA AGGIORNAMENTO:** context-updater aggiorna SOLO le sezioni tecniche
(`## Stato`, `## Stack`, `## Fase corrente`, `## Struttura progetto`).
Non tocca mai: sezioni `## Regole`, `## Note manuali`, né qualsiasi contenuto
che l'utente ha aggiunto manualmente. Ha precedenza su doc-generator
per gli aggiornamenti incrementali — doc-generator è per la generazione iniziale.

### 1. Scansiona la struttura attuale
```
src/app/           → pagine e route esistenti
src/modules/       → moduli di dominio (queries, actions, types)
src/components/    → componenti custom (non ui/)
src/lib/           → utilities e configurazioni
omega/             → documenti omega esistenti
package.json       → dipendenze attuali
```

### 2. Aggiorna `omega/state.md`
Aggiorna questi campi:
- `last_updated`: data odierna
- `completed_modules`: lista moduli completati
- `in_progress`: cosa è in corso
- `pending`: cosa manca ancora
- `known_issues`: problemi aperti (non blocchi risolti)
- `recent_changes`: ultimi 3-5 cambiamenti significativi

### 3. Aggiorna `CLAUDE.md`
Sezioni da aggiornare:

**[STRUTTURA PROGETTO]** — aggiungi nuove route/moduli scoperti
**[MODULI IMPLEMENTATI]** — spunta moduli completati, aggiungi nuovi
**[SCHEMA DB]** — aggiungi tabelle nuove o modificate
**[DIPENDENZE CHIAVE]** — aggiorna se cambiate
**[DESIGN SYSTEM]** — aggiorna se tier o palette cambiati
**[REGOLE OMEGA]** — non modificare (sono regole permanenti)
**[PROSSIMI STEP]** — aggiorna con task successivi reali

### 4. Verifica coerenza
Controlla che:
- I moduli dichiarati in CLAUDE.md esistano effettivamente in `src/modules/`
- Le route dichiarate esistano in `src/app/`
- Le dipendenze in CLAUDE.md siano allineate a `package.json`
- Il tier dichiarato corrisponda a quello nei componenti

---

## FORMATO SEZIONE AGGIORNATA IN CLAUDE.md

```markdown
## [MODULI IMPLEMENTATI]
<!-- Aggiornato: [DATA] -->
- [x] Auth (login, logout, session) — NextAuth v5
- [x] Clienti (CRUD + soft delete) — completato [DATA]
- [x] Ordini (lista, dettaglio, stati) — completato [DATA]
- [ ] Fatturazione — in sviluppo
- [ ] Report — da iniziare

## [SCHEMA DB — TABELLE ESISTENTI]
<!-- Aggiornato: [DATA] -->
- users (id, email, name, role, created_at)
- organizations (id, name, slug, plan)
- clients (id, org_id, name, email, phone, deleted_at)
- orders (id, org_id, client_id, status, total, created_at)

## [PROSSIMI STEP]
<!-- Aggiornato: [DATA] -->
1. Completare modulo fatturazione (actions.ts + UI)
2. Aggiungere export CSV su tabella ordini
3. Implementare notifiche email su cambio stato ordine
```

---

## REGOLE

**Compatto:** CLAUDE.md non deve superare 300 righe. Se cresce troppo, rimuovi sezioni obsolete o sposta in omega/.

**Solo necessario:** Non aggiungere documentazione decorativa. Solo info che servono al modello per lavorare sul progetto.

**Sincronizzato:** Mai lasciare CLAUDE.md desincronizzato dal codice reale. Un CLAUDE.md sbagliato è peggio di nessun CLAUDE.md.

**Non riscrivere:** Aggiorna le sezioni pertinenti, non riscrivere l'intero file. Mantieni le sezioni [REGOLE OMEGA] invariate.

**Timestamp:** Ogni sezione aggiornata riceve un commento `<!-- Aggiornato: [DATA] -->`.

---

## OUTPUT

Al completamento dell'aggiornamento:
```
omega-context-updater completato

Aggiornato CLAUDE.md:
  → [MODULI IMPLEMENTATI]: aggiunto X, spuntato Y
  → [SCHEMA DB]: aggiunta tabella Z
  → [PROSSIMI STEP]: aggiornati

Aggiornato omega/state.md:
  → last_updated: [DATA]
  → completed_modules: +[lista]
  → pending: aggiornato
```
