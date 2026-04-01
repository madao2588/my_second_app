from sqlalchemy.orm import Session

from app.core.exceptions import AppException
from app.core.security import get_password_hash
from app.models.user import User
from app.repositories.employee_repository import EmployeeRepository
from app.repositories.role_repository import RoleRepository
from app.repositories.user_repository import UserRepository
from app.schemas.common import IdData, PageData
from app.schemas.user import UserCreate, UserListItem, UserQuery, UserRead, UserRoleAssign, UserUpdate


class UserService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = UserRepository(db)
        self.employee_repository = EmployeeRepository(db)
        self.role_repository = RoleRepository(db)

    def list_users(self, query: UserQuery) -> PageData[UserListItem]:
        return self.repository.list_users(query)

    def get_user(self, user_id: int) -> UserRead:
        user = self.repository.get_by_id(user_id)
        if user is None:
            raise AppException("用户不存在", 404)
        return self.repository.to_read_schema(user)

    def create_user(self, payload: UserCreate) -> IdData:
        if self.repository.get_by_username(payload.username) is not None:
            raise AppException("登录账号已存在", 400)

        self._validate_employee(payload.employee_id)
        user = self.repository.create_user(payload, get_password_hash(payload.password))
        self.db.commit()
        return IdData(id=user.id)

    def update_user(self, user_id: int, payload: UserUpdate) -> UserRead:
        user = self.repository.get_by_id(user_id)
        if user is None:
            raise AppException("用户不存在", 404)

        employee_id = (
            payload.employee_id
            if "employee_id" in payload.model_fields_set
            else user.employee_id
        )
        self._validate_employee(employee_id, exclude_user_id=user_id)

        updated = self.repository.update_user(user, payload)
        self.db.commit()
        return self.repository.to_read_schema(updated)

    def delete_user(self, user_id: int, current_user_id: int | None = None) -> None:
        user = self.repository.get_by_id(user_id)
        if user is None:
            raise AppException("用户不存在", 404)
        if current_user_id is not None and user.id == current_user_id:
            raise AppException("不能删除当前登录账号", 400)
        self.repository.delete_user(user)
        self.db.commit()

    def assign_roles(self, user_id: int, payload: UserRoleAssign) -> UserRead:
        user = self.repository.get_by_id(user_id)
        if user is None:
            raise AppException("用户不存在", 404)

        roles = self.role_repository.get_by_ids(payload.role_ids)
        if len(roles) != len(set(payload.role_ids)):
            raise AppException("存在无效角色，无法完成分配", 400)

        user.roles = roles
        self.db.add(user)
        self.db.commit()
        refreshed = self.repository.get_by_id(user_id)
        if refreshed is None:
            raise AppException("用户不存在", 404)
        return self.repository.to_read_schema(refreshed)

    def _validate_employee(
        self,
        employee_id: int | None,
        exclude_user_id: int | None = None,
    ) -> None:
        if employee_id is None:
            return
        employee = self.employee_repository.get_employee(employee_id)
        if employee is None:
            raise AppException("关联员工不存在", 400)
        bound = self.repository.get_by_employee_id(employee_id)
        if bound is not None and bound.id != exclude_user_id:
            raise AppException("该员工已绑定其他账号", 400)
