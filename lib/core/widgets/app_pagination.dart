import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';

class AppPaginationBar extends StatelessWidget {
  final int page;
  final int pageSize;
  final int total;
  final ValueChanged<int> onPageChanged;

  const AppPaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = total == 0 ? 1 : (total / pageSize).ceil();
    final canGoPrev = page > 1;
    final canGoNext = page < totalPages;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Text(
          '共 $total 条记录，第 $page / $totalPages 页',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: canGoPrev ? () => onPageChanged(page - 1) : null,
              child: const Text('上一页'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: canGoNext ? () => onPageChanged(page + 1) : null,
              child: const Text('下一页'),
            ),
          ],
        ),
      ],
    );
  }
}
