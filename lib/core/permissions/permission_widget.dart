import 'package:flutter/material.dart';

class PermissionWidget extends StatelessWidget {
  final bool allowed;
  final Widget child;
  final Widget? fallback;
  final bool showDisabledState;
  final String deniedTooltip;
  final double disabledOpacity;

  const PermissionWidget({
    super.key,
    required this.allowed,
    required this.child,
    this.fallback,
    this.showDisabledState = false,
    this.deniedTooltip = '无权限执行该操作',
    this.disabledOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    if (allowed) {
      return child;
    }
    if (showDisabledState) {
      return Tooltip(
        message: deniedTooltip,
        child: Opacity(
          opacity: disabledOpacity,
          child: IgnorePointer(
            ignoring: true,
            child: child,
          ),
        ),
      );
    }
    return fallback ?? const SizedBox.shrink();
  }
}
