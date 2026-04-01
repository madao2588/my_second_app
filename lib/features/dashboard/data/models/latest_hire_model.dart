class LatestHireModel {
  final int id;
  final String name;
  final String deptName;
  final String positionName;
  final String hireDate;

  const LatestHireModel({
    required this.id,
    required this.name,
    required this.deptName,
    required this.positionName,
    required this.hireDate,
  });

  factory LatestHireModel.fromJson(Map<String, dynamic> json) {
    return LatestHireModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      deptName: json['dept_name'] as String? ?? '',
      positionName: json['position_name'] as String? ?? '',
      hireDate: json['hire_date'] as String? ?? '',
    );
  }
}
