import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_second_app/app/router/route_names.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';

class _SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final String? permission;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.permission,
  });
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_SidebarItem>[
      const _SidebarItem(
        label: '仪表盘',
        icon: Icons.dashboard_outlined,
        route: RouteNames.dashboard,
        permission: PermissionCodes.dashboardView,
      ),
      const _SidebarItem(
        label: '员工管理',
        icon: Icons.groups_outlined,
        route: RouteNames.employees,
        permission: PermissionCodes.empView,
      ),
      const _SidebarItem(
        label: '部门管理',
        icon: Icons.account_tree_outlined,
        route: RouteNames.departments,
        permission: PermissionCodes.deptView,
      ),
      const _SidebarItem(
        label: '岗位管理',
        icon: Icons.badge_outlined,
        route: RouteNames.positions,
        permission: PermissionCodes.positionView,
      ),
      const _SidebarItem(
        label: '用户管理',
        icon: Icons.person_outline,
        route: RouteNames.users,
        permission: PermissionCodes.userView,
      ),
      const _SidebarItem(
        label: '角色权限',
        icon: Icons.shield_outlined,
        route: RouteNames.roles,
        permission: PermissionCodes.roleView,
      ),
    ];

    final filtered = items
        .where(
          (item) =>
              item.permission == null ||
              appAuthController.state.permissions.contains(item.permission),
        )
        .toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF111C35),
            Color(0xFF0B1220),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BrandMark(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enterprise Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '企业基础信息管理平台',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '导航菜单',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final selected = GoRouterState.of(context).matchedLocation == item.route;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.14)
                          : Colors.transparent,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.go(item.route),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.brandBlue
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Text(
        'EA',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
