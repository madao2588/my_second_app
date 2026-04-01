from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.common import BoolData, IdData, PageData
from app.schemas.role import (
    RoleCreate,
    RoleListItem,
    RolePermissionAssign,
    RoleQuery,
    RoleRead,
    RoleUpdate,
)
from app.services.role_service import RoleService

router = APIRouter()


@router.get("", response_model=ApiResponse[PageData[RoleListItem]])
def list_roles(
    query: RoleQuery = Depends(),
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:view")),
) -> ApiResponse[PageData[RoleListItem]]:
    data = RoleService(db).list_roles(query)
    return ApiResponse(data=data)


@router.get("/{role_id}", response_model=ApiResponse[RoleRead])
def get_role(
    role_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:view")),
) -> ApiResponse[RoleRead]:
    data = RoleService(db).get_role(role_id)
    return ApiResponse(data=data)


@router.post("", response_model=ApiResponse[IdData])
def create_role(
    payload: RoleCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:add")),
) -> ApiResponse[IdData]:
    data = RoleService(db).create_role(payload)
    return ApiResponse(message="创建成功", data=data)


@router.put("/{role_id}", response_model=ApiResponse[RoleRead])
def update_role(
    role_id: int,
    payload: RoleUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:edit")),
) -> ApiResponse[RoleRead]:
    data = RoleService(db).update_role(role_id, payload)
    return ApiResponse(message="更新成功", data=data)


@router.delete("/{role_id}", response_model=ApiResponse[BoolData])
def delete_role(
    role_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:delete")),
) -> ApiResponse[BoolData]:
    RoleService(db).delete_role(role_id)
    return ApiResponse(message="删除成功", data=BoolData())


@router.put("/{role_id}/permissions", response_model=ApiResponse[RoleRead])
def assign_permissions(
    role_id: int,
    payload: RolePermissionAssign,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:assign-permission")),
) -> ApiResponse[RoleRead]:
    data = RoleService(db).assign_permissions(role_id, payload)
    return ApiResponse(message="权限分配成功", data=data)
