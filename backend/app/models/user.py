from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import AuditMixin, Base, ID_TYPE
from app.models.role import user_roles


class User(AuditMixin, Base):
    __tablename__ = "users"
    __table_args__ = (UniqueConstraint("username", name="uk_users_username"),)

    id: Mapped[int] = mapped_column(ID_TYPE, primary_key=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    real_name: Mapped[str] = mapped_column(String(50), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    email: Mapped[str | None] = mapped_column(String(100), nullable=True)
    employee_id: Mapped[int | None] = mapped_column(
        ID_TYPE, ForeignKey("employees.id"), nullable=True, unique=True
    )
    status: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    employee = relationship("Employee", back_populates="account", uselist=False)
    roles = relationship("Role", secondary=user_roles, back_populates="users")
