from datetime import datetime
from typing import Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class AuditSchema(BaseModel):
    created_at: datetime
    updated_at: datetime
    created_by: int | None = None
    updated_by: int | None = None


class PageQuery(BaseModel):
    page: int = Field(default=1, ge=1)
    page_size: int = Field(default=10, ge=1, le=100)


class PageData(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int


class IdData(BaseModel):
    id: int


class BoolData(BaseModel):
    success: bool = True
