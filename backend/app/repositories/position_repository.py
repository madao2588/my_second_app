from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.employee import Employee
from app.models.position import Position
from app.schemas.common import PageData
from app.schemas.position import (
    PositionCreate,
    PositionListItem,
    PositionQuery,
    PositionRead,
    PositionUpdate,
)


class PositionRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_positions(self, query: PositionQuery) -> PageData[PositionListItem]:
        filters = []

        if query.keyword:
            keyword = f"%{query.keyword.strip()}%"
            filters.append(
                or_(
                    Position.position_name.ilike(keyword),
                    Position.position_code.ilike(keyword),
                    Position.level_name.ilike(keyword),
                )
            )
        if query.status is not None:
            filters.append(Position.status == query.status)

        total = self.db.scalar(select(func.count(Position.id)).where(*filters)) or 0
        stmt = (
            select(Position)
            .where(*filters)
            .order_by(Position.id.asc())
            .offset((query.page - 1) * query.page_size)
            .limit(query.page_size)
        )
        items = [
            PositionListItem(
                id=item.id,
                position_code=item.position_code,
                position_name=item.position_name,
                level_name=item.level_name,
                status=item.status,
                remark=item.remark,
                created_at=item.created_at,
                updated_at=item.updated_at,
                created_by=item.created_by,
                updated_by=item.updated_by,
            )
            for item in self.db.execute(stmt).scalars().all()
        ]
        return PageData(items=items, total=total, page=query.page, page_size=query.page_size)

    def list_active(self) -> list[Position]:
        stmt = select(Position).where(Position.status == 1).order_by(Position.id.asc())
        return list(self.db.execute(stmt).scalars().all())

    def get_position(self, position_id: int) -> Position | None:
        stmt = select(Position).where(Position.id == position_id)
        return self.db.execute(stmt).scalar_one_or_none()

    def get_by_code(self, position_code: str) -> Position | None:
        stmt = select(Position).where(Position.position_code == position_code)
        return self.db.execute(stmt).scalar_one_or_none()

    def create_position(self, payload: PositionCreate) -> Position:
        position = Position(**payload.model_dump())
        self.db.add(position)
        self.db.flush()
        self.db.refresh(position)
        return position

    def update_position(self, position: Position, payload: PositionUpdate) -> Position:
        for key, value in payload.model_dump(exclude_unset=True).items():
            setattr(position, key, value)
        self.db.add(position)
        self.db.flush()
        self.db.refresh(position)
        return position

    def delete_position(self, position: Position) -> None:
        self.db.delete(position)
        self.db.flush()

    def count_active_employees(self, position_id: int) -> int:
        stmt = select(func.count(Employee.id)).where(
            Employee.position_id == position_id,
            Employee.is_deleted.is_(False),
        )
        return self.db.scalar(stmt) or 0

    def exists(self, position_id: int) -> bool:
        stmt = select(Position.id).where(Position.id == position_id, Position.status == 1)
        return self.db.execute(stmt).scalar_one_or_none() is not None

    @staticmethod
    def to_read_schema(position: Position) -> PositionRead:
        return PositionRead(
            id=position.id,
            position_code=position.position_code,
            position_name=position.position_name,
            level_name=position.level_name,
            status=position.status,
            remark=position.remark,
            created_at=position.created_at,
            updated_at=position.updated_at,
            created_by=position.created_by,
            updated_by=position.updated_by,
        )
