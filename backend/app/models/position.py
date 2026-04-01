from sqlalchemy import Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import AuditMixin, Base, ID_TYPE


class Position(AuditMixin, Base):
    __tablename__ = "positions"
    __table_args__ = (UniqueConstraint("position_code", name="uk_positions_position_code"),)

    id: Mapped[int] = mapped_column(ID_TYPE, primary_key=True, autoincrement=True)
    position_code: Mapped[str] = mapped_column(String(50), nullable=False)
    position_name: Mapped[str] = mapped_column(String(100), nullable=False)
    level_name: Mapped[str | None] = mapped_column(String(50), nullable=True)
    status: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    remark: Mapped[str | None] = mapped_column(String(255), nullable=True)

    employees = relationship("Employee", back_populates="position")
