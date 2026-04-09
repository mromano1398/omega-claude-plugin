# Sprint — Planning, Tracking, Standup

## `omega/team-state.md` — Tracking team

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

## STATO TEAM — Vista aggregata

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

## MULTI-PIANO — Un piano per developer/branch

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

## SPRINT PLANNING — Processo

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

## DAILY STANDUP

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
