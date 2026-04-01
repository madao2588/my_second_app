from datetime import date, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.department import Department
from app.models.employee import Employee
from app.models.position import Position
from app.schemas.dashboard import ChartPoint, DashboardSummary, LatestHireItem


class DashboardRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_summary(self, employee_id: int | None = None) -> DashboardSummary:
        today = date.today()
        month_start = today.replace(day=1)
        next_month = (
            today.replace(year=today.year + 1, month=1, day=1)
            if today.month == 12
            else today.replace(month=today.month + 1, day=1)
        )

        base_filters = [Employee.is_deleted.is_(False)]
        total_employees = self.db.scalar(
            select(func.count(Employee.id)).where(*base_filters)
        ) or 0
        month_hires = self.db.scalar(
            select(func.count(Employee.id)).where(
                *base_filters,
                Employee.hire_date >= month_start,
                Employee.hire_date < next_month,
            )
        ) or 0
        month_leaves = self.db.scalar(
            select(func.count(Employee.id)).where(
                *base_filters,
                Employee.left_at.is_not(None),
                Employee.left_at >= datetime.combine(month_start, datetime.min.time()),
                Employee.left_at < datetime.combine(next_month, datetime.min.time()),
            )
        ) or 0

        active_departments = self.db.scalar(
            select(func.count(Department.id)).where(Department.status == 1)
        ) or 0
        avg_department_headcount = round(
            total_employees / active_departments, 1
        ) if active_departments else 0.0

        user_join_days = 0
        if employee_id is not None:
            hire_date = self.db.scalar(
                select(Employee.hire_date).where(
                    Employee.id == employee_id,
                    Employee.is_deleted.is_(False),
                )
            )
            if hire_date is not None:
                user_join_days = max((today - hire_date).days + 1, 1)

        return DashboardSummary(
            total_employees=int(total_employees),
            month_hires=int(month_hires),
            month_leaves=int(month_leaves),
            avg_department_headcount=avg_department_headcount,
            user_join_days=user_join_days,
        )

    def get_department_distribution(self) -> list[ChartPoint]:
        stmt = (
            select(Department.dept_name, func.count(Employee.id).label("employee_count"))
            .join(Employee, Employee.dept_id == Department.id)
            .where(Employee.is_deleted.is_(False))
            .group_by(Department.id, Department.dept_name)
            .order_by(func.count(Employee.id).desc(), Department.id.asc())
        )
        return [
            ChartPoint(name=name, value=int(value))
            for name, value in self.db.execute(stmt).all()
        ]

    def get_position_distribution(self) -> list[ChartPoint]:
        stmt = (
            select(Position.position_name, func.count(Employee.id).label("employee_count"))
            .join(Employee, Employee.position_id == Position.id)
            .where(Employee.is_deleted.is_(False))
            .group_by(Position.id, Position.position_name)
            .order_by(func.count(Employee.id).desc(), Position.id.asc())
        )
        return [
            ChartPoint(name=name, value=int(value))
            for name, value in self.db.execute(stmt).all()
        ]

    def get_latest_hires(self, limit: int = 5) -> list[LatestHireItem]:
        stmt = (
            select(
                Employee.id,
                Employee.name,
                Department.dept_name,
                Position.position_name,
                Employee.hire_date,
            )
            .join(Department, Department.id == Employee.dept_id)
            .join(Position, Position.id == Employee.position_id)
            .where(Employee.is_deleted.is_(False))
            .order_by(Employee.hire_date.desc(), Employee.id.desc())
            .limit(limit)
        )
        return [
            LatestHireItem(
                id=employee_id,
                name=name,
                dept_name=dept_name,
                position_name=position_name,
                hire_date=hire_date,
            )
            for employee_id, name, dept_name, position_name, hire_date in self.db.execute(stmt).all()
        ]
