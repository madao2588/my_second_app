from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.common import BoolData, IdData, PageData
from app.schemas.user import UserCreate, UserListItem, UserQuery, UserRead, UserRoleAssign, UserUpdate
from app.services.user_service import UserService

router = APIRouter()


@router.get("", response_model=ApiResponse[PageData[UserListItem]])
def list_users(
    query: UserQuery = Depends(),
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("user:view")),
) -> ApiResponse[PageData[UserListItem]]:
    data = UserService(db).list_users(query)
    return ApiResponse(data=data)


@router.get("/{user_id}", response_model=ApiResponse[UserRead])
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("user:view")),
) -> ApiResponse[UserRead]:
    data = UserService(db).get_user(user_id)
    return ApiResponse(data=data)


@router.post("", response_model=ApiResponse[IdData])
def create_user(
    payload: UserCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("user:add")),
) -> ApiResponse[IdData]:
    data = UserService(db).create_user(payload)
    return ApiResponse(message="创建成功", data=data)


@router.put("/{user_id}", response_model=ApiResponse[UserRead])
def update_user(
    user_id: int,
    payload: UserUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("user:edit")),
) -> ApiResponse[UserRead]:
    data = UserService(db).update_user(user_id, payload)
    return ApiResponse(message="更新成功", data=data)


@router.delete("/{user_id}", response_model=ApiResponse[BoolData])
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_permission("user:delete")),
) -> ApiResponse[BoolData]:
    UserService(db).delete_user(user_id, current_user_id=current_user.id)
    return ApiResponse(message="删除成功", data=BoolData())


@router.put("/{user_id}/roles", response_model=ApiResponse[UserRead])
def assign_roles(
    user_id: int,
    payload: UserRoleAssign,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("user:assign-role")),
) -> ApiResponse[UserRead]:
    data = UserService(db).assign_roles(user_id, payload)
    return ApiResponse(message="角色分配成功", data=data)
