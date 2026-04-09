---
name: omega-team
description: Use when working in a team of 2+ developers, coordinating parallel feature work, managing PR workflows, planning sprints, tracking who is doing what, or handling merge conflicts. Triggered by mentions of "team", "developer", "PR", "sprint", "review", "branch per feature".
user-invocable: false
---

# omega-team — Coordinamento Team · PR · Sprint · Multi-piano

**Lingua:** Sempre italiano.
**Contesto:** Questa sub-skill estende omega per team da 2 a 8 developer. Non sostituisce il workflow Git — lo orchestra e lo documenta.

## QUANDO USARE

- Team di 2+ developer su stesso progetto
- Coordinamento branch paralleli con dipendenze
- Gestione PR review e approvazioni
- Sprint planning e assegnazione task
- Standup e stato giornaliero
- Release con tag + changelog

## FLUSSO DECISIONALE

```
Nuova feature → crea piano in omega/plans/team/[developer]_[branch].md
                → aggiorna team-state.md

PR aperta → assegna reviewer dalla matrice
          → aggiorna stato in team-state.md
          → blocco se dipendenze non risolte

Sprint → leggi PRD → stima capacità (N dev × giorni × 0.7)
       → prioritizza → assegna → aggiorna team-state.md

Release → conventional commits → changelog → tag semver → deploy
```

## REGOLE CHIAVE

1. **Un piano per developer per branch** — in `omega/plans/team/`
2. **Non auto-approvarti** — chi scrive il codice non fa review da solo
3. **Branch vita max 3 giorni** — branch più lunghi = conflitti certi
4. **Rebase frequente** — almeno ogni giorno lavorativo
5. **schema.prisma: MAI merge automatico** — confronta manualmente
6. **Reviewer senior su codice critico** — DB, auth, pagamenti
7. **CI verde prima del merge** — build + test obbligatori
8. **Aggiorna team-state.md ad ogni cambio** — fonte di verità del team
9. **Blocchi comunicati subito** — non aspettare lo standup
10. **Tag semver per ogni release** — triggera deploy automatico

## CHECKLIST SINTETICA

- [ ] `omega/team-state.md` creato e aggiornato
- [ ] Branch protection configurata su main
- [ ] Reviewer matrix definita
- [ ] PR template in `.github/pull_request_template.md`
- [ ] Sprint backlog assegnato con stime
- [ ] Nessun branch più vecchio di 3 giorni senza merge/rebase
- [ ] Tutti i PR con almeno 1 review approvata prima del merge
- [ ] CHANGELOG aggiornato ad ogni release

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/pr-workflow.md] — stati PR, template description, branch protection, reviewer assignment, merge conflict protocol, release e changelog
- [references/sprint.md] — team-state.md format, vista aggregata team, multi-piano per developer, sprint planning, daily standup

## MIGRATION PARALLELE — Prisma in team

Il problema più comune in team con Prisma: due developer creano migration su branch diversi
che poi collidono su `prisma/migrations/` al momento del merge.

### Regola d'oro: migration su branch dedicato
```
feature/add-payment-fields     ← solo codice applicativo
migration/add-payment-fields   ← solo schema.prisma + migration
```
La migration viene mergiata PRIMA del branch feature. Il feature branch poi fa rebase.

### Naming convention migration
```bash
# Sempre con timestamp preciso per evitare conflitti:
npx prisma migrate dev --name "$(date +%Y%m%d_%H%M)_add_payment_fields_[initials]"
# Esempio: 20260409_1430_add_payment_fields_MR
```

### Shadow database per CI
```env
# .env.test (non committare)
DATABASE_URL="postgresql://user:pass@localhost:5432/mydb_test"
SHADOW_DATABASE_URL="postgresql://user:pass@localhost:5432/mydb_shadow"
```
```json
{
  "scripts": {
    "prisma:migrate:ci": "prisma migrate deploy",
    "prisma:migrate:dev": "prisma migrate dev"
  }
}
```

### Checklist review migration PR
- [ ] Migration è reversibile (o ha piano di rollback documentato)?
- [ ] Aggiunge colonne come nullable prima di NOT NULL?
- [ ] Non droppa colonne con dati senza piano di migrazione dati?
- [ ] Non tocca tabelle con lock durante ore di punta?
- [ ] `prisma generate` è stato rieseguito dopo la migration?
- [ ] Il team è stato avvisato: "migration in arrivo, fare pull prima del prossimo sviluppo"
