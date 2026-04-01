from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.common import BoolData, IdData, PageData
from app.schemas.department import (
    DepartmentCreate,
    DepartmentListItem,
    DepartmentOption,
    DepartmentQuery,
    DepartmentRead,
    DepartmentUpdate,
)
from app.services.department_service import DepartmentService

router = APIRouter()


@router.get("", response_model=ApiResponse[PageData[DepartmentListItem]])
def list_departments(
    query: DepartmentQuery = Depends(),
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dept:view")),
) -> ApiResponse[PageData[DepartmentListItem]]:
    data = DepartmentService(db).list_departments(query)
    return ApiResponse(data=data)


@router.get("/options", response_model=ApiResponse[list[DepartmentOption]])
def list_department_options(
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dept:view")),
) -> ApiResponse[list[DepartmentOption]]:
    data = DepartmentService(db).list_options()
    return ApiResponse(data=data)


@router.get("/{department_id}", response_model=ApiResponse[DepartmentRead])
def get_department(
    department_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dept:view")),
) -> ApiResponse[DepartmentRead]:
    data = DepartmentService(db).get_department(department_id)
    return ApiResponse(data=data)


@router.post("", response_model=ApiResponse[IdData])
def create_department(
    payload: DepartmentCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dept:add")),
) -> ApiResponse[IdData]:
    data = DepartmentService(db).create_department(payload)
    return ApiResponse(message="创建成功", data=data)


@router.put("/{department_id}", response_model=ApiResponse[DepartmentRead])
def update_department(
    department_id: int,
    payload: DepartmentUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dept:edit")),
) -> ApiResponse[DepartmentRead]:
    data = DepartmentService(db).update_department(department_id, payload)
    return ApiResponse(message="更新成功", data=data)


@router.delete("/{department_id}", response_model=ApiResponse[BoolData])
def delete_department(
    department_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dept:delete")),
) -> ApiResponse[BoolData]:
    DepartmentService(db).delete_department(department_id)
    return ApiResponse(message="删除成功", data=BoolData())
