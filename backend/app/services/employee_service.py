from datetime import datetime

from sqlalchemy.orm import Session

from app.core.exceptions import AppException
from app.models.employee import Employee
from app.repositories.department_repository import DepartmentRepository
from app.repositories.employee_repository import EmployeeRepository
from app.repositories.position_repository import PositionRepository
from app.schemas.common import IdData, PageData
from app.schemas.employee import EmployeeCreate, EmployeeListItem, EmployeeQuery, EmployeeRead, EmployeeUpdate


class EmployeeService:
    def __init__(self, db: Session):
        self.db = db
        self.employee_repository = EmployeeRepository(db)
        self.department_repository = DepartmentRepository(db)
        self.position_repository = PositionRepository(db)

    def list_employees(self, query: EmployeeQuery) -> PageData[EmployeeListItem]:
        return self.employee_repository.list_employees(query)

    def get_employee(self, employee_id: int) -> EmployeeRead:
        employee = self.employee_repository.get_employee(employee_id)
        if employee is None:
            raise AppException("员工不存在", 404)
        return self.employee_repository.to_read_schema(employee)

    def create_employee(self, payload: EmployeeCreate) -> IdData:
        self._validate_create_payload(payload)
        employee = self.employee_repository.create_employee(payload)
        self.db.commit()
        return IdData(id=employee.id)

    def update_employee(self, employee_id: int, payload: EmployeeUpdate) -> EmployeeRead:
        employee = self.employee_repository.get_employee(employee_id)
        if employee is None:
            raise AppException("员工不存在", 404)

        self._validate_update_payload(employee, payload)
        updated = self.employee_repository.update_employee(employee, payload)
        self.db.commit()
        return self.employee_repository.to_read_schema(updated)

    def delete_employee(self, employee_id: int) -> None:
        employee = self.employee_repository.get_employee(employee_id)
        if employee is None:
            raise AppException("员工不存在", 404)

        employee.deleted_at = datetime.utcnow()
        self.employee_repository.soft_delete_employee(employee)
        self.db.commit()

    def _validate_create_payload(self, payload: EmployeeCreate) -> None:
        if self.employee_repository.get_by_emp_no(payload.emp_no) is not None:
            raise AppException("工号已存在", 400)

        self._validate_related_entities(payload.dept_id, payload.position_id, payload.leader_id)
        self._validate_leave_time(payload.status, payload.left_at)

    def _validate_update_payload(self, employee: Employee, payload: EmployeeUpdate) -> None:
        dept_id = payload.dept_id if payload.dept_id is not None else employee.dept_id
        position_id = payload.position_id if payload.position_id is not None else employee.position_id
        leader_id = payload.leader_id if payload.leader_id is not None else employee.leader_id
        status = payload.status if payload.status is not None else employee.status
        left_at = payload.left_at if payload.left_at is not None else employee.left_at

        self._validate_related_entities(dept_id, position_id, leader_id)
        self._validate_leave_time(status, left_at)

        if leader_id is not None and leader_id == employee.id:
            raise AppException("直属上级不能选择自己", 400)

    def _validate_related_entities(
        self,
        dept_id: int,
        position_id: int,
        leader_id: int | None,
    ) -> None:
        if not self.department_repository.exists(dept_id):
            raise AppException("部门不存在", 400)
        if not self.position_repository.exists(position_id):
            raise AppException("岗位不存在", 400)
        if leader_id is not None and self.employee_repository.get_employee(leader_id) is None:
            raise AppException("直属上级不存在", 400)

    @staticmethod
    def _validate_leave_time(status: str, left_at: datetime | None) -> None:
        if status == "left" and left_at is None:
            raise AppException("离职员工必须填写离职时间", 400)
