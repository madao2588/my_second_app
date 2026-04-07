import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/core/network/dio_client.dart';
import 'package:my_second_app/core/storage/token_storage.dart';
import 'package:my_second_app/core/storage/user_storage.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:my_second_app/shared/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController._internal({bool keepAlive = false})
      : _keepAlive = keepAlive,
        _tokenStorage = TokenStorage(),
        _userStorage = UserStorage(),
        state = const AuthState.initial() {
    _dio = DioClient(
      tokenStorage: _tokenStorage,
      userStorage: _userStorage,
      onUnauthorized: logoutSilently,
    ).create();
    _repository = AuthRepository(_dio);
  }

  final TokenStorage _tokenStorage;
  final UserStorage _userStorage;
  final bool _keepAlive;
  late final Dio _dio;
  late final AuthRepository _repository;

  AuthState state;

  Dio get dio => _dio;

  Future<void> bootstrap() async {
    final token = await _tokenStorage.readToken();
    final user = await _userStorage.readUser();
    final roles = await _userStorage.readRoles();
    final permissions = await _userStorage.readPermissions();

    if (token != null && user != null) {
      state = state.copyWith(
        initialized: true,
        token: token,
        user: user,
        roles: roles,
        permissions: permissions.toSet(),
        clearError: true,
      );
      notifyListeners();

      try {
        await refreshCurrentUser();
      } catch (_) {
        await logoutSilently();
      }
      return;
    }

    state = state.copyWith(initialized: true, clearError: true);
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    notifyListeners();

    try {
      final result = await _repository.login(
        username: username,
        password: password,
      );
      await _tokenStorage.saveToken(result.accessToken);
      await _userStorage.saveUser(result.user);
      await _userStorage.savePermissions(result.permissions);

      state = state.copyWith(
        initialized: true,
        loading: false,
        token: result.accessToken,
        user: result.user,
        permissions: result.permissions.toSet(),
        roles: const [],
      );
      notifyListeners();

      await refreshCurrentUser();
    } on ApiException catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error.message,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        loading: false,
        errorMessage: '登录失败，请稍后重试',
      );
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    final result = await _repository.me();
    await _userStorage.saveUser(result.user);
    await _userStorage.saveRoles(result.roles);
    await _userStorage.savePermissions(result.permissions);

    state = state.copyWith(
      initialized: true,
      user: result.user,
      roles: result.roles,
      permissions: result.permissions.toSet(),
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _userStorage.clear();
    state = state.copyWith(
      initialized: true,
      loading: false,
      roles: const [],
      permissions: const {},
      clearToken: true,
      clearUser: true,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> logoutSilently() async {
    await logout();
  }

  bool hasPermission(String code) => state.permissions.contains(code);

  @override
  void dispose() {
    if (_keepAlive) {
      return;
    }
    super.dispose();
  }
}

final AuthController appAuthController =
    AuthController._internal(keepAlive: true);

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => appAuthController,
);
