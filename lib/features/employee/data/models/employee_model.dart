class EmployeeModel {
  final int id;
  final String empNo;
  final String name;
  final String gender;
  final String? phone;
  final String? email;
  final int deptId;
  final String deptName;
  final int positionId;
  final String positionName;
  final int? leaderId;
  final String? leaderName;
  final String status;
  final String hireDate;

  const EmployeeModel({
    required this.id,
    required this.empNo,
    required this.name,
    required this.gender,
    required this.phone,
    required this.email,
    required this.deptId,
    required this.deptName,
    required this.positionId,
    required this.positionName,
    required this.leaderId,
    required this.leaderName,
    required this.status,
    required this.hireDate,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      empNo: json['emp_no'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      deptId: json['dept_id'] as int,
      deptName: json['dept_name'] as String? ?? '',
      positionId: json['position_id'] as int,
      positionName: json['position_name'] as String? ?? '',
      leaderId: json['leader_id'] as int?,
      leaderName: json['leader_name'] as String?,
      status: json['status'] as String,
      hireDate: json['hire_date'] as String,
    );
  }
}
