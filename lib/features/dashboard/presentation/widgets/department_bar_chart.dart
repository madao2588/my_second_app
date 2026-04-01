import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/features/dashboard/data/models/chart_item_model.dart';

class DepartmentBarChart extends StatelessWidget {
  final List<ChartItemModel> items;

  const DepartmentBarChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _ChartEmptyState(message: '暂无部门分布数据');
    }

    final maxValue = items.map((item) => item.value).reduce((a, b) => a > b ? a : b);
    final groups = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.brandBlueDark,
                AppColors.brandBlue,
              ],
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxValue.toDouble() * 1.25,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = items[group.x.toInt()];
              return BarTooltipItem(
                '${item.name}\n${item.value} 人',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxValue <= 5 ? 1 : null,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= items.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    items[index].name,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue <= 5 ? 1 : null,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: AppColors.line,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  final String message;

  const _ChartEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
