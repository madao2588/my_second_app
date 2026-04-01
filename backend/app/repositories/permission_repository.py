from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.permission import Permission


class PermissionRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_permissions(self) -> list[Permission]:
        stmt = select(Permission).order_by(
            Permission.sort_order.asc(),
            Permission.id.asc(),
        )
        return list(self.db.execute(stmt).scalars().all())

    def list_active_permissions(self) -> list[Permission]:
        stmt = (
            select(Permission)
            .where(Permission.status == 1)
            .order_by(Permission.sort_order.asc(), Permission.id.asc())
        )
        return list(self.db.execute(stmt).scalars().all())

    def get_by_ids(self, permission_ids: list[int]) -> list[Permission]:
        if not permission_ids:
            return []
        stmt = select(Permission).where(Permission.id.in_(permission_ids))
        return list(self.db.execute(stmt).scalars().all())
