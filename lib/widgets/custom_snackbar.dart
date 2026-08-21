import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.greenAccent, Icons.check_circle_outline_rounded);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.redAccent, Icons.error_outline_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blueAccent, Icons.info_outline_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, Colors.orangeAccent, Icons.warning_amber_rounded);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
