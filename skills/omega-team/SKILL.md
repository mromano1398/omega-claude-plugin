---
name: omega-team
description: Use when working in a team of 2+ developers, coordinating parallel feature work, managing PR workflows, planning sprints, tracking who is doing what, or handling merge conflicts. Triggered by mentions of "team", "developer", "PR", "sprint", "review", "branch per feature".
user-invocable: false
---

# omega-team — Coordinamento Team · PR · Sprint · Multi-piano

**Lingua:** Sempre italiano.
**Contesto:** Questa sub-skill estende omega per team da 2 a 8 developer. Non sostituisce il workflow Git — lo orchestra e lo documenta.

---

## STATO TEAM — Vista aggregata

Quando l'utente chiede lo stato del team, genera questo report da `omega/team-state.md`:

```
╔══════════════════════════════════════════════════════════════╗
║  STATO TEAM — [nome progetto]          Sprint [N] · [date]  ║
╠══════════════════════════════════════════════════════════════╣
║  DEVELOPER  │ BRANCH              │ STATO       │ BLOCCO    ║
║─────────────┼─────────────────────┼─────────────┼───────────║
║  [nome]     │ feature/[nome]      │ 🔄 IN CORSO │ —         ║
║  [nome]     │ fix/[nome]          │ 👁 REVIEW   │ @[reviewer]║
║  [nome]     │ feature/[nome]      │ ✅ MERGED   │ —         ║
║  [nome]     │ —                   │ 🔒 BLOCCATO │ attende PR║
╠══════════════════════════════════════════════════════════════╣
║  Sprint velocity: [N] RF completati / [M] pianificati        ║
║  PR aperte: [N]  ·  Da fare review: [lista nomi]            ║
╚══════════════════════════════════════════════════════════════╝
```

---

## `omega/team-state.md` — Tracking team (aggiorna ad ogni cambio)

```markdown
# Team State
Aggiornato: [timestamp]
Sprint: [N] · [data inizio] → [data fine]

## Developer
| Nome | Branch | RF | Stato | PR | Reviewer |
|---|---|---|---|---|---|
| Alice | feature/giacenze | RF-042 | IN_CORSO | — | — |
| Bob | fix/advisory-lock | RF-051 | IN_REVIEW | #47 | Alice |
| Carlo | feature/pdf-ddt | RF-038 | MERGED | — | — |

## PR Aperte
| PR | Branch | Autore | Reviewer | Stato | Blocco |
|---|---|---|---|---|---|
| #47 | fix/advisory-lock | Bob | Alice | WAITING_REVIEW | — |
| #48 | feature/giacenze | Alice | Bob | CHANGES_REQUESTED | attende fix |

## Dipendenze
- RF-042 (Alice) blocca RF-050 (Carlo) — Alice deve mergiare prima

## Sprint Backlog
| RF | Titolo | Assegnato | Stima | Stato |
|---|---|---|---|---|
| RF-038 | PDF DDT Uscita | Carlo | 2g | ✅ done |
| RF-042 | Giacenze per sede | Alice | 3g | 🔄 in corso |
| RF-050 | Export Excel | Carlo | 1g | 🔒 bloccato |
| RF-051 | Fix advisory lock | Bob | 0.5g | 👁 review |
```

---

## MULTI-PIANO — Un piano per developer/branch

Con team, ogni branch ha il suo piano. Il piano principale di omega rimane per il progetto, i piani per-branch sono in `omega/plans/team/`:

```
omega/plans/
├── team/
│   ├── alice_feature-giacenze.md    ← piano di Alice su feature/giacenze
│   ├── bob_fix-advisory-lock.md     ← piano di Bob
│   └── carlo_feature-pdf-ddt.md    ← piano di Carlo
└── [piani progetto globali]
```

### Struttura piano per-developer

```markdown
# Piano: [RF-XXX] [titolo feature]
Developer: [nome]
Branch: feature/[nome]
Sprint: [N]
Creato: [timestamp]

## RF associati
- RF-042: [titolo]

## Steps
- [ ] 1. Schema DB: aggiungere colonna giacenza_sede_id
      File: prisma/schema.prisma (oppure migrations/)
      Verifica: `npm run build` verde
- [ ] 2. Query: getGiacenzaPerSede()
      File: modules/giacenze/queries.ts
      Verifica: unit test passa
- [ ] 3. UI: componente GiacenzeTable con filtro sede
      File: app/(dashboard)/giacenze/page.tsx
      Verifica: pagina renderizza correttamente
- [ ] 4. Test integration: giacenza si aggiorna dopo movimento
      File: src/tests/integration/giacenze.test.ts
- [ ] 5. PR: apri verso main con description template

## Dipendenze
- Attende: nessuna
- Blocca: RF-050 (Carlo)

## Stato: IN_PROGRESS
```

---

## PR WORKFLOW

### Stati PR supportati da omega

| Stato | Significato | Prossima azione |
|---|---|---|
| `DRAFT` | In preparazione, non pronto per review | Developer completa il lavoro |
| `WAITING_REVIEW` | Pronto, reviewer non ancora iniziato | Reviewer assegnato prende in carico |
| `IN_REVIEW` | Reviewer sta leggendo | Reviewer lascia commenti o approva |
| `CHANGES_REQUESTED` | Richieste modifiche | Developer fa fix e ri-richiede review |
| `APPROVED` | Review superata | Developer fa merge (dopo CI verde) |
| `MERGED` | Mergiato in main | Aggiorna team-state.md |
| `CLOSED` | Chiuso senza merge | Documenta perché |

### Template PR description

```markdown
## Cosa fa questo PR
[1-3 frasi che descrivono la feature/fix]

## RF collegati
- Closes RF-042: Giacenze per sede
- Relates to RF-050: Export Excel

## Test plan
- [ ] Unit test: `npm test src/tests/unit/giacenze`
- [ ] Integration: `npm test src/tests/integration/giacenze`
- [ ] Manuale: naviga /giacenze, filtra per sede, verifica totali

## Screenshot (se UI)
[prima / dopo]

## Migration DB
- [ ] Sì — migration inclusa: `omega/migrations/[nome].sql`
- [x] No

## Checklist pre-merge
- [ ] Build verde (`npm run build`)
- [ ] Zero TypeScript errors
- [ ] Test passano
- [ ] Design system rispettato
- [ ] Nessun console.log debug
- [ ] .env non incluso
```

### Branch protection rules (consiglia all'utente di configurare)

```
main:
  - Require PR before merging
  - Require 1 approval minimum
  - Require status checks: build, test
  - No force push
  - No direct commits
```

---

## REVIEWER ASSIGNMENT

### Principi
- **Non auto-approvarti**: chi ha scritto il codice non può essere l'unico reviewer
- **Bilanciamento**: distribuisci il carico di review equamente
- **Expertise matching**: codice critico (DB, auth, pagamenti) → reviewer senior

### Matrice reviewer (configura in `omega/team-state.md`)

```markdown
## Reviewer Matrix
| Autore PR | Reviewer default | Backup |
|---|---|---|
| Alice | Bob | Carlo |
| Bob | Alice | Carlo |
| Carlo | Alice | Bob |
```

---

## SPRINT PLANNING — [menu voce SP]

### Processo

1. **Leggi backlog PRD**: tutte le RF non ancora implementate
2. **Stima capacità**: N developer × giorni disponibili × 0.7 (margine)
3. **Prioritizza** con l'utente: quali RF entrano nello sprint?
4. **Assegna** ogni RF a un developer (basandoti sulla matrice expertise)
5. **Crea piani per-developer** in `omega/plans/team/`
6. **Aggiorna `omega/team-state.md`** con sprint backlog

### Output sprint planning

```markdown
# Sprint [N] — [data inizio] → [data fine]
Generato: [timestamp]
Capacità team: [N developer × M giorni = X giorni/uomo]

## Backlog sprint
| RF | Titolo | Stima | Assegnato | Dipendenze |
|---|---|---|---|---|
| RF-042 | Giacenze per sede | 3g | Alice | — |
| RF-051 | Fix advisory lock | 0.5g | Bob | — |
| RF-050 | Export Excel | 1g | Carlo | RF-042 |

## Carico per developer
- Alice: 3g / 4g disponibili
- Bob: 0.5g / 4g disponibili
- Carlo: 1g / 4g disponibili (attende RF-042)

## Obiettivo sprint
Al termine: giacenze per sede funzionanti, advisory lock fixato, export Excel disponibile.

## Definition of Done
- [ ] Feature implementata e testata
- [ ] PR aperta con description completa
- [ ] Review approvata (min 1)
- [ ] Build CI verde
- [ ] Mergiata in main
```

---

## MERGE CONFLICT PROTOCOL

Quando ci sono conflitti su file condivisi:

### File ad alto rischio di conflitto

```
prisma/schema.prisma     → sempre potenziale conflitto
src/lib/db.ts            → cambia raramente ma criticamente
src/components/layout/Sidebar.tsx → navigation changes
package.json / package-lock.json  → conflitti di versioni dipendenze
```

### Processo risoluzione

```
1. Chi mergia prima vince — gli altri devono fare rebase
   git fetch origin && git rebase origin/main

2. Per schema.prisma:
   - MAI fare merge automatico
   - Confronta le due versioni manualmente
   - Assicurati che le migration siano sequenziali

3. Per package.json:
   - Prendi ENTRAMBE le dipendenze nuove
   - Rigenera lock file: npm install

4. Dopo risoluzione: ri-riesegui test completi
```

### Prevenzione conflitti

```markdown
## Regole coordinamento (aggiungere a CLAUDE.md del progetto)

1. Avvisa il team nel canale Slack prima di modificare schema.prisma
2. Un solo developer alla volta modifica Sidebar.tsx
3. Fai rebase frequente (almeno ogni giorno lavorativo)
4. Branch di vita max: 3 giorni — branch più lunghi = conflitti certi
```

---

## DAILY STANDUP — Contesto rapido

Quando l'utente chiede "standup di oggi" o "stato giornaliero":

```
📅 STANDUP — [data]

👤 [Developer A] — branch: feature/[nome]
   Ieri: [cosa ha fatto — da team-state]
   Oggi: [prossimo step del piano]
   Blocco: [sì/no — e quale]

👤 [Developer B] — PR #[N] in WAITING_REVIEW
   Ieri: aperta PR #[N] per RF-[XXX]
   Oggi: attende review di [reviewer]
   Blocco: [sì — review pendente]

🚨 BLOCCHI ATTIVI
   - Bob attende review Alice su PR #47 (da 2 giorni)
   - Carlo bloccato su RF-050 fino a merge Alice

📋 PR DA REVIEWARE OGGI
   - #47 (Bob → Alice): fix advisory lock — priorità ALTA
```

---

## RELEASE — Tag + Changelog

```bash
# Genera changelog da conventional commits
npx conventional-changelog-cli -p angular -i CHANGELOG.md -s

# Tag release
git tag -a v1.2.0 -m "Release v1.2.0 — giacenze per sede, export Excel, fix advisory lock"
git push origin v1.2.0
# → triggera GitHub Actions deploy
```

### `CHANGELOG.md` — formato

```markdown
# Changelog

## [1.2.0] — 2026-04-15

### Features
- RF-042: Giacenze per sede con filtro e drill-down (#52)
- RF-050: Export Excel giacenze e movimenti (#54)

### Bug Fixes
- RF-051: Race condition nella numerazione DDT con advisory lock (#47)

### Breaking Changes
- Nessuna
```

---

## CHECKLIST TEAM

- [ ] `omega/team-state.md` creato e aggiornato
- [ ] Branch protection configurata su main
- [ ] Reviewer matrix definita
- [ ] PR template in `.github/pull_request_template.md`
- [ ] Sprint backlog assegnato con stime
- [ ] Nessun branch più vecchio di 3 giorni senza merge/rebase
- [ ] Tutti i PR con almeno 1 review approvata prima del merge
- [ ] CHANGELOG aggiornato ad ogni release
