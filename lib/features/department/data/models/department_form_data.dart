class DepartmentFormData {
  final String deptCode;
  final String deptName;
  final int? parentId;
  final int? leaderEmployeeId;
  final int sortOrder;
  final int status;
  final String? remark;

  const DepartmentFormData({
    required this.deptCode,
    required this.deptName,
    required this.parentId,
    required this.leaderEmployeeId,
    required this.sortOrder,
    required this.status,
    required this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'dept_code': deptCode,
      'dept_name': deptName,
      'parent_id': parentId,
      'leader_employee_id': leaderEmployeeId,
      'sort_order': sortOrder,
      'status': status,
      'remark': remark,
    };
  }
}
