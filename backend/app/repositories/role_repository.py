from sqlalchemy import Select, func, or_, select
from sqlalchemy.orm import Session, joinedload

from app.models.role import Role
from app.schemas.common import PageData
from app.schemas.role import RoleCreate, RoleListItem, RoleQuery, RoleRead, RoleUpdate


class RoleRepository:
    def __init__(self, db: Session):
        self.db = db

    def _base_query(self) -> Select[tuple[Role]]:
        return select(Role).options(joinedload(Role.users), joinedload(Role.permissions))

    def list_roles(self, query: RoleQuery) -> PageData[RoleListItem]:
        filters = []
        if query.keyword:
            keyword = f"%{query.keyword.strip()}%"
            filters.append(
                or_(
                    Role.role_code.ilike(keyword),
                    Role.role_name.ilike(keyword),
                    Role.remark.ilike(keyword),
                )
            )
        if query.status is not None:
            filters.append(Role.status == query.status)

        total = self.db.scalar(select(func.count(Role.id)).where(*filters)) or 0
        stmt = (
            self._base_query()
            .where(*filters)
            .order_by(Role.id.asc())
            .offset((query.page - 1) * query.page_size)
            .limit(query.page_size)
        )
        roles = self.db.execute(stmt).unique().scalars().all()
        items = [self.to_list_item(item) for item in roles]
        return PageData(items=items, total=total, page=query.page, page_size=query.page_size)

    def list_all(self) -> list[Role]:
        stmt = self._base_query().order_by(Role.id.asc())
        return list(self.db.execute(stmt).unique().scalars().all())

    def list_active(self) -> list[Role]:
        stmt = self._base_query().where(Role.status == 1).order_by(Role.id.asc())
        return list(self.db.execute(stmt).unique().scalars().all())

    def get_role(self, role_id: int) -> Role | None:
        stmt = self._base_query().where(Role.id == role_id)
        return self.db.execute(stmt).unique().scalar_one_or_none()

    def get_by_code(self, role_code: str) -> Role | None:
        stmt = self._base_query().where(Role.role_code == role_code)
        return self.db.execute(stmt).unique().scalar_one_or_none()

    def get_by_ids(self, role_ids: list[int]) -> list[Role]:
        if not role_ids:
            return []
        stmt = self._base_query().where(Role.id.in_(role_ids))
        return list(self.db.execute(stmt).unique().scalars().all())

    def create_role(self, payload: RoleCreate) -> Role:
        role = Role(**payload.model_dump())
        self.db.add(role)
        self.db.flush()
        self.db.refresh(role)
        return self.get_role(role.id) or role

    def update_role(self, role: Role, payload: RoleUpdate) -> Role:
        for key, value in payload.model_dump(exclude_unset=True).items():
            setattr(role, key, value)
        self.db.add(role)
        self.db.flush()
        self.db.refresh(role)
        return self.get_role(role.id) or role

    def delete_role(self, role: Role) -> None:
        self.db.delete(role)
        self.db.flush()

    @staticmethod
    def to_list_item(role: Role) -> RoleListItem:
        return RoleListItem(
            id=role.id,
            role_code=role.role_code,
            role_name=role.role_name,
            status=role.status,
            remark=role.remark,
            user_count=len(role.users),
            permission_count=len([item for item in role.permissions if item.status == 1]),
            created_at=role.created_at,
            updated_at=role.updated_at,
            created_by=role.created_by,
            updated_by=role.updated_by,
        )

    @staticmethod
    def to_read_schema(role: Role) -> RoleRead:
        return RoleRead(
            id=role.id,
            role_code=role.role_code,
            role_name=role.role_name,
            status=role.status,
            remark=role.remark,
            user_count=len(role.users),
            permission_count=len([item for item in role.permissions if item.status == 1]),
            permission_ids=[item.id for item in role.permissions],
            created_at=role.created_at,
            updated_at=role.updated_at,
            created_by=role.created_by,
            updated_by=role.updated_by,
        )
