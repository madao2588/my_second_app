class PermissionModel {
  final int id;
  final String permCode;
  final String permName;
  final String permType;
  final int? parentId;
  final String? routePath;
  final String? icon;
  final int sortOrder;
  final int status;
  final List<PermissionModel> children;

  const PermissionModel({
    required this.id,
    required this.permCode,
    required this.permName,
    required this.permType,
    required this.parentId,
    required this.routePath,
    required this.icon,
    required this.sortOrder,
    required this.status,
    required this.children,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as int,
      permCode: json['perm_code'] as String,
      permName: json['perm_name'] as String,
      permType: json['perm_type'] as String,
      parentId: json['parent_id'] as int?,
      routePath: json['route_path'] as String?,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      status: json['status'] as int? ?? 1,
      children: (json['children'] as List<dynamic>? ?? const [])
          .map((item) => PermissionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
