---
name: omega-python
description: Use when the project is Python-based — FastAPI, Django, Flask, data pipelines, scripts, CLI tools, or AI/ML workloads. Covers project setup, FastAPI patterns, SQLAlchemy + Alembic, pytest, Docker, background tasks, and deployment. Triggered by mentions of "Python", "FastAPI", "Django", "Flask", "pandas", "script Python", "data pipeline".
user-invocable: false
---

# omega-python — FastAPI · SQLAlchemy · Alembic · pytest · Docker

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- FastAPI: https://fastapi.tiangolo.com
- SQLAlchemy: https://docs.sqlalchemy.org
- Alembic: https://alembic.sqlalchemy.org
- Pydantic: https://docs.pydantic.dev
- pytest: https://docs.pytest.org
- Ruff: https://docs.astral.sh/ruff

## QUANDO USARE

- Progetto Python: FastAPI, Django, Flask, script, pipeline dati
- Setup nuovo progetto con virtual environment e pyproject.toml
- API REST con autenticazione JWT
- Migration DB con Alembic
- Test con pytest + httpx (transazione rollback)
- Build Docker per deployment

## FLUSSO DECISIONALE

```
Nuovo progetto:
→ FastAPI (API REST async) | Django (app web + admin) | Flask (prototipo) | Script puro

Setup base FastAPI:
1. Virtual environment + pyproject.toml
2. Struttura src/{api,core,db,models,schemas,services}
3. SQLAlchemy 2.0 async + asyncpg
4. Alembic per migrations
5. Auth JWT con bcrypt
6. pytest con transazione rollback
7. Dockerfile + docker-compose
```

## REGOLE CHIAVE

1. **`pydantic-settings` per config** — mai hardcoded in codice
2. **SQLAlchemy 2.0 async** con `asyncpg` — non la versione sync
3. **Alembic `--autogenerate`** dopo ogni modifica ai models
4. **`expire_on_commit=False`** in `async_sessionmaker` — obbligatorio per async
5. **Test con transazione rollback** — DB sempre pulito dopo ogni test
6. **CORS con origini specifiche** — mai `*` in produzione
7. **`/health` endpoint** sempre implementato (per Docker + monitoring)
8. **User non-root nel Dockerfile** — sicurezza container
9. **Ruff + mypy nel CI** — lint e type check obbligatori
10. **4 workers uvicorn** in produzione (`--workers 4`)

## CHECKLIST SINTETICA

- [ ] Virtual environment attivo e `pyproject.toml` con dipendenze pinned
- [ ] `pydantic-settings` per config da env (no hardcoded)
- [ ] SQLAlchemy 2.0 async con `asyncpg`
- [ ] Alembic configurato, migration autogenerate funzionante
- [ ] Auth JWT con hash bcrypt per password
- [ ] CORS configurato con origini specifiche (non `*`)
- [ ] `/health` endpoint (per Docker + monitoring)
- [ ] Test con transazione rollback (DB sempre pulito)
- [ ] Dockerfile con user non-root
- [ ] Ruff + mypy nel CI

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/fastapi.md] — setup, pyproject.toml, struttura progetto, config, main.py, auth JWT, endpoint pattern, background tasks, comandi
- [references/sqlalchemy.md] — SQLAlchemy 2.0 async, models, Alembic migrations, test pytest+httpx con rollback, Docker
