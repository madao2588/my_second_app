import 'package:my_second_app/features/dashboard/data/models/chart_item_model.dart';
import 'package:my_second_app/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:my_second_app/features/dashboard/data/models/latest_hire_model.dart';

class DashboardState {
  final bool loading;
  final String? errorMessage;
  final DashboardSummaryModel? summary;
  final List<ChartItemModel> departmentDistribution;
  final List<ChartItemModel> positionDistribution;
  final List<LatestHireModel> latestHires;

  const DashboardState({
    this.loading = false,
    this.errorMessage,
    this.summary,
    this.departmentDistribution = const [],
    this.positionDistribution = const [],
    this.latestHires = const [],
  });

  DashboardState copyWith({
    bool? loading,
    String? errorMessage,
    DashboardSummaryModel? summary,
    List<ChartItemModel>? departmentDistribution,
    List<ChartItemModel>? positionDistribution,
    List<LatestHireModel>? latestHires,
    bool clearError = false,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      summary: summary ?? this.summary,
      departmentDistribution: departmentDistribution ?? this.departmentDistribution,
      positionDistribution: positionDistribution ?? this.positionDistribution,
      latestHires: latestHires ?? this.latestHires,
    );
  }
}
