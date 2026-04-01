import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/user/data/models/user_form_data.dart';
import 'package:my_second_app/features/user/data/models/user_query.dart';
import 'package:my_second_app/shared/models/page_result.dart';
import 'package:my_second_app/shared/models/user_model.dart';


class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<PageResult<UserModel>> fetchUsers(UserQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: query.toQueryParameters(),
    );
    final data = _unwrapObject(response.data);
    final items = (data['items'] as List<dynamic>)
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return PageResult<UserModel>(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? query.page,
      pageSize: data['page_size'] as int? ?? query.pageSize,
    );
  }

  Future<Map<String, dynamic>> fetchUserDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$id');
    return _unwrapObject(response.data);
  }

  Future<void> createUser(UserFormData data) async {
    await _dio.post<Map<String, dynamic>>('/users', data: data.toJson());
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _dio.put<Map<String, dynamic>>('/users/$id', data: data);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete<Map<String, dynamic>>('/users/$id');
  }

  Future<void> assignRoles(int id, List<int> roleIds) async {
    await _dio.put<Map<String, dynamic>>(
      '/users/$id/roles',
      data: {'role_ids': roleIds},
    );
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
}
