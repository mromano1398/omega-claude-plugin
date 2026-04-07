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

---

## SCELTA FRAMEWORK

| Scenario | Framework |
|---|---|
| API REST / GraphQL moderna | **FastAPI** (async, OpenAPI automatico, Pydantic) |
| App web con template HTML | **Django** (admin, ORM, auth inclusi) |
| App semplice / prototipo | **Flask** (minimalista) |
| Script / automation / pipeline dati | **Script Python puro** + Click/Typer per CLI |
| ML / AI | **FastAPI** + background tasks |

---

## SETUP PROGETTO — FastAPI

```bash
# Crea virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Struttura progetto
mkdir -p src/{api,core,db,models,schemas,services} tests
touch pyproject.toml .env.example README.md
```

### `pyproject.toml`

```toml
[project]
name = "mio-progetto"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115",
    "uvicorn[standard]>=0.30",
    "sqlalchemy[asyncio]>=2.0",
    "alembic>=1.13",
    "asyncpg>=0.30",          # PostgreSQL async driver
    "pydantic>=2.7",
    "pydantic-settings>=2.3",
    "python-jose[cryptography]>=3.3",  # JWT
    "passlib[bcrypt]>=1.7",
    "python-multipart>=0.0.9",
]

[project.optional-dependencies]
dev = [
    "pytest>=8",
    "pytest-asyncio>=0.23",
    "httpx>=0.27",            # Test client asincrono
    "ruff>=0.4",
    "mypy>=1.10",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.pytest.ini_options]
asyncio_mode = "auto"
```

```bash
pip install -e ".[dev]"
```

---

## STRUTTURA PROGETTO

```
src/
├── main.py              ← Entry point FastAPI
├── core/
│   ├── config.py        ← Settings con pydantic-settings
│   └── security.py      ← JWT, password hashing
├── db/
│   ├── base.py          ← Base SQLAlchemy + engine
│   └── session.py       ← Dependency get_db
├── models/              ← SQLAlchemy models (ORM)
│   ├── utente.py
│   └── ordine.py
├── schemas/             ← Pydantic schemas (request/response)
│   ├── utente.py
│   └── ordine.py
├── api/
│   ├── deps.py          ← Shared dependencies (auth check)
│   └── v1/
│       ├── router.py    ← Aggrega tutti i router
│       ├── utenti.py
│       └── ordini.py
└── services/            ← Business logic
    ├── utenti.py
    └── ordini.py
```

---

## CONFIG — `core/config.py`

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # App
    APP_NAME: str = "Mio Progetto"
    DEBUG: bool = False
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Database
    DATABASE_URL: str

    # Opzionali
    REDIS_URL: str | None = None
    SENDGRID_API_KEY: str | None = None

settings = Settings()
```

---

## DATABASE — SQLAlchemy 2.0 async

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

---

## MIGRATIONS — Alembic

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
```

---

## ENTRY POINT — `main.py`

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from src.db.base import engine, Base
from src.api.v1.router import api_router
from src.core.config import settings

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    await engine.dispose()

app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",      # Swagger UI
    redoc_url="/redoc",    # ReDoc
    openapi_url="/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://mioapp.com"],  # NON usare * in produzione
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True,
)

app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health():
    return {"status": "ok"}
```

---

## AUTH JWT — Pattern completo

```python
# core/security.py
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
from src.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(data: dict) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return jwt.encode({**data, "exp": expire}, settings.SECRET_KEY, algorithm="HS256")

# api/deps.py — dependency auth
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession
from src.db.session import get_db
from src.models.utente import Utente
from sqlalchemy import select

security = HTTPBearer()

async def get_current_user(
    token: str = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> Utente:
    try:
        payload = jwt.decode(token.credentials, settings.SECRET_KEY, algorithms=["HS256"])
        utente_id: int = payload.get("sub")
        if not utente_id:
            raise HTTPException(status_code=401, detail="Token non valido")
    except JWTError:
        raise HTTPException(status_code=401, detail="Token non valido o scaduto")

    result = await db.execute(select(Utente).where(Utente.id == utente_id))
    utente = result.scalar_one_or_none()
    if not utente or not utente.attivo:
        raise HTTPException(status_code=401, detail="Utente non trovato")
    return utente
```

---

## ENDPOINT PATTERN

```python
# api/v1/ordini.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from src.db.session import get_db
from src.api.deps import get_current_user
from src.models.utente import Utente
from src.schemas.ordine import OrdineCreate, OrdineResponse
from src.services.ordini import OrdiniService

router = APIRouter(prefix="/ordini", tags=["ordini"])

@router.get("/", response_model=list[OrdineResponse])
async def lista_ordini(
    db: AsyncSession = Depends(get_db),
    current_user: Utente = Depends(get_current_user),
):
    service = OrdiniService(db)
    return await service.get_by_user(current_user.id)

@router.post("/", response_model=OrdineResponse, status_code=201)
async def crea_ordine(
    payload: OrdineCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Utente = Depends(get_current_user),
):
    service = OrdiniService(db)
    return await service.create(payload, current_user.id)
```

---

## TEST — pytest + httpx

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

---

## BACKGROUND TASKS

```python
# Task semplice (in-process, per operazioni brevi < 30s)
from fastapi import BackgroundTasks

@router.post("/invita")
async def invia_invito(
    email: str,
    background_tasks: BackgroundTasks,
    current_user: Utente = Depends(get_current_user),
):
    background_tasks.add_task(send_invite_email, email, current_user)
    return {"status": "invito in elaborazione"}

# Task pesanti (usa Celery o ARQ per task > 30s)
# pip install arq
```

---

## DOCKER

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

---

## COMANDI

```bash
# Avvio sviluppo (auto-reload)
uvicorn src.main:app --reload

# Test
pytest tests/ -v --tb=short
pytest tests/ --cov=src --cov-report=html

# Lint + format
ruff check src/ tests/
ruff format src/ tests/

# Type check
mypy src/

# Migration
alembic revision --autogenerate -m "descrizione"
alembic upgrade head
```

---

## CHECKLIST PYTHON

- [ ] Virtual environment attivo e `pyproject.toml` con dipendenze pinned
- [ ] `pydantic-settings` per config da env (no hardcoded)
- [ ] SQLAlchemy 2.0 async con `asyncpg`
- [ ] Alembic configurato, migration autogenerate funzionante
- [ ] Auth JWT con hash bcrypt per password
- [ ] CORS configurato con origini specifiche (non `*`)
- [ ] `/health` endpoint (per Docker + monitoring)
- [ ] Test con transazione rollback (DB sempre pulito)
- [ ] Dockerfile multi-stage con user non-root
- [ ] Ruff + mypy nel CI
