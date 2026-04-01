import 'package:dio/dio.dart';
import 'package:my_second_app/core/constants/app_constants.dart';
import 'package:my_second_app/core/network/auth_interceptor.dart';
import 'package:my_second_app/core/storage/token_storage.dart';
import 'package:my_second_app/core/storage/user_storage.dart';

class DioClient {
  final TokenStorage tokenStorage;
  final UserStorage userStorage;
  final Future<void> Function() onUnauthorized;

  DioClient({
    required this.tokenStorage,
    required this.userStorage,
    required this.onUnauthorized,
  });

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        userStorage: userStorage,
        onUnauthorized: onUnauthorized,
      ),
    );

    return dio;
  }
}
