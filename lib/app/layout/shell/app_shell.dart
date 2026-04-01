import 'package:flutter/material.dart';
import 'package:my_second_app/app/layout/shell/app_header.dart';
import 'package:my_second_app/app/layout/shell/app_sidebar.dart';
import 'package:my_second_app/app/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;

        Widget background({required Widget content}) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandBlue.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  left: -120,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                content,
              ],
            ),
          );
        }

        if (compact) {
          return Scaffold(
            drawer: const Drawer(
              child: SafeArea(child: AppSidebar()),
            ),
            body: Builder(
              builder: (innerContext) {
                return background(
                  content: Column(
                    children: [
                      AppHeader(
                        compact: true,
                        onMenuPressed: () => Scaffold.of(innerContext).openDrawer(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return Scaffold(
          body: background(
            content: Row(
              children: [
                const SizedBox(width: 260, child: AppSidebar()),
                Expanded(
                  child: Column(
                    children: [
                      const AppHeader(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
