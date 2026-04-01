from pydantic import BaseModel, Field

from app.schemas.common import AuditSchema, PageQuery


class DepartmentQuery(PageQuery):
    keyword: str | None = None
    status: int | None = None


class DepartmentBase(BaseModel):
    dept_code: str = Field(..., max_length=50)
    dept_name: str = Field(..., max_length=100)
    parent_id: int | None = None
    leader_employee_id: int | None = None
    sort_order: int = 0
    status: int = 1
    remark: str | None = None


class DepartmentCreate(DepartmentBase):
    pass


class DepartmentUpdate(BaseModel):
    dept_name: str | None = None
    parent_id: int | None = None
    leader_employee_id: int | None = None
    sort_order: int | None = None
    status: int | None = None
    remark: str | None = None


class DepartmentListItem(AuditSchema):
    id: int
    dept_code: str
    dept_name: str
    parent_id: int | None = None
    parent_name: str | None = None
    leader_employee_id: int | None = None
    leader_name: str | None = None
    level: int
    path: str
    sort_order: int
    status: int
    remark: str | None = None


class DepartmentRead(DepartmentListItem):
    pass


class DepartmentOption(BaseModel):
    id: int
    dept_name: str
