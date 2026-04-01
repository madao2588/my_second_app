import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:my_second_app/app/layout/shell/app_shell.dart';
import 'package:my_second_app/features/auth/presentation/pages/login_page.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:my_second_app/features/department/presentation/pages/department_list_page.dart';
import 'package:my_second_app/features/employee/presentation/pages/employee_list_page.dart';
import 'package:my_second_app/features/position/presentation/pages/position_list_page.dart';
import 'package:my_second_app/features/role/presentation/pages/role_list_page.dart';
import 'package:my_second_app/features/user/presentation/pages/user_list_page.dart';

import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.dashboard,
  refreshListenable: appAuthController,
  redirect: (context, state) {
    final isLoginPage = state.matchedLocation == RouteNames.login;
    final isAuthenticated = appAuthController.state.isAuthenticated;

    if (!appAuthController.state.initialized) {
      return isLoginPage ? null : RouteNames.login;
    }
    if (!isAuthenticated && !isLoginPage) {
      return RouteNames.login;
    }
    if (isAuthenticated && isLoginPage) {
      return RouteNames.dashboard;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginPage(),
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
