from pydantic import BaseModel, Field


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenPayload(BaseModel):
    sub: str


class CurrentUserInfo(BaseModel):
    id: int
    username: str
    real_name: str
    employee_id: int | None = None


class CurrentRole(BaseModel):
    id: int
    role_code: str
    role_name: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "Bearer"
    user_info: CurrentUserInfo
    permissions: list[str] = Field(default_factory=list)


class MeResponse(BaseModel):
    id: int
    username: str
    real_name: str
    employee_id: int | None = None
    roles: list[CurrentRole] = Field(default_factory=list)
    permissions: list[str] = Field(default_factory=list)
