import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';

class AppTableLoadingSkeleton extends StatelessWidget {
  final int rows;
  final int columns;

  const AppTableLoadingSkeleton({
    super.key,
    this.rows = 5,
    this.columns = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            columns,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == columns - 1 ? 0 : 12),
                child: const _SkeletonBox(height: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (var row = 0; row < rows; row++) ...[
          Row(
            children: List.generate(
              columns,
              (index) => Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: index == columns - 1 ? 0 : 12),
                  child: _SkeletonBox(
                    height: 18,
                    widthFactor: index == columns - 1 ? 0.5 : 0.72,
                  ),
                ),
              ),
            ),
          ),
          if (row != rows - 1) ...[
            const SizedBox(height: 18),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 18),
          ],
        ],
      ],
    );
  }
}

class AppPanelLoadingSkeleton extends StatelessWidget {
  final double height;

  const AppPanelLoadingSkeleton({
    super.key,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonBox(height: 18, width: 160),
        const SizedBox(height: 10),
        const _SkeletonBox(height: 12, width: 220),
        const SizedBox(height: 22),
        Expanded(
          child: _SkeletonBox(
            height: height,
            width: double.infinity,
            borderRadius: 20,
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final double widthFactor;

  const _SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius = 12,
    this.widthFactor = 1,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.brandBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (width == null && widthFactor < 1) {
      child = FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: child,
      );
    }

    return child;
  }
}
