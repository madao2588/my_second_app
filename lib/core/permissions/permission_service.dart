class PermissionService {
  const PermissionService();

  bool hasPermission(Iterable<String> permissions, String code) {
    return permissions.contains(code);
  }
}
