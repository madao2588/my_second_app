import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/app/content/app_copy.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/app_breakpoints.dart';
import 'package:my_second_app/core/widgets/app_error_state.dart';
import 'package:my_second_app/core/widgets/app_loading_skeleton.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/dashboard/data/models/chart_item_model.dart';
import 'package:my_second_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:my_second_app/features/dashboard/presentation/widgets/department_bar_chart.dart';
import 'package:my_second_app/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:my_second_app/features/dashboard/presentation/widgets/latest_hires_card.dart';
import 'package:my_second_app/features/dashboard/presentation/widgets/position_donut_chart.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardControllerProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final user = appAuthController.state.user;
    final controller = ref.watch(dashboardControllerProvider);
    final state = controller.state;
    final summary = state.summary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight = constraints.maxHeight < 820;
        final compactWidth =
            constraints.maxWidth < AppBreakpoints.compactDesktop;
        final stackHero = constraints.maxWidth < 1260;
        final stackCharts = constraints.maxWidth < 1120;
        final contentMaxWidth = compactWidth
            ? constraints.maxWidth
            : AppBreakpoints.contentMaxWidth;

        return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: compactHeight ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroSection(
                    userName:
                        user?.realName ?? AppCopy.dashboardDefaultUserName,
                    joinDays: summary?.userJoinDays ?? 0,
                    monthHires: summary?.monthHires ?? 0,
                    monthLeaves: summary?.monthLeaves ?? 0,
                    compactWidth: stackHero,
                  ),
                  const SizedBox(height: 24),
                  if (state.loading && summary == null) ...[
                    _metricSection(summary, loading: true),
                    const SizedBox(height: 16),
                    _chartSection(
                      stackCharts: stackCharts,
                      departmentDistribution: const [],
                      positionDistribution: const [],
                      loading: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: stackCharts ? 320 : 360,
                      child: const _PanelCard(
                        title: AppCopy.dashboardLatestHiresTitle,
                        subtitle: AppCopy.dashboardLatestHiresSubtitle,
                        child: AppPanelLoadingSkeleton(height: 220),
                      ),
                    ),
                  ] else if (state.errorMessage != null && summary == null) ...[
                    AppErrorState(
                      message: state.errorMessage!,
                      onRetry: controller.load,
                    ),
                  ] else ...[
                    if (state.errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _metricSection(summary),
                    const SizedBox(height: 16),
                    _chartSection(
                      stackCharts: stackCharts,
                      departmentDistribution: state.departmentDistribution,
                      positionDistribution: state.positionDistribution,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: stackCharts ? 320 : 360,
                      child: _PanelCard(
                        title: AppCopy.dashboardLatestHiresTitle,
                        subtitle: AppCopy.dashboardLatestHiresSubtitle,
                        child: LatestHiresCard(items: state.latestHires),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _heroSection({
    required String userName,
    required int joinDays,
    required int monthHires,
    required int monthLeaves,
    required bool compactWidth,
  }) {
    final overviewCard = Container(
      width: compactWidth ? double.infinity : 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppCopy.dashboardOverviewTitle,
            style: TextStyle(
              color: Color(0xFFBFDBFE),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppCopy.dashboardOverviewHires(monthHires),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppCopy.dashboardOverviewLeaves(monthLeaves),
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: compactWidth
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroText(userName: userName, joinDays: joinDays),
                const SizedBox(height: 20),
                overviewCard,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _HeroText(userName: userName, joinDays: joinDays),
                ),
                const SizedBox(width: 20),
                overviewCard,
              ],
            ),
    );
  }

  Widget _metricSection(dynamic summary, {bool loading = false}) {
    if (loading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1120;
          final itemWidth = constraints.maxWidth < 720
              ? constraints.maxWidth
              : (constraints.maxWidth - 16) / 2;
          final items = List.generate(
            4,
            (_) => SizedBox(
              width: compact ? itemWidth : null,
              height: 208,
              child: const _MetricSkeletonCard(),
            ),
          );

          if (compact) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: items,
            );
          }

          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(child: items[i]),
                if (i != items.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        },
      );
    }

    final cards = [
      KpiCard(
        title: AppCopy.dashboardTotalEmployeesTitle,
        value: '${summary?.totalEmployees ?? 0}',
        note: AppCopy.dashboardTotalEmployeesNote,
        color: AppColors.brandBlue,
        icon: Icons.groups_rounded,
      ),
      KpiCard(
        title: AppCopy.dashboardMonthHiresTitle,
        value: '${summary?.monthHires ?? 0}',
        note: AppCopy.dashboardMonthHiresNote,
        color: AppColors.success,
        icon: Icons.person_add_alt_1_rounded,
      ),
      KpiCard(
        title: AppCopy.dashboardMonthLeavesTitle,
        value: '${summary?.monthLeaves ?? 0}',
        note: AppCopy.dashboardMonthLeavesNote,
        color: AppColors.danger,
        icon: Icons.person_remove_alt_1_rounded,
      ),
      KpiCard(
        title: AppCopy.dashboardAverageHeadcountTitle,
        value: summary == null
            ? '0.0'
            : summary.avgDepartmentHeadcount.toStringAsFixed(1),
        note: AppCopy.dashboardAverageHeadcountNote,
        color: AppColors.warning,
        icon: Icons.equalizer_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1120) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: constraints.maxWidth < 720
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 16) / 2,
                    height: 208,
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: SizedBox(height: 208, child: cards[i])),
              if (i != cards.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _chartSection({
    required bool stackCharts,
    required List<ChartItemModel> departmentDistribution,
    required List<ChartItemModel> positionDistribution,
    bool loading = false,
  }) {
    final departmentChild = loading
        ? const AppPanelLoadingSkeleton()
        : DepartmentBarChart(items: departmentDistribution);
    final positionChild = loading
        ? const AppPanelLoadingSkeleton()
        : PositionDonutChart(items: positionDistribution);

    if (stackCharts) {
      return Column(
        children: [
          SizedBox(
            height: 360,
            child: _PanelCard(
              title: AppCopy.dashboardDepartmentChartTitle,
              subtitle: AppCopy.dashboardDepartmentChartSubtitle,
              child: departmentChild,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: _PanelCard(
              title: AppCopy.dashboardPositionChartTitle,
              subtitle: AppCopy.dashboardPositionChartSubtitle,
              child: positionChild,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _PanelCard(
              title: AppCopy.dashboardDepartmentChartTitle,
              subtitle: AppCopy.dashboardDepartmentChartSubtitle,
              child: departmentChild,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _PanelCard(
              title: AppCopy.dashboardPositionChartTitle,
              subtitle: AppCopy.dashboardPositionChartSubtitle,
              child: positionChild,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final String userName;
  final int joinDays;

  const _HeroText({
    required this.userName,
    required this.joinDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppCopy.dashboardGreeting(userName),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppCopy.dashboardHeroDescription(joinDays),
          style: const TextStyle(
            height: 1.8,
            color: Color(0xFFE2E8F0),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _PanelCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MetricSkeletonCard extends StatelessWidget {
  const _MetricSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x142563EB),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          Spacer(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x142563EB),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(width: 78, height: 14),
          ),
          SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x142563EB),
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: SizedBox(width: 96, height: 28),
          ),
          SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x142563EB),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(width: 170, height: 12),
          ),
        ],
      ),
    );
  }
}
