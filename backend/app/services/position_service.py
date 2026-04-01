from sqlalchemy.orm import Session

from app.core.exceptions import AppException
from app.repositories.position_repository import PositionRepository
from app.schemas.common import IdData, PageData
from app.schemas.position import (
    PositionCreate,
    PositionListItem,
    PositionOption,
    PositionQuery,
    PositionRead,
    PositionUpdate,
)


class PositionService:
    def __init__(self, db: Session):
        self.repository = PositionRepository(db)
        self.db = db

    def list_positions(self, query: PositionQuery) -> PageData[PositionListItem]:
        return self.repository.list_positions(query)

    def get_position(self, position_id: int) -> PositionRead:
        position = self.repository.get_position(position_id)
        if position is None:
            raise AppException("岗位不存在", 404)
        return self.repository.to_read_schema(position)

    def create_position(self, payload: PositionCreate) -> IdData:
        if self.repository.get_by_code(payload.position_code) is not None:
            raise AppException("岗位编码已存在", 400)
        position = self.repository.create_position(payload)
        self.db.commit()
        return IdData(id=position.id)

    def update_position(self, position_id: int, payload: PositionUpdate) -> PositionRead:
        position = self.repository.get_position(position_id)
        if position is None:
            raise AppException("岗位不存在", 404)
        updated = self.repository.update_position(position, payload)
        self.db.commit()
        return self.repository.to_read_schema(updated)

    def delete_position(self, position_id: int) -> None:
        position = self.repository.get_position(position_id)
        if position is None:
            raise AppException("岗位不存在", 404)
        if self.repository.count_active_employees(position_id) > 0:
            raise AppException("该岗位下存在员工，无法删除", 400)
        self.repository.delete_position(position)
        self.db.commit()

    def list_options(self) -> list[PositionOption]:
        positions = self.repository.list_active()
        return [
            PositionOption(id=item.id, position_name=item.position_name)
            for item in positions
        ]
