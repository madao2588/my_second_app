class UserModel {
  final int id;
  final String username;
  final String realName;
  final int? employeeId;
  final String? employeeName;
  final String? phone;
  final String? email;
  final int status;
  final List<int> roleIds;
  final List<String> roleNames;
  final String? lastLoginAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.realName,
    required this.employeeId,
    required this.employeeName,
    required this.phone,
    required this.email,
    required this.status,
    required this.roleIds,
    required this.roleNames,
    required this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      realName: json['real_name'] as String? ?? json['realName'] as String? ?? '',
      employeeId: json['employee_id'] as int?,
      employeeName: json['employee_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as int? ?? 1,
      roleIds: (json['role_ids'] as List<dynamic>? ?? const []).cast<int>(),
      roleNames: (json['role_names'] as List<dynamic>? ?? const []).cast<String>(),
      lastLoginAt: json['last_login_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'real_name': realName,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'phone': phone,
      'email': email,
      'status': status,
      'role_ids': roleIds,
      'role_names': roleNames,
      'last_login_at': lastLoginAt,
    };
  }
}
