import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/features/dashboard/data/models/chart_item_model.dart';

class PositionDonutChart extends StatelessWidget {
  final List<ChartItemModel> items;

  const PositionDonutChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '暂无岗位占比数据',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    const palette = [
      Color(0xFF2563EB),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
    ];

    final total = items.fold<int>(0, (sum, item) => sum + item.value);
    final sections = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        color: palette[index % palette.length],
        value: item.value.toDouble(),
        radius: 56,
        showTitle: false,
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 48,
                  sections: sections,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (_, __) {},
                  ),
                ),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '总人数',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final percent = total == 0 ? 0 : (item.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: palette[index % palette.length],
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${item.value} / ${percent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
