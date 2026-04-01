class DepartmentModel {
  final int id;
  final String deptCode;
  final String deptName;
  final int? parentId;
  final String? parentName;
  final int? leaderEmployeeId;
  final String? leaderName;
  final int level;
  final String path;
  final int sortOrder;
  final int status;
  final String? remark;

  const DepartmentModel({
    required this.id,
    required this.deptCode,
    required this.deptName,
    required this.parentId,
    required this.parentName,
    required this.leaderEmployeeId,
    required this.leaderName,
    required this.level,
    required this.path,
    required this.sortOrder,
    required this.status,
    required this.remark,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int,
      deptCode: json['dept_code'] as String,
      deptName: json['dept_name'] as String,
      parentId: json['parent_id'] as int?,
      parentName: json['parent_name'] as String?,
      leaderEmployeeId: json['leader_employee_id'] as int?,
      leaderName: json['leader_name'] as String?,
      level: json['level'] as int? ?? 1,
      path: json['path'] as String? ?? '/',
      sortOrder: json['sort_order'] as int? ?? 0,
      status: json['status'] as int? ?? 1,
      remark: json['remark'] as String?,
    );
  }
}
