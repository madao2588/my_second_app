from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.common import BoolData, IdData, PageData
from app.schemas.employee import EmployeeCreate, EmployeeListItem, EmployeeQuery, EmployeeRead, EmployeeUpdate
from app.services.employee_service import EmployeeService

router = APIRouter()


@router.get("", response_model=ApiResponse[PageData[EmployeeListItem]])
def list_employees(
    query: EmployeeQuery = Depends(),
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("emp:view")),
) -> ApiResponse[PageData[EmployeeListItem]]:
    data = EmployeeService(db).list_employees(query)
    return ApiResponse(data=data)


@router.get("/{employee_id}", response_model=ApiResponse[EmployeeRead])
def get_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("emp:view")),
) -> ApiResponse[EmployeeRead]:
    data = EmployeeService(db).get_employee(employee_id)
    return ApiResponse(data=data)


@router.post("", response_model=ApiResponse[IdData])
def create_employee(
    payload: EmployeeCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("emp:add")),
) -> ApiResponse[IdData]:
    data = EmployeeService(db).create_employee(payload)
    return ApiResponse(message="创建成功", data=data)


@router.put("/{employee_id}", response_model=ApiResponse[EmployeeRead])
def update_employee(
    employee_id: int,
    payload: EmployeeUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("emp:edit")),
) -> ApiResponse[EmployeeRead]:
    data = EmployeeService(db).update_employee(employee_id, payload)
    return ApiResponse(message="更新成功", data=data)


@router.delete("/{employee_id}", response_model=ApiResponse[BoolData])
def delete_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("emp:delete")),
) -> ApiResponse[BoolData]:
    EmployeeService(db).delete_employee(employee_id)
    return ApiResponse(message="删除成功", data=BoolData())
