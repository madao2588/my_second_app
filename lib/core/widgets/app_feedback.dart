import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';

void showAppSuccess(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    backgroundColor: AppColors.success,
    icon: Icons.check_circle_outline_rounded,
  );
}

void showAppError(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    backgroundColor: AppColors.danger,
    icon: Icons.error_outline_rounded,
  );
}

void _showAppSnackBar(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
  required IconData icon,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
