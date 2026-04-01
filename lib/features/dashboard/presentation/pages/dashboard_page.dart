import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
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
        final compactWidth = constraints.maxWidth < 1180;
        final compact = compactHeight || compactWidth;

        final hero = _heroSection(
          userName: user?.realName ?? '管理员',
          joinDays: summary?.userJoinDays ?? 0,
          monthHires: summary?.monthHires ?? 0,
          monthLeaves: summary?.monthLeaves ?? 0,
          compactWidth: compactWidth,
        );

        final metrics = _metricSection(summary);

        final charts = compactWidth
            ? Column(
                children: [
                  SizedBox(
                    height: 360,
                    child: _PanelCard(
                      title: '各部门人数分布',
                      subtitle: '按有效员工统计部门人员规模',
                      child: DepartmentBarChart(items: state.departmentDistribution),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 360,
                    child: _PanelCard(
                      title: '岗位占比',
                      subtitle: '当前岗位结构分布',
                      child: PositionDonutChart(items: state.positionDistribution),
                    ),
                  ),
                ],
              )
            : Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _PanelCard(
                        title: '各部门人数分布',
                        subtitle: '按有效员工统计部门人员规模',
                        child: DepartmentBarChart(items: state.departmentDistribution),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _PanelCard(
                        title: '岗位占比',
                        subtitle: '当前岗位结构分布',
                        child: PositionDonutChart(items: state.positionDistribution),
                      ),
                    ),
                  ],
                ),
              );

        final latestHires = SizedBox(
          height: compact ? 320 : double.infinity,
          child: _PanelCard(
            title: '最新入职员工',
            subtitle: '最近 5 条入职记录',
            child: LatestHiresCard(items: state.latestHires),
          ),
        );

        final contentChildren = <Widget>[
          hero,
          const SizedBox(height: 24),
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
          if (state.loading && summary == null)
            const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            metrics,
            const SizedBox(height: 16),
            if (compactWidth) ...[
              charts,
              const SizedBox(height: 16),
              latestHires,
            ],
          ],
        ];

        if (compact) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentChildren,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...contentChildren.take(contentChildren.length - 2),
            charts,
            const SizedBox(height: 16),
            Expanded(child: latestHires),
          ],
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
            '本月总览',
            style: TextStyle(
              color: Color(0xFFBFDBFE),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$monthHires 人入职',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '离职 $monthLeaves 人',
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

  Widget _metricSection(summary) {
    final cards = [
      KpiCard(
        title: '总员工数',
        value: '${summary?.totalEmployees ?? 0}',
        note: '当前系统内全部有效员工',
        color: AppColors.brandBlue,
        icon: Icons.groups_rounded,
      ),
      KpiCard(
        title: '本月入职',
        value: '${summary?.monthHires ?? 0}',
        note: '本月新增员工数量',
        color: AppColors.success,
        icon: Icons.person_add_alt_1_rounded,
      ),
      KpiCard(
        title: '本月离职',
        value: '${summary?.monthLeaves ?? 0}',
        note: '本月离职员工数量',
        color: AppColors.danger,
        icon: Icons.person_remove_alt_1_rounded,
      ),
      KpiCard(
        title: '平均编制',
        value: summary == null
            ? '0.0'
            : summary.avgDepartmentHeadcount.toStringAsFixed(1),
        note: '按启用部门估算的人均规模',
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
          '早上好，$userName',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '今天是你加入企业的第 $joinDays 天。组织数据已经汇总完成，你可以在这里快速查看人员规模、岗位分布和最新入职情况。',
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
