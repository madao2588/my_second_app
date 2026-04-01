from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field

from app.schemas.common import AuditSchema, PageQuery


class EmployeeQuery(PageQuery):
    keyword: str | None = None
    dept_id: int | None = None
    status: str | None = None
    sort_by: str = "created_at"
    sort_order: str = "desc"


class EmployeeBase(BaseModel):
    emp_no: str = Field(..., max_length=50)
    name: str = Field(..., max_length=50)
    gender: str = Field(..., max_length=10)
    phone: str | None = Field(default=None, max_length=20)
    email: EmailStr | None = None
    dept_id: int
    position_id: int
    leader_id: int | None = None
    status: str = "active"
    hire_date: date
    left_at: datetime | None = None
    deleted_at: datetime | None = None
    birth_date: date | None = None
    address: str | None = Field(default=None, max_length=255)
    remark: str | None = Field(default=None, max_length=255)
    is_deleted: bool = False


class EmployeeCreate(EmployeeBase):
    pass


class EmployeeUpdate(BaseModel):
    name: str | None = None
    gender: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    dept_id: int | None = None
    position_id: int | None = None
    leader_id: int | None = None
    status: str | None = None
    hire_date: date | None = None
    left_at: datetime | None = None
    birth_date: date | None = None
    address: str | None = None
    remark: str | None = None
    is_deleted: bool | None = None


class EmployeeRead(EmployeeBase, AuditSchema):
    id: int


class EmployeeListItem(BaseModel):
    id: int
    emp_no: str
    name: str
    gender: str
    phone: str | None = None
    email: str | None = None
    dept_id: int
    dept_name: str
    position_id: int
    position_name: str
    leader_id: int | None = None
    leader_name: str | None = None
    status: str
    hire_date: date
    created_at: datetime
