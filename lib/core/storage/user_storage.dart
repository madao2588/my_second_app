import 'dart:convert';

import 'package:my_second_app/shared/models/role_model.dart';
import 'package:my_second_app/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _userKey = 'auth_user';
  static const _rolesKey = 'auth_roles';
  static const _permissionsKey = 'auth_permissions';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveRoles(List<RoleModel> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _rolesKey,
      jsonEncode(roles.map((role) => role.toJson()).toList()),
    );
  }

  Future<List<RoleModel>> readRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rolesKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => RoleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePermissions(List<String> permissions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_permissionsKey, permissions);
  }

  Future<List<String>> readPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_permissionsKey) ?? <String>[];
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_rolesKey);
    await prefs.remove(_permissionsKey);
  }
}
