from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session, aliased, joinedload

from app.models.department import Department
from app.models.employee import Employee
from app.models.position import Position
from app.schemas.common import PageData
from app.schemas.employee import EmployeeCreate, EmployeeListItem, EmployeeQuery, EmployeeRead, EmployeeUpdate


class EmployeeRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_employees(self, query: EmployeeQuery) -> PageData[EmployeeListItem]:
        leader = aliased(Employee)
        filters = [Employee.is_deleted.is_(False)]

        if query.keyword:
            keyword = f"%{query.keyword.strip()}%"
            filters.append(
                or_(
                    Employee.name.ilike(keyword),
                    Employee.emp_no.ilike(keyword),
                    Employee.phone.ilike(keyword),
                )
            )
        if query.dept_id is not None:
            filters.append(Employee.dept_id == query.dept_id)
        if query.status:
            filters.append(Employee.status == query.status)

        count_stmt = select(func.count(Employee.id)).where(*filters)
        total = self.db.scalar(count_stmt) or 0

        sort_column = {
            "created_at": Employee.created_at,
            "hire_date": Employee.hire_date,
            "name": Employee.name,
            "emp_no": Employee.emp_no,
        }.get(query.sort_by, Employee.created_at)

        if query.sort_order.lower() == "asc":
            order_by = sort_column.asc()
        else:
            order_by = sort_column.desc()

        stmt = (
            select(Employee, Department.dept_name, Position.position_name, leader.name.label("leader_name"))
            .join(Department, Department.id == Employee.dept_id)
            .join(Position, Position.id == Employee.position_id)
            .outerjoin(leader, leader.id == Employee.leader_id)
            .where(*filters)
            .order_by(order_by)
            .offset((query.page - 1) * query.page_size)
            .limit(query.page_size)
        )

        rows = self.db.execute(stmt).all()
        items = [
            EmployeeListItem(
                id=employee.id,
                emp_no=employee.emp_no,
                name=employee.name,
                gender=employee.gender,
                phone=employee.phone,
                email=employee.email,
                dept_id=employee.dept_id,
                dept_name=dept_name,
                position_id=employee.position_id,
                position_name=position_name,
                leader_id=employee.leader_id,
                leader_name=leader_name,
                status=employee.status,
                hire_date=employee.hire_date,
                created_at=employee.created_at,
            )
            for employee, dept_name, position_name, leader_name in rows
        ]

        return PageData(items=items, total=total, page=query.page, page_size=query.page_size)

    def get_employee(self, employee_id: int) -> Employee | None:
        stmt = (
            select(Employee)
            .options(
                joinedload(Employee.department),
                joinedload(Employee.position),
                joinedload(Employee.leader),
            )
            .where(Employee.id == employee_id, Employee.is_deleted.is_(False))
        )
        return self.db.execute(stmt).scalar_one_or_none()

    def get_by_emp_no(self, emp_no: str) -> Employee | None:
        stmt = select(Employee).where(Employee.emp_no == emp_no, Employee.is_deleted.is_(False))
        return self.db.execute(stmt).scalar_one_or_none()

    def create_employee(self, payload: EmployeeCreate) -> Employee:
        employee = Employee(**payload.model_dump())
        self.db.add(employee)
        self.db.flush()
        self.db.refresh(employee)
        return employee

    def update_employee(self, employee: Employee, payload: EmployeeUpdate) -> Employee:
        for key, value in payload.model_dump(exclude_unset=True).items():
            setattr(employee, key, value)
        self.db.add(employee)
        self.db.flush()
        self.db.refresh(employee)
        return employee

    def soft_delete_employee(self, employee: Employee) -> None:
        employee.is_deleted = True
        self.db.add(employee)
        self.db.flush()

    @staticmethod
    def to_read_schema(employee: Employee) -> EmployeeRead:
        return EmployeeRead.model_validate(employee, from_attributes=True)
