import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/shared/models/role_model.dart';
import 'package:my_second_app/shared/models/user_model.dart';

class LoginResult {
  final String accessToken;
  final UserModel user;
  final List<String> permissions;

  const LoginResult({
    required this.accessToken,
    required this.user,
    required this.permissions,
  });
}

class MeResult {
  final UserModel user;
  final List<RoleModel> roles;
  final List<String> permissions;

  const MeResult({
    required this.user,
    required this.roles,
    required this.permissions,
  });
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = _unwrap(response.data);
    return LoginResult(
      accessToken: data['access_token'] as String,
      user: UserModel.fromJson(data['user_info'] as Map<String, dynamic>),
      permissions: (data['permissions'] as List<dynamic>).cast<String>(),
    );
  }

  Future<MeResult> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final data = _unwrap(response.data);

    return MeResult(
      user: UserModel.fromJson(data),
      roles: (data['roles'] as List<dynamic>)
          .map((item) => RoleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      permissions: (data['permissions'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic>? response) {
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
