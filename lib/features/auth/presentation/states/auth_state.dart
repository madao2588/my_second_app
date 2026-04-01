import 'package:my_second_app/shared/models/role_model.dart';
import 'package:my_second_app/shared/models/user_model.dart';

class AuthState {
  final bool initialized;
  final bool loading;
  final String? token;
  final UserModel? user;
  final List<RoleModel> roles;
  final Set<String> permissions;
  final String? errorMessage;

  const AuthState({
    required this.initialized,
    required this.loading,
    required this.token,
    required this.user,
    required this.roles,
    required this.permissions,
    required this.errorMessage,
  });

  const AuthState.initial()
      : initialized = false,
        loading = false,
        token = null,
        user = null,
        roles = const [],
        permissions = const {},
        errorMessage = null;

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    bool? initialized,
    bool? loading,
    String? token,
    UserModel? user,
    List<RoleModel>? roles,
    Set<String>? permissions,
    String? errorMessage,
    bool clearToken = false,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      loading: loading ?? this.loading,
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
