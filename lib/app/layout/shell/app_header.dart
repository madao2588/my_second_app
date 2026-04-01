import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_second_app/app/layout/shell/app_breadcrumb.dart';
import 'package:my_second_app/app/router/route_names.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';

class AppHeader extends StatelessWidget {
  final bool compact;
  final VoidCallback? onMenuPressed;

  const AppHeader({
    super.key,
    this.compact = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = appAuthController.state.user;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (compact && onMenuPressed != null) ...[
                IconButton(
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: '菜单',
                ),
                const SizedBox(width: 4),
              ],
              const AppBreadcrumb(),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _HeaderChip(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      today,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (user != null)
                _HeaderChip(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.realName.characters.first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: compact ? 130 : 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.realName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user.username,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: '退出登录',
                        onPressed: () async {
                          await appAuthController.logout();
                          if (context.mounted) {
                            context.go(RouteNames.login);
                          }
                        },
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final Widget child;

  const _HeaderChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}
