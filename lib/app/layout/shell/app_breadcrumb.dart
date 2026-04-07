import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_second_app/app/content/app_copy.dart';
import 'package:my_second_app/app/navigation/app_navigation.dart';
import 'package:my_second_app/app/theme/app_colors.dart';

class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    final label = AppNavigation.destinationForRoute(route)?.label ??
        AppCopy.breadcrumbHome;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            AppCopy.breadcrumbRoot,
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
