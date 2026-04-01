from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_permission
from app.core.response import ApiResponse
from app.models.user import User
from app.schemas.dashboard import ChartPoint, DashboardSummary, LatestHireItem
from app.services.dashboard_service import DashboardService

router = APIRouter()


@router.get("/summary", response_model=ApiResponse[DashboardSummary])
def get_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_permission("dashboard:view")),
) -> ApiResponse[DashboardSummary]:
    data = DashboardService(db).get_summary(current_user)
    return ApiResponse(data=data)


@router.get("/department-distribution", response_model=ApiResponse[list[ChartPoint]])
def get_department_distribution(
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dashboard:view")),
) -> ApiResponse[list[ChartPoint]]:
    data = DashboardService(db).get_department_distribution()
    return ApiResponse(data=data)


@router.get("/position-distribution", response_model=ApiResponse[list[ChartPoint]])
def get_position_distribution(
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dashboard:view")),
) -> ApiResponse[list[ChartPoint]]:
    data = DashboardService(db).get_position_distribution()
    return ApiResponse(data=data)


@router.get("/latest-hires", response_model=ApiResponse[list[LatestHireItem]])
def get_latest_hires(
    limit: int = Query(default=5, ge=1, le=20),
    db: Session = Depends(get_db),
    _: User = Depends(require_permission("dashboard:view")),
) -> ApiResponse[list[LatestHireItem]]:
    data = DashboardService(db).get_latest_hires(limit=limit)
    return ApiResponse(data=data)
