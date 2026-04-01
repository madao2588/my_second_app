class UserFormData {
  final String username;
  final String? password;
  final String realName;
  final String? phone;
  final String? email;
  final int? employeeId;
  final int status;

  const UserFormData({
    required this.username,
    required this.password,
    required this.realName,
    required this.phone,
    required this.email,
    required this.employeeId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      if (password != null) 'password': password,
      'real_name': realName,
      'phone': phone,
      'email': email,
      'employee_id': employeeId,
      'status': status,
    };
  }
}
