from sqlalchemy.orm import Session

from app.core.exceptions import AppException
from app.repositories.permission_repository import PermissionRepository
from app.repositories.role_repository import RoleRepository
from app.schemas.common import IdData, PageData
from app.schemas.role import (
    RoleCreate,
    RoleListItem,
    RolePermissionAssign,
    RoleQuery,
    RoleRead,
    RoleUpdate,
)


class RoleService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = RoleRepository(db)
        self.permission_repository = PermissionRepository(db)

    def list_roles(self, query: RoleQuery) -> PageData[RoleListItem]:
        return self.repository.list_roles(query)

    def get_role(self, role_id: int) -> RoleRead:
        role = self.repository.get_role(role_id)
        if role is None:
            raise AppException("角色不存在", 404)
        return self.repository.to_read_schema(role)

    def create_role(self, payload: RoleCreate) -> IdData:
        if self.repository.get_by_code(payload.role_code) is not None:
            raise AppException("角色编码已存在", 400)
        role = self.repository.create_role(payload)
        self.db.commit()
        return IdData(id=role.id)

    def update_role(self, role_id: int, payload: RoleUpdate) -> RoleRead:
        role = self.repository.get_role(role_id)
        if role is None:
            raise AppException("角色不存在", 404)
        updated = self.repository.update_role(role, payload)
        self.db.commit()
        return self.repository.to_read_schema(updated)

    def delete_role(self, role_id: int) -> None:
        role = self.repository.get_role(role_id)
        if role is None:
            raise AppException("角色不存在", 404)
        if role.users:
            raise AppException("该角色已绑定用户，无法删除", 400)
        self.repository.delete_role(role)
        self.db.commit()

    def assign_permissions(self, role_id: int, payload: RolePermissionAssign) -> RoleRead:
        role = self.repository.get_role(role_id)
        if role is None:
            raise AppException("角色不存在", 404)
        permissions = self.permission_repository.get_by_ids(payload.permission_ids)
        if len(permissions) != len(set(payload.permission_ids)):
            raise AppException("存在无效权限，无法完成分配", 400)
        role.permissions = permissions
        self.db.add(role)
        self.db.commit()
        refreshed = self.repository.get_role(role_id)
        if refreshed is None:
            raise AppException("角色不存在", 404)
        return self.repository.to_read_schema(refreshed)
