import 'package:dio/dio.dart';
import 'package:my_second_app/core/storage/token_storage.dart';
import 'package:my_second_app/core/storage/user_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final UserStorage userStorage;
  final Future<void> Function() onUnauthorized;

  AuthInterceptor({
    required this.tokenStorage,
    required this.userStorage,
    required this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await tokenStorage.clearToken();
      await userStorage.clear();
      await onUnauthorized();
    }
    handler.next(err);
  }
}
