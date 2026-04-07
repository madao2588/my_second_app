import 'package:flutter/material.dart';
import 'package:my_second_app/app/layout/shell/app_header.dart';
import 'package:my_second_app/app/layout/shell/app_sidebar.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/app_breakpoints.dart';

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
        final compact = constraints.maxWidth < AppBreakpoints.mobile;
        final contentWidth =
            (constraints.maxWidth - 260).clamp(0.0, double.infinity);

        Widget background({required Widget content}) {
          return Container(
            width: double.infinity,
            height: double.infinity,
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
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -120,
                    right: -80,
                    child: IgnorePointer(
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brandBlue.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -140,
                    left: -120,
                    child: IgnorePointer(
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(child: content),
                ],
              ),
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
                        onMenuPressed: () =>
                            Scaffold.of(innerContext).openDrawer(),
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
            content: SizedBox.expand(
              child: Row(
                children: [
                  const SizedBox(width: 260, child: AppSidebar()),
                  SizedBox(
                    width: contentWidth,
                    child: ClipRect(
                      child: Column(
                        children: [
                          const AppHeader(),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.fromLTRB(28, 24, 28, 28),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
