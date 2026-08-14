import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Custom themed snackbar helpers for success, error, and info messages.
class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppTheme.successGreen, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppTheme.errorRed, Icons.error_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppTheme.infoBlue, Icons.info_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppTheme.warningOrange, Icons.warning_rounded);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}
