from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session, aliased, joinedload

from app.models.department import Department
from app.models.employee import Employee
from app.schemas.common import PageData
from app.schemas.department import (
    DepartmentCreate,
    DepartmentListItem,
    DepartmentQuery,
    DepartmentRead,
    DepartmentUpdate,
)


class DepartmentRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_departments(self, query: DepartmentQuery) -> PageData[DepartmentListItem]:
        parent = aliased(Department)
        leader = aliased(Employee)
        filters = []

        if query.keyword:
          keyword = f"%{query.keyword.strip()}%"
          filters.append(
              or_(
                  Department.dept_name.ilike(keyword),
                  Department.dept_code.ilike(keyword),
              )
          )
        if query.status is not None:
            filters.append(Department.status == query.status)

        total = self.db.scalar(select(func.count(Department.id)).where(*filters)) or 0

        stmt = (
            select(
                Department,
                parent.dept_name.label("parent_name"),
                leader.name.label("leader_name"),
            )
            .outerjoin(parent, parent.id == Department.parent_id)
            .outerjoin(leader, leader.id == Department.leader_employee_id)
            .where(*filters)
            .order_by(Department.sort_order.asc(), Department.id.asc())
            .offset((query.page - 1) * query.page_size)
            .limit(query.page_size)
        )

        rows = self.db.execute(stmt).all()
        items = [
            DepartmentListItem(
                id=department.id,
                dept_code=department.dept_code,
                dept_name=department.dept_name,
                parent_id=department.parent_id,
                parent_name=parent_name,
                leader_employee_id=department.leader_employee_id,
                leader_name=leader_name,
                level=department.level,
                path=department.path,
                sort_order=department.sort_order,
                status=department.status,
                remark=department.remark,
                created_at=department.created_at,
                updated_at=department.updated_at,
                created_by=department.created_by,
                updated_by=department.updated_by,
            )
            for department, parent_name, leader_name in rows
        ]
        return PageData(items=items, total=total, page=query.page, page_size=query.page_size)

    def list_active(self) -> list[Department]:
        stmt = (
            select(Department)
            .where(Department.status == 1)
            .order_by(Department.sort_order.asc(), Department.id.asc())
        )
        return list(self.db.execute(stmt).scalars().all())

    def get_department(self, department_id: int) -> Department | None:
        stmt = (
            select(Department)
            .options(joinedload(Department.parent), joinedload(Department.leader))
            .where(Department.id == department_id)
        )
        return self.db.execute(stmt).scalar_one_or_none()

    def get_by_code(self, dept_code: str) -> Department | None:
        stmt = select(Department).where(Department.dept_code == dept_code)
        return self.db.execute(stmt).scalar_one_or_none()

    def create_department(self, payload: DepartmentCreate) -> Department:
        department = Department(
            dept_code=payload.dept_code,
            dept_name=payload.dept_name,
            parent_id=payload.parent_id,
            leader_employee_id=payload.leader_employee_id,
            sort_order=payload.sort_order,
            status=payload.status,
            remark=payload.remark,
            level=1,
            path="/",
        )
        self.db.add(department)
        self.db.flush()
        self.db.refresh(department)
        return department

    def update_department(self, department: Department, payload: DepartmentUpdate) -> Department:
        for key, value in payload.model_dump(exclude_unset=True).items():
            setattr(department, key, value)
        self.db.add(department)
        self.db.flush()
        self.db.refresh(department)
        return department

    def apply_hierarchy(self, department: Department, level: int, path: str) -> None:
        department.level = level
        department.path = path
        self.db.add(department)
        self.db.flush()

    def list_descendants(self, old_path: str, exclude_id: int) -> list[Department]:
        stmt = (
            select(Department)
            .where(Department.path.like(f"{old_path}%"), Department.id != exclude_id)
            .order_by(Department.level.asc(), Department.id.asc())
        )
        return list(self.db.execute(stmt).scalars().all())

    def delete_department(self, department: Department) -> None:
        self.db.delete(department)
        self.db.flush()

    def count_children(self, department_id: int) -> int:
        stmt = select(func.count(Department.id)).where(Department.parent_id == department_id)
        return self.db.scalar(stmt) or 0

    def count_active_employees(self, department_id: int) -> int:
        stmt = select(func.count(Employee.id)).where(
            Employee.dept_id == department_id,
            Employee.is_deleted.is_(False),
        )
        return self.db.scalar(stmt) or 0

    def exists(self, department_id: int) -> bool:
        stmt = select(Department.id).where(Department.id == department_id, Department.status == 1)
        return self.db.execute(stmt).scalar_one_or_none() is not None

    @staticmethod
    def to_read_schema(department: Department) -> DepartmentRead:
        parent_name = department.parent.dept_name if department.parent is not None else None
        leader_name = department.leader.name if department.leader is not None else None
        return DepartmentRead(
            id=department.id,
            dept_code=department.dept_code,
            dept_name=department.dept_name,
            parent_id=department.parent_id,
            parent_name=parent_name,
            leader_employee_id=department.leader_employee_id,
            leader_name=leader_name,
            level=department.level,
            path=department.path,
            sort_order=department.sort_order,
            status=department.status,
            remark=department.remark,
            created_at=department.created_at,
            updated_at=department.updated_at,
            created_by=department.created_by,
            updated_by=department.updated_by,
        )
