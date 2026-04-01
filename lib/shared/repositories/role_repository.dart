import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/role/data/models/role_form_data.dart';
import 'package:my_second_app/features/role/data/models/role_query.dart';
import 'package:my_second_app/shared/models/page_result.dart';
import 'package:my_second_app/shared/models/permission_model.dart';
import 'package:my_second_app/shared/models/role_model.dart';


class RoleRepository {
  final Dio _dio;

  RoleRepository(this._dio);

  Future<PageResult<RoleModel>> fetchRoles(RoleQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/roles',
      queryParameters: query.toQueryParameters(),
    );
    final data = _unwrapObject(response.data);
    final items = (data['items'] as List<dynamic>)
        .map((item) => RoleModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return PageResult<RoleModel>(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? query.page,
      pageSize: data['page_size'] as int? ?? query.pageSize,
    );
  }

  Future<Map<String, dynamic>> fetchRoleDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/roles/$id');
    return _unwrapObject(response.data);
  }

  Future<void> createRole(RoleFormData data) async {
    await _dio.post<Map<String, dynamic>>('/roles', data: data.toJson());
  }

  Future<void> updateRole(int id, Map<String, dynamic> data) async {
    await _dio.put<Map<String, dynamic>>('/roles/$id', data: data);
  }

  Future<void> deleteRole(int id) async {
    await _dio.delete<Map<String, dynamic>>('/roles/$id');
  }

  Future<void> assignPermissions(int id, List<int> permissionIds) async {
    await _dio.put<Map<String, dynamic>>(
      '/roles/$id/permissions',
      data: {'permission_ids': permissionIds},
    );
  }

  Future<List<PermissionModel>> fetchPermissionTree() async {
    final response = await _dio.get<Map<String, dynamic>>('/permissions/tree');
    final data = _unwrapList(response.data);
    return data
        .map((item) => PermissionModel.fromJson(item))
        .toList();
  }

  Map<String, dynamic> _unwrapObject(Map<String, dynamic>? response) {
    if (response == null) {
      throw const ApiException(code: -1, message: '响应为空');
    }
    final code = response['code'] as int? ?? -1;
    final message = response['message'] as String? ?? '请求失败';
    if (code != 0) {
      throw ApiException(code: code, message: message);
    }
    return response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  List<Map<String, dynamic>> _unwrapList(Map<String, dynamic>? response) {
    if (response == null) {
      throw const ApiException(code: -1, message: '响应为空');
    }
    final code = response['code'] as int? ?? -1;
    final message = response['message'] as String? ?? '请求失败';
    if (code != 0) {
      throw ApiException(code: code, message: message);
    }
    return (response['data'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }
}
