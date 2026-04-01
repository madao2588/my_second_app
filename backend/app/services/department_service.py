from sqlalchemy.orm import Session

from app.core.exceptions import AppException
from app.models.department import Department
from app.repositories.department_repository import DepartmentRepository
from app.repositories.employee_repository import EmployeeRepository
from app.schemas.common import IdData, PageData
from app.schemas.department import (
    DepartmentCreate,
    DepartmentListItem,
    DepartmentOption,
    DepartmentQuery,
    DepartmentRead,
    DepartmentUpdate,
)


class DepartmentService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = DepartmentRepository(db)
        self.employee_repository = EmployeeRepository(db)

    def list_departments(self, query: DepartmentQuery) -> PageData[DepartmentListItem]:
        return self.repository.list_departments(query)

    def get_department(self, department_id: int) -> DepartmentRead:
        department = self.repository.get_department(department_id)
        if department is None:
            raise AppException("部门不存在", 404)
        return self.repository.to_read_schema(department)

    def create_department(self, payload: DepartmentCreate) -> IdData:
        if self.repository.get_by_code(payload.dept_code) is not None:
            raise AppException("部门编码已存在", 400)

        parent = self._validate_parent(payload.parent_id)
        self._validate_leader(payload.leader_employee_id)

        department = self.repository.create_department(payload)
        level, path = self._build_hierarchy(department.id, parent)
        self.repository.apply_hierarchy(department, level, path)

        self.db.commit()
        return IdData(id=department.id)

    def update_department(self, department_id: int, payload: DepartmentUpdate) -> DepartmentRead:
        department = self.repository.get_department(department_id)
        if department is None:
            raise AppException("部门不存在", 404)

        old_path = department.path
        old_level = department.level

        parent_changed = "parent_id" in payload.model_fields_set
        parent = self._validate_parent(payload.parent_id if parent_changed else department.parent_id)
        self._validate_leader(
            payload.leader_employee_id
            if "leader_employee_id" in payload.model_fields_set
            else department.leader_employee_id
        )

        if parent is not None and parent.path.startswith(f"{old_path}"):
            raise AppException("上级部门不能选择当前部门或其下级部门", 400)

        updated = self.repository.update_department(department, payload)

        if parent_changed:
            new_level, new_path = self._build_hierarchy(updated.id, parent)
            self.repository.apply_hierarchy(updated, new_level, new_path)
            self._sync_descendants(updated.id, old_path, new_path, old_level, new_level)

        self.db.commit()
        return self.repository.to_read_schema(updated)

    def delete_department(self, department_id: int) -> None:
        department = self.repository.get_department(department_id)
        if department is None:
            raise AppException("部门不存在", 404)

        if self.repository.count_children(department_id) > 0:
            raise AppException("该部门下存在子部门，无法删除", 400)
        if self.repository.count_active_employees(department_id) > 0:
            raise AppException("该部门下存在员工，无法删除", 400)

        self.repository.delete_department(department)
        self.db.commit()

    def list_options(self) -> list[DepartmentOption]:
        departments = self.repository.list_active()
        return [
            DepartmentOption(id=item.id, dept_name=item.dept_name)
            for item in departments
        ]

    def _validate_parent(self, parent_id: int | None) -> Department | None:
        if parent_id is None:
            return None
        parent = self.repository.get_department(parent_id)
        if parent is None:
            raise AppException("上级部门不存在", 400)
        return parent

    def _validate_leader(self, leader_employee_id: int | None) -> None:
        if leader_employee_id is None:
            return
        employee = self.employee_repository.get_employee(leader_employee_id)
        if employee is None:
            raise AppException("部门负责人不存在", 400)

    @staticmethod
    def _build_hierarchy(department_id: int, parent: Department | None) -> tuple[int, str]:
        if parent is None:
            return 1, f"/{department_id}/"
        return parent.level + 1, f"{parent.path}{department_id}/"

    def _sync_descendants(
        self,
        department_id: int,
        old_path: str,
        new_path: str,
        old_level: int,
        new_level: int,
    ) -> None:
        level_delta = new_level - old_level
        descendants = self.repository.list_descendants(old_path, department_id)
        for item in descendants:
            item.path = item.path.replace(old_path, new_path, 1)
            item.level = item.level + level_delta
            self.db.add(item)
        self.db.flush()
