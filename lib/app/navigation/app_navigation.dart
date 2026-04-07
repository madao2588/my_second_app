import 'package:flutter/material.dart';
import 'package:my_second_app/app/content/app_copy.dart';
import 'package:my_second_app/app/router/route_names.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';

class AppDestination {
  final String label;
  final IconData icon;
  final String route;
  final String? permission;
  final bool showInNavigation;

  const AppDestination({
    required this.label,
    required this.icon,
    required this.route,
    this.permission,
    this.showInNavigation = true,
  });
}

class AppNavigation {
  static const dashboard = AppDestination(
    label: AppCopy.dashboardLabel,
    icon: Icons.dashboard_outlined,
    route: RouteNames.dashboard,
    permission: PermissionCodes.dashboardView,
  );

  static const employees = AppDestination(
    label: AppCopy.employeesLabel,
    icon: Icons.groups_outlined,
    route: RouteNames.employees,
    permission: PermissionCodes.empView,
  );

  static const departments = AppDestination(
    label: AppCopy.departmentsLabel,
    icon: Icons.account_tree_outlined,
    route: RouteNames.departments,
    permission: PermissionCodes.deptView,
  );

  static const positions = AppDestination(
    label: AppCopy.positionsLabel,
    icon: Icons.badge_outlined,
    route: RouteNames.positions,
    permission: PermissionCodes.positionView,
  );

  static const users = AppDestination(
    label: AppCopy.usersLabel,
    icon: Icons.person_outline,
    route: RouteNames.users,
    permission: PermissionCodes.userView,
  );

  static const roles = AppDestination(
    label: AppCopy.rolesLabel,
    icon: Icons.shield_outlined,
    route: RouteNames.roles,
    permission: PermissionCodes.roleView,
  );

  static const all = <AppDestination>[
    dashboard,
    employees,
    departments,
    positions,
    users,
    roles,
  ];

  static AppDestination? destinationForRoute(String route) {
    for (final destination in all) {
      if (destination.route == route) {
        return destination;
      }
    }
    return null;
  }

  static List<AppDestination> accessibleNavigation(
    Iterable<String> permissions,
  ) {
    return all
        .where(
          (destination) =>
              destination.showInNavigation &&
              (destination.permission == null ||
                  permissions.contains(destination.permission)),
        )
        .toList();
  }

  static bool canAccessRoute(String route, Iterable<String> permissions) {
    final destination = destinationForRoute(route);
    if (destination == null) {
      return true;
    }
    return destination.permission == null ||
        permissions.contains(destination.permission);
  }

  static String firstAccessibleRoute(Iterable<String> permissions) {
    final destinations = accessibleNavigation(permissions);
    if (destinations.isNotEmpty) {
      return destinations.first.route;
    }
    return RouteNames.dashboard;
  }

  const AppNavigation._();
}
