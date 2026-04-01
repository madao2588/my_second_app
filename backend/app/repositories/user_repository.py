from sqlalchemy import Select, func, or_, select
from sqlalchemy.orm import Session, joinedload

from app.models.employee import Employee
from app.models.role import Role
from app.models.user import User
from app.schemas.common import PageData
from app.schemas.user import UserCreate, UserListItem, UserQuery, UserRead, UserUpdate


class UserRepository:
    def __init__(self, db: Session):
        self.db = db

    def _base_query(self) -> Select[tuple[User]]:
        return select(User).options(
            joinedload(User.roles).joinedload(Role.permissions),
            joinedload(User.employee),
        )

    def get_by_username(self, username: str) -> User | None:
        stmt = self._base_query().where(User.username == username)
        return self.db.execute(stmt).unique().scalar_one_or_none()

    def get_by_id(self, user_id: int) -> User | None:
        stmt = self._base_query().where(User.id == user_id)
        return self.db.execute(stmt).unique().scalar_one_or_none()

    def list_users(self, query: UserQuery) -> PageData[UserListItem]:
        filters = []
        if query.keyword:
            keyword = f"%{query.keyword.strip()}%"
            filters.append(
                or_(
                    User.username.ilike(keyword),
                    User.real_name.ilike(keyword),
                    User.phone.ilike(keyword),
                    User.email.ilike(keyword),
                )
            )
        if query.status is not None:
            filters.append(User.status == query.status)

        total = self.db.scalar(select(func.count(User.id)).where(*filters)) or 0
        stmt = (
            self._base_query()
            .where(*filters)
            .order_by(User.id.asc())
            .offset((query.page - 1) * query.page_size)
            .limit(query.page_size)
        )
        users = self.db.execute(stmt).unique().scalars().all()
        items = [self.to_list_item(item) for item in users]
        return PageData(items=items, total=total, page=query.page, page_size=query.page_size)

    def get_by_employee_id(self, employee_id: int) -> User | None:
        stmt = self._base_query().where(User.employee_id == employee_id)
        return self.db.execute(stmt).unique().scalar_one_or_none()

    def create_user(self, payload: UserCreate, password_hash: str) -> User:
        user = User(
            username=payload.username,
            password_hash=password_hash,
            real_name=payload.real_name,
            phone=payload.phone,
            email=payload.email,
            employee_id=payload.employee_id,
            status=payload.status,
        )
        self.db.add(user)
        self.db.flush()
        self.db.refresh(user)
        return self.get_by_id(user.id) or user

    def update_user(self, user: User, payload: UserUpdate) -> User:
        for key, value in payload.model_dump(exclude_unset=True).items():
            setattr(user, key, value)
        self.db.add(user)
        self.db.flush()
        self.db.refresh(user)
        return self.get_by_id(user.id) or user

    def delete_user(self, user: User) -> None:
        self.db.delete(user)
        self.db.flush()

    @staticmethod
    def to_list_item(user: User) -> UserListItem:
        return UserListItem(
            id=user.id,
            username=user.username,
            real_name=user.real_name,
            phone=user.phone,
            email=user.email,
            employee_id=user.employee_id,
            employee_name=user.employee.name if user.employee is not None else None,
            status=user.status,
            last_login_at=user.last_login_at,
            role_ids=[role.id for role in user.roles],
            role_names=[role.role_name for role in user.roles],
            created_at=user.created_at,
            updated_at=user.updated_at,
            created_by=user.created_by,
            updated_by=user.updated_by,
        )

    @staticmethod
    def to_read_schema(user: User) -> UserRead:
        return UserRead(
            id=user.id,
            username=user.username,
            real_name=user.real_name,
            phone=user.phone,
            email=user.email,
            employee_id=user.employee_id,
            employee_name=user.employee.name if user.employee is not None else None,
            status=user.status,
            last_login_at=user.last_login_at,
            role_ids=[role.id for role in user.roles],
            role_names=[role.role_name for role in user.roles],
            created_at=user.created_at,
            updated_at=user.updated_at,
            created_by=user.created_by,
            updated_by=user.updated_by,
        )
