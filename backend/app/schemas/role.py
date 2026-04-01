from pydantic import BaseModel, Field

from app.schemas.common import AuditSchema, PageQuery


class RoleBase(BaseModel):
    role_code: str = Field(..., max_length=50)
    role_name: str = Field(..., max_length=50)
    status: int = 1
    remark: str | None = None


class RoleCreate(RoleBase):
    pass


class RoleUpdate(BaseModel):
    role_name: str | None = None
    status: int | None = None
    remark: str | None = None


class RoleRead(RoleBase, AuditSchema):
    id: int
    user_count: int = 0
    permission_count: int = 0
    permission_ids: list[int] = Field(default_factory=list)


class RoleQuery(PageQuery):
    keyword: str | None = None
    status: int | None = None


class RoleListItem(AuditSchema):
    id: int
    role_code: str
    role_name: str
    status: int
    remark: str | None = None
    user_count: int = 0
    permission_count: int = 0


class RolePermissionAssign(BaseModel):
    permission_ids: list[int] = Field(default_factory=list)
