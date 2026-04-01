from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.auth import LoginRequest, LoginResponse, MeResponse
from app.services.auth_service import AuthService

router = APIRouter()


@router.post("/login", response_model=ApiResponse[LoginResponse])
def login(
    payload: LoginRequest,
    db: Session = Depends(get_db),
) -> ApiResponse[LoginResponse]:
    data = AuthService(db).login(payload.username, payload.password)
    return ApiResponse(data=data)


@router.get("/me", response_model=ApiResponse[MeResponse])
def me(current_user: User = Depends(get_current_user)) -> ApiResponse[MeResponse]:
    data = AuthService.get_me(current_user)
    return ApiResponse(data=data)
