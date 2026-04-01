from sqlalchemy import ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import AuditMixin, Base, ID_TYPE


class Department(AuditMixin, Base):
    __tablename__ = "departments"
    __table_args__ = (UniqueConstraint("dept_code", name="uk_departments_dept_code"),)

    id: Mapped[int] = mapped_column(ID_TYPE, primary_key=True, autoincrement=True)
    dept_code: Mapped[str] = mapped_column(String(50), nullable=False)
    dept_name: Mapped[str] = mapped_column(String(100), nullable=False)
    parent_id: Mapped[int | None] = mapped_column(
        ID_TYPE, ForeignKey("departments.id"), nullable=True, index=True
    )
    leader_employee_id: Mapped[int | None] = mapped_column(
        ID_TYPE, ForeignKey("employees.id"), nullable=True
    )
    level: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    path: Mapped[str] = mapped_column(String(255), nullable=False, default="/")
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    status: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    remark: Mapped[str | None] = mapped_column(String(255), nullable=True)

    parent = relationship("Department", remote_side=[id], back_populates="children")
    children = relationship("Department", back_populates="parent")
    leader = relationship("Employee", foreign_keys=[leader_employee_id], uselist=False)
    employees = relationship("Employee", back_populates="department", foreign_keys="Employee.dept_id")
