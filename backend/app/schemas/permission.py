from pydantic import BaseModel, Field

from app.schemas.common import AuditSchema


class PermissionBase(BaseModel):
    perm_code: str = Field(..., max_length=100)
    perm_name: str = Field(..., max_length=100)
    perm_type: str = Field(..., max_length=20)
    parent_id: int | None = None
    route_path: str | None = None
    icon: str | None = None
    sort_order: int = 0
    status: int = 1


class PermissionCreate(PermissionBase):
    pass


class PermissionUpdate(BaseModel):
    perm_name: str | None = None
    perm_type: str | None = None
    parent_id: int | None = None
    route_path: str | None = None
    icon: str | None = None
    sort_order: int | None = None
    status: int | None = None


class PermissionRead(PermissionBase, AuditSchema):
    id: int


class PermissionNode(PermissionRead):
    children: list["PermissionNode"] = Field(default_factory=list)


PermissionNode.model_rebuild()
