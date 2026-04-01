class DashboardSummaryModel {
  final int totalEmployees;
  final int monthHires;
  final int monthLeaves;
  final double avgDepartmentHeadcount;
  final int userJoinDays;

  const DashboardSummaryModel({
    required this.totalEmployees,
    required this.monthHires,
    required this.monthLeaves,
    required this.avgDepartmentHeadcount,
    required this.userJoinDays,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalEmployees: json['total_employees'] as int? ?? 0,
      monthHires: json['month_hires'] as int? ?? 0,
      monthLeaves: json['month_leaves'] as int? ?? 0,
      avgDepartmentHeadcount: (json['avg_department_headcount'] as num?)?.toDouble() ?? 0,
      userJoinDays: json['user_join_days'] as int? ?? 0,
    );
  }
}
