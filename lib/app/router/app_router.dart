import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:my_second_app/app/layout/shell/app_shell.dart';
import 'package:my_second_app/app/navigation/app_navigation.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:my_second_app/features/auth/presentation/pages/login_page.dart';
import 'package:my_second_app/features/auth/presentation/pages/no_permission_page.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:my_second_app/features/department/presentation/pages/department_list_page.dart';
import 'package:my_second_app/features/employee/presentation/pages/employee_list_page.dart';
import 'package:my_second_app/features/position/presentation/pages/position_list_page.dart';
import 'package:my_second_app/features/role/presentation/pages/role_list_page.dart';
import 'package:my_second_app/features/user/presentation/pages/user_list_page.dart';

import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

String? resolveAppRedirect({
  required String matchedLocation,
  required AuthState authState,
}) {
  final isLoginPage = matchedLocation == RouteNames.login;
  final isNoPermissionPage = matchedLocation == RouteNames.noPermission;
  final isAuthenticated = authState.isAuthenticated;
  final permissions = authState.permissions;

  if (!authState.initialized) {
    return isLoginPage ? null : RouteNames.login;
  }
  if (!isAuthenticated && !isLoginPage) {
    return RouteNames.login;
  }
  if (isAuthenticated && isLoginPage) {
    return AppNavigation.firstAccessibleRoute(permissions);
  }
  if (isAuthenticated && isNoPermissionPage) {
    return null;
  }
  if (isAuthenticated &&
      !isLoginPage &&
      !isNoPermissionPage &&
      !AppNavigation.canAccessRoute(matchedLocation, permissions)) {
    return RouteNames.noPermission;
  }
  return null;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.dashboard,
  refreshListenable: appAuthController,
  redirect: (context, state) {
    return resolveAppRedirect(
      matchedLocation: state.matchedLocation,
      authState: appAuthController.state,
    );
  },
  routes: [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.noPermission,
      builder: (context, state) => const NoPermissionPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: RouteNames.employees,
          builder: (context, state) => const EmployeeListPage(),
        ),
        GoRoute(
          path: RouteNames.departments,
          builder: (context, state) => const DepartmentListPage(),
        ),
        GoRoute(
          path: RouteNames.positions,
          builder: (context, state) => const PositionListPage(),
        ),
        GoRoute(
          path: RouteNames.users,
          builder: (context, state) => const UserListPage(),
        ),
        GoRoute(
          path: RouteNames.roles,
          builder: (context, state) => const RoleListPage(),
        ),
      ],
    ),
  ],
);
