class EmployeeFormData {
  final String empNo;
  final String name;
  final String gender;
  final String? phone;
  final String? email;
  final int deptId;
  final int positionId;
  final int? leaderId;
  final String status;
  final String hireDate;
  final String? leftAt;
  final String? birthDate;
  final String? address;
  final String? remark;

  const EmployeeFormData({
    required this.empNo,
    required this.name,
    required this.gender,
    required this.phone,
    required this.email,
    required this.deptId,
    required this.positionId,
    required this.leaderId,
    required this.status,
    required this.hireDate,
    required this.leftAt,
    required this.birthDate,
    required this.address,
    required this.remark,
  });

  factory EmployeeFormData.fromDetail(Map<String, dynamic> json) {
    return EmployeeFormData(
      empNo: json['emp_no'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      deptId: json['dept_id'] as int,
      positionId: json['position_id'] as int,
      leaderId: json['leader_id'] as int?,
      status: json['status'] as String,
      hireDate: json['hire_date'] as String,
      leftAt: json['left_at'] as String?,
      birthDate: json['birth_date'] as String?,
      address: json['address'] as String?,
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_no': empNo,
      'name': name,
      'gender': gender,
      'phone': phone,
      'email': email,
      'dept_id': deptId,
      'position_id': positionId,
      'leader_id': leaderId,
      'status': status,
      'hire_date': hireDate,
      'left_at': leftAt,
      'birth_date': birthDate,
      'address': address,
      'remark': remark,
    };
  }
}
