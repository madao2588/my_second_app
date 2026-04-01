from collections.abc import Generator

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.core.security import decode_access_token
from app.models.user import User
from app.repositories.user_repository import UserRepository


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="未登录或 Token 缺失")

    token = authorization.replace("Bearer ", "", 1).strip()

    try:
        payload = decode_access_token(token)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)) from exc

    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token 无效")

    user = UserRepository(db).get_by_id(int(user_id))
    if user is None or user.status != 1:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="用户不存在或已禁用")

    return user


def require_permission(permission_code: str):
    def checker(current_user: User = Depends(get_current_user)) -> User:
        permission_codes = {
            permission.perm_code
            for role in current_user.roles
            for permission in role.permissions
            if permission.status == 1
        }
        if permission_code not in permission_codes:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="无权限访问该资源")
        return current_user

    return checker
