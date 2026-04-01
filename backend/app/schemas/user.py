from datetime import datetime

from pydantic import BaseModel, EmailStr, Field

from app.schemas.common import AuditSchema, PageQuery


class UserBase(BaseModel):
    username: str = Field(..., max_length=50)
    real_name: str = Field(..., max_length=50)
    phone: str | None = Field(default=None, max_length=20)
    email: EmailStr | None = None
    employee_id: int | None = None
    status: int = 1


class UserCreate(UserBase):
    password: str = Field(..., min_length=6, max_length=50)


class UserUpdate(BaseModel):
    real_name: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    employee_id: int | None = None
    status: int | None = None


class UserRead(UserBase, AuditSchema):
    id: int
    last_login_at: datetime | None = None
    employee_name: str | None = None
    role_ids: list[int] = Field(default_factory=list)
    role_names: list[str] = Field(default_factory=list)


class UserQuery(PageQuery):
    keyword: str | None = None
    status: int | None = None


class UserListItem(AuditSchema):
    id: int
    username: str
    real_name: str
    phone: str | None = None
    email: EmailStr | None = None
    employee_id: int | None = None
    employee_name: str | None = None
    status: int
    last_login_at: datetime | None = None
    role_ids: list[int] = Field(default_factory=list)
    role_names: list[str] = Field(default_factory=list)


class UserRoleAssign(BaseModel):
    role_ids: list[int] = Field(default_factory=list)
