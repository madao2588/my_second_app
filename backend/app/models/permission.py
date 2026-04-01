from sqlalchemy import ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import AuditMixin, Base, ID_TYPE
from app.models.role import role_permissions


class Permission(AuditMixin, Base):
    __tablename__ = "permissions"
    __table_args__ = (UniqueConstraint("perm_code", name="uk_permissions_perm_code"),)

    id: Mapped[int] = mapped_column(ID_TYPE, primary_key=True, autoincrement=True)
    perm_code: Mapped[str] = mapped_column(String(100), nullable=False)
    perm_name: Mapped[str] = mapped_column(String(100), nullable=False)
    perm_type: Mapped[str] = mapped_column(String(20), nullable=False)
    parent_id: Mapped[int | None] = mapped_column(
        ID_TYPE, ForeignKey("permissions.id"), nullable=True
    )
    route_path: Mapped[str | None] = mapped_column(String(200), nullable=True)
    icon: Mapped[str | None] = mapped_column(String(100), nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    status: Mapped[int] = mapped_column(Integer, nullable=False, default=1)

    parent = relationship("Permission", remote_side=[id], back_populates="children")
    children = relationship("Permission", back_populates="parent")
    roles = relationship("Role", secondary=role_permissions, back_populates="permissions")
