class RoleFormData {
  final String roleCode;
  final String roleName;
  final int status;
  final String? remark;

  const RoleFormData({
    required this.roleCode,
    required this.roleName,
    required this.status,
    required this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'role_code': roleCode,
      'role_name': roleName,
      'status': status,
      'remark': remark,
    };
  }
}
