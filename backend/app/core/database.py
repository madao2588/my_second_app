import sys

try:
    import sqlite3  # noqa: F401
except ModuleNotFoundError:
    import pysqlite3 as sqlite3  # type: ignore

    sys.modules["sqlite3"] = sqlite3

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings
from app.models import Base

connect_args = {}
if settings.database_url.startswith("sqlite"):
    connect_args["check_same_thread"] = False

engine = create_engine(
    settings.database_url,
    future=True,
    pool_pre_ping=True,
    echo=settings.database_echo,
    connect_args=connect_args,
)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, class_=Session)


def create_db_tables() -> None:
    Base.metadata.create_all(bind=engine)
