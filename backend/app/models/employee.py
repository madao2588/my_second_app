from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import AuditMixin, Base, ID_TYPE


class Employee(AuditMixin, Base):
    __tablename__ = "employees"
    __table_args__ = (UniqueConstraint("emp_no", name="uk_employees_emp_no"),)

    id: Mapped[int] = mapped_column(ID_TYPE, primary_key=True, autoincrement=True)
    emp_no: Mapped[str] = mapped_column(String(50), nullable=False)
    name: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    gender: Mapped[str] = mapped_column(String(10), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    email: Mapped[str | None] = mapped_column(String(100), nullable=True)
    dept_id: Mapped[int] = mapped_column(
        ID_TYPE, ForeignKey("departments.id"), nullable=False, index=True
    )
    position_id: Mapped[int] = mapped_column(
        ID_TYPE, ForeignKey("positions.id"), nullable=False, index=True
    )
    leader_id: Mapped[int | None] = mapped_column(
        ID_TYPE, ForeignKey("employees.id"), nullable=True
    )
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="active", index=True)
    hire_date: Mapped[date] = mapped_column(Date, nullable=False)
    left_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    birth_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    address: Mapped[str | None] = mapped_column(String(255), nullable=True)
    remark: Mapped[str | None] = mapped_column(String(255), nullable=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, index=True)
    department = relationship("Department", back_populates="employees", foreign_keys=[dept_id])
    position = relationship("Position", back_populates="employees", foreign_keys=[position_id])
    leader = relationship("Employee", remote_side=[id], uselist=False)
    account = relationship("User", back_populates="employee", uselist=False)
