import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/features/dashboard/data/models/latest_hire_model.dart';

class LatestHiresCard extends StatelessWidget {
  final List<LatestHireModel> items;

  const LatestHiresCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '暂无入职记录',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.brandBlue.withValues(alpha: 0.10),
            child: Text(
              item.name.isEmpty ? '-' : item.name.substring(0, 1),
              style: const TextStyle(
                color: AppColors.brandBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${item.deptName} · ${item.positionName}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          trailing: Text(
            _formatDate(item.hireDate),
            style: const TextStyle(
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String value) {
    try {
      return DateFormat('MM-dd').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }
}
