from sqlalchemy.orm import Session

from app.core.exceptions import AppException
from app.core.security import create_access_token, verify_password
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.auth import CurrentRole, CurrentUserInfo, LoginResponse, MeResponse


class AuthService:
    def __init__(self, db: Session):
        self.user_repository = UserRepository(db)

    def login(self, username: str, password: str) -> LoginResponse:
        user = self.user_repository.get_by_username(username)
        if user is None or user.status != 1:
            raise AppException("账号不存在或已禁用", 401)

        if not verify_password(password, user.password_hash):
            raise AppException("用户名或密码错误", 401)

        permissions = self._extract_permissions(user)
        token = create_access_token({"sub": str(user.id), "username": user.username})

        return LoginResponse(
            access_token=token,
            user_info=CurrentUserInfo(
                id=user.id,
                username=user.username,
                real_name=user.real_name,
                employee_id=user.employee_id,
            ),
            permissions=permissions,
        )

    @staticmethod
    def get_me(user: User) -> MeResponse:
        return MeResponse(
            id=user.id,
            username=user.username,
            real_name=user.real_name,
            employee_id=user.employee_id,
            roles=[
                CurrentRole(id=role.id, role_code=role.role_code, role_name=role.role_name)
                for role in user.roles
            ],
            permissions=AuthService._extract_permissions(user),
        )

    @staticmethod
    def _extract_permissions(user: User) -> list[str]:
        permission_codes = {
            permission.perm_code
            for role in user.roles
            for permission in role.permissions
            if permission.status == 1
        }
        return sorted(permission_codes)
