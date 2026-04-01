import 'package:flutter/material.dart';

class PermissionWidget extends StatelessWidget {
  final bool allowed;
  final Widget child;
  final Widget? fallback;

  const PermissionWidget({
    super.key,
    required this.allowed,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (allowed) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
