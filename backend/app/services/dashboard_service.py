from sqlalchemy.orm import Session

from app.models.user import User
from app.repositories.dashboard_repository import DashboardRepository
from app.schemas.dashboard import ChartPoint, DashboardSummary, LatestHireItem


class DashboardService:
    def __init__(self, db: Session):
        self.repository = DashboardRepository(db)

    def get_summary(self, current_user: User) -> DashboardSummary:
        return self.repository.get_summary(current_user.employee_id)

    def get_department_distribution(self) -> list[ChartPoint]:
        return self.repository.get_department_distribution()

    def get_position_distribution(self) -> list[ChartPoint]:
        return self.repository.get_position_distribution()

    def get_latest_hires(self, limit: int = 5) -> list[LatestHireItem]:
        return self.repository.get_latest_hires(limit=limit)
