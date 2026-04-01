import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_second_app/app/router/route_names.dart';
import 'package:my_second_app/app/theme/app_colors.dart';

class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    final label = switch (route) {
      RouteNames.dashboard => '仪表盘',
      RouteNames.employees => '员工管理',
      RouteNames.departments => '部门管理',
      RouteNames.positions => '岗位管理',
      RouteNames.users => '用户管理',
      RouteNames.roles => '角色权限',
      _ => '首页',
    };

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '控制台',
            style: TextStyle(
              color: AppColors.brandBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textHint,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
