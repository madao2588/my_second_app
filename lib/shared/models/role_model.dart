class RoleModel {
  final int id;
  final String roleCode;
  final String roleName;
  final int status;
  final String? remark;
  final int userCount;
  final int permissionCount;
  final List<int> permissionIds;

  const RoleModel({
    required this.id,
    required this.roleCode,
    required this.roleName,
    required this.status,
    required this.remark,
    required this.userCount,
    required this.permissionCount,
    required this.permissionIds,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      roleCode: json['role_code'] as String,
      roleName: json['role_name'] as String,
      status: json['status'] as int? ?? 1,
      remark: json['remark'] as String?,
      userCount: json['user_count'] as int? ?? 0,
      permissionCount: json['permission_count'] as int? ?? 0,
      permissionIds: (json['permission_ids'] as List<dynamic>? ?? const []).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_code': roleCode,
      'role_name': roleName,
      'status': status,
      'remark': remark,
      'user_count': userCount,
      'permission_count': permissionCount,
      'permission_ids': permissionIds,
    };
  }
}
