import 'package:flutter_test/flutter_test.dart';
import 'package:my_second_app/app/router/app_router.dart';
import 'package:my_second_app/app/router/route_names.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:my_second_app/shared/models/user_model.dart';

void main() {
  group('resolveAppRedirect', () {
    test('redirects unauthenticated users to login', () {
      final result = resolveAppRedirect(
        matchedLocation: RouteNames.dashboard,
        authState: const AuthState(
          initialized: true,
          loading: false,
          token: null,
          user: null,
          roles: [],
          permissions: {},
          errorMessage: null,
        ),
      );

      expect(result, RouteNames.login);
    });

    test('redirects authenticated users away from login', () {
      final result = resolveAppRedirect(
        matchedLocation: RouteNames.login,
        authState: _authenticatedState(
          permissions: {PermissionCodes.empView},
        ),
      );

      expect(result, RouteNames.employees);
    });

    test('redirects authenticated users without permission to 403', () {
      final result = resolveAppRedirect(
        matchedLocation: RouteNames.employees,
        authState: _authenticatedState(
          permissions: {PermissionCodes.dashboardView},
        ),
      );

      expect(result, RouteNames.noPermission);
    });
  });
}

AuthState _authenticatedState({
  required Set<String> permissions,
}) {
  return AuthState(
    initialized: true,
    loading: false,
    token: 'token',
    user: const UserModel(
      id: 1,
      username: 'admin',
      realName: '管理员',
      employeeId: null,
      employeeName: null,
      phone: null,
      email: null,
      status: 1,
      roleIds: [],
      roleNames: [],
      lastLoginAt: null,
    ),
    roles: const [],
    permissions: permissions,
    errorMessage: null,
  );
}
