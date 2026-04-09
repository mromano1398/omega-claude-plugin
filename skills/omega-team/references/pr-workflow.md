# PR Workflow — Gestione Pull Request

## Stati PR supportati da omega

| Stato | Significato | Prossima azione |
|---|---|---|
| `DRAFT` | In preparazione, non pronto per review | Developer completa il lavoro |
| `WAITING_REVIEW` | Pronto, reviewer non ancora iniziato | Reviewer assegnato prende in carico |
| `IN_REVIEW` | Reviewer sta leggendo | Reviewer lascia commenti o approva |
| `CHANGES_REQUESTED` | Richieste modifiche | Developer fa fix e ri-richiede review |
| `APPROVED` | Review superata | Developer fa merge (dopo CI verde) |
| `MERGED` | Mergiato in main | Aggiorna team-state.md |
| `CLOSED` | Chiuso senza merge | Documenta perché |

## Template PR description

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

## Branch protection rules (consiglia all'utente di configurare)

```
main:
  - Require PR before merging
  - Require 1 approval minimum
  - Require status checks: build, test
  - No force push
  - No direct commits
```

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

## MERGE CONFLICT PROTOCOL

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
