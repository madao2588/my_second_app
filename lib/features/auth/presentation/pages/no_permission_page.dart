import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_second_app/app/router/route_names.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/widgets/app_card.dart';

class NoPermissionPage extends StatelessWidget {
  const NoPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: AppCardSection(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 36,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '无权限访问',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '当前账号没有访问此页面的权限。你可以返回仪表盘，或联系管理员调整角色权限。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(RouteNames.dashboard),
                    child: const Text('返回仪表盘'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('重新登录'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
