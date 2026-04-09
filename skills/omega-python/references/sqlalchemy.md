# SQLAlchemy + Alembic + pytest

Doc ufficiale:
- SQLAlchemy: https://docs.sqlalchemy.org
- Alembic: https://alembic.sqlalchemy.org
- pytest: https://docs.pytest.org
- Ruff: https://docs.astral.sh/ruff

## SQLAlchemy 2.0 Async

```python
# db/base.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase

engine = create_async_engine(
    settings.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://"),
    echo=settings.DEBUG,
    pool_size=10,
    max_overflow=20,
)

AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

class Base(DeclarativeBase):
    pass

# db/session.py — dependency per FastAPI
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

```python
# models/utente.py
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from src.db.base import Base

class Utente(Base):
    __tablename__ = "utenti"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    nome: Mapped[str | None] = mapped_column(String(100))
    attivo: Mapped[bool] = mapped_column(Boolean, default=True)
    creato_il: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
```

## Alembic — Migrations

```bash
# Inizializza Alembic
alembic init alembic

# Configura alembic/env.py — aggiungi:
# from src.db.base import Base
# from src.models import *  # importa tutti i modelli
# target_metadata = Base.metadata

# Crea migration automatica (da diff tra modelli e DB)
alembic revision --autogenerate -m "aggiungi tabella utenti"

# Applica migration
alembic upgrade head

# Torna indietro di 1
alembic downgrade -1

# Stato attuale
alembic current

# Migration
alembic revision --autogenerate -m "descrizione"
alembic upgrade head
```

## Test — pytest + httpx

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from src.main import app
from src.db.base import Base
from src.db.session import get_db

TEST_DATABASE_URL = "postgresql+asyncpg://postgres:test@localhost:5432/testdb"

@pytest.fixture(scope="session")
async def test_engine():
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest.fixture
async def db_session(test_engine):
    # Transazione rollback per ogni test (DB sempre pulito)
    async with test_engine.connect() as conn:
        await conn.begin()
        session = AsyncSession(bind=conn)
        yield session
        await session.close()
        await conn.rollback()

@pytest.fixture
async def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()

# tests/test_ordini.py
async def test_crea_ordine_autenticato(client, db_session, utente_factory):
    utente = await utente_factory(db_session)
    token = create_access_token({"sub": utente.id})

    response = await client.post(
        "/api/v1/ordini/",
        json={"articoli": [{"id": 1, "quantita": 2}]},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 201
    assert response.json()["stato"] == "BOZZA"

async def test_ordine_senza_auth_401(client):
    response = await client.post("/api/v1/ordini/", json={})
    assert response.status_code == 403  # HTTPBearer → 403 senza token
```

## Docker

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Dipendenze prima (cache ottimizzata)
COPY pyproject.toml .
RUN pip install --no-cache-dir -e .

COPY src/ ./src/

RUN adduser --disabled-password --gecos "" appuser
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

```yaml
# docker-compose.yml
services:
  api:
    build: .
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s

volumes:
  pgdata:
```
