from sqlalchemy import Column, ForeignKey, Integer, String, Table, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import AuditMixin, Base, ID_TYPE

user_roles = Table(
    "user_roles",
    Base.metadata,
    Column("user_id", ID_TYPE, ForeignKey("users.id"), primary_key=True),
    Column("role_id", ID_TYPE, ForeignKey("roles.id"), primary_key=True),
)

role_permissions = Table(
    "role_permissions",
    Base.metadata,
    Column("role_id", ID_TYPE, ForeignKey("roles.id"), primary_key=True),
    Column("permission_id", ID_TYPE, ForeignKey("permissions.id"), primary_key=True),
)


class Role(AuditMixin, Base):
    __tablename__ = "roles"
    __table_args__ = (UniqueConstraint("role_code", name="uk_roles_role_code"),)

    id: Mapped[int] = mapped_column(ID_TYPE, primary_key=True, autoincrement=True)
    role_code: Mapped[str] = mapped_column(String(50), nullable=False)
    role_name: Mapped[str] = mapped_column(String(50), nullable=False)
    status: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    remark: Mapped[str | None] = mapped_column(String(255), nullable=True)

    users = relationship("User", secondary=user_roles, back_populates="roles")
    permissions = relationship("Permission", secondary=role_permissions, back_populates="roles")
