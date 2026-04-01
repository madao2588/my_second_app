from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.common import BoolData, IdData, PageData
from app.schemas.position import (
    PositionCreate,
    PositionListItem,
    PositionOption,
    PositionQuery,
    PositionRead,
    PositionUpdate,
)
from app.services.position_service import PositionService

router = APIRouter()


@router.get("", response_model=ApiResponse[PageData[PositionListItem]])
def list_positions(
    query: PositionQuery = Depends(),
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("position:view")),
) -> ApiResponse[PageData[PositionListItem]]:
    data = PositionService(db).list_positions(query)
    return ApiResponse(data=data)


@router.get("/options", response_model=ApiResponse[list[PositionOption]])
def list_position_options(
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("position:view")),
) -> ApiResponse[list[PositionOption]]:
    data = PositionService(db).list_options()
    return ApiResponse(data=data)


@router.get("/{position_id}", response_model=ApiResponse[PositionRead])
def get_position(
    position_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("position:view")),
) -> ApiResponse[PositionRead]:
    data = PositionService(db).get_position(position_id)
    return ApiResponse(data=data)


@router.post("", response_model=ApiResponse[IdData])
def create_position(
    payload: PositionCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("position:add")),
) -> ApiResponse[IdData]:
    data = PositionService(db).create_position(payload)
    return ApiResponse(message="创建成功", data=data)


@router.put("/{position_id}", response_model=ApiResponse[PositionRead])
def update_position(
    position_id: int,
    payload: PositionUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("position:edit")),
) -> ApiResponse[PositionRead]:
    data = PositionService(db).update_position(position_id, payload)
    return ApiResponse(message="更新成功", data=data)


@router.delete("/{position_id}", response_model=ApiResponse[BoolData])
def delete_position(
    position_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("position:delete")),
) -> ApiResponse[BoolData]:
    PositionService(db).delete_position(position_id)
    return ApiResponse(message="删除成功", data=BoolData())
