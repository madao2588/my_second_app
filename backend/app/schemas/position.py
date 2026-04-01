from pydantic import BaseModel, Field

from app.schemas.common import AuditSchema, PageQuery


class PositionQuery(PageQuery):
    keyword: str | None = None
    status: int | None = None


class PositionBase(BaseModel):
    position_code: str = Field(..., max_length=50)
    position_name: str = Field(..., max_length=100)
    level_name: str | None = Field(default=None, max_length=50)
    status: int = 1
    remark: str | None = None


class PositionCreate(PositionBase):
    pass


class PositionUpdate(BaseModel):
    position_name: str | None = None
    level_name: str | None = None
    status: int | None = None
    remark: str | None = None


class PositionListItem(AuditSchema):
    id: int
    position_code: str
    position_name: str
    level_name: str | None = None
    status: int
    remark: str | None = None


class PositionRead(PositionListItem):
    pass


class PositionOption(BaseModel):
    id: int
    position_name: str
