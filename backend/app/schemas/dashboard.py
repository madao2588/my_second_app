from datetime import date

from pydantic import BaseModel


class DashboardSummary(BaseModel):
    total_employees: int
    month_hires: int
    month_leaves: int
    avg_department_headcount: float
    user_join_days: int


class ChartPoint(BaseModel):
    name: str
    value: int


class LatestHireItem(BaseModel):
    id: int
    name: str
    dept_name: str
    position_name: str
    hire_date: date
