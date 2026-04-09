# FastAPI — Setup, Struttura, Auth JWT, Endpoint

Doc ufficiale: https://fastapi.tiangolo.com
Pydantic: https://docs.pydantic.dev

## Scelta framework

| Scenario | Framework |
|---|---|
| API REST / GraphQL moderna | **FastAPI** (async, OpenAPI automatico, Pydantic) |
| App web con template HTML | **Django** (admin, ORM, auth inclusi) |
| App semplice / prototipo | **Flask** (minimalista) |
| Script / automation / pipeline dati | **Script Python puro** + Click/Typer per CLI |
| ML / AI | **FastAPI** + background tasks |

## Setup progetto

```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

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
    "asyncpg>=0.30",
    "pydantic>=2.7",
    "pydantic-settings>=2.3",
    "python-jose[cryptography]>=3.3",
    "passlib[bcrypt]>=1.7",
    "python-multipart>=0.0.9",
]

[project.optional-dependencies]
dev = [
    "pytest>=8",
    "pytest-asyncio>=0.23",
    "httpx>=0.27",
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

## Struttura progetto

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

## Config — `core/config.py`

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    APP_NAME: str = "Mio Progetto"
    DEBUG: bool = False
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    DATABASE_URL: str
    REDIS_URL: str | None = None
    SENDGRID_API_KEY: str | None = None

settings = Settings()
```

## Entry Point — `main.py`

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from src.db.base import engine, Base
from src.api.v1.router import api_router
from src.core.config import settings

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()

app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
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

## Auth JWT

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

# api/deps.py
from fastapi import Depends, HTTPException
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

## Endpoint Pattern

```python
# api/v1/ordini.py
from fastapi import APIRouter, Depends
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

## Background Tasks

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

## Comandi

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
```
