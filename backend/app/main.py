from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import settings
from app.core.database import SessionLocal, create_db_tables
from app.core.exceptions import register_exception_handlers
from app.services.bootstrap_service import BootstrapService


@asynccontextmanager
async def lifespan(_: FastAPI):
    if settings.auto_create_tables:
        create_db_tables()
    if settings.auto_seed_data:
        db = SessionLocal()
        try:
            BootstrapService(db).seed_if_needed()
        finally:
            db.close()
    yield


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

register_exception_handlers(app)
app.include_router(api_router, prefix=settings.api_prefix)
