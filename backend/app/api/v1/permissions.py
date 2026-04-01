from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.permission import PermissionNode
from app.services.permission_service import PermissionService

router = APIRouter()


@router.get("/tree", response_model=ApiResponse[list[PermissionNode]])
def get_permission_tree(
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("role:view")),
) -> ApiResponse[list[PermissionNode]]:
    data = PermissionService(db).get_tree()
    return ApiResponse(data=data)
