// lib/utils/snackbar_helper.dart

import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class SnackBarHelper {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final snackBarConfig = _getSnackBarConfig(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(snackBarConfig.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snackBarConfig.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: snackBarConfig.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action:
            actionLabel != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onActionPressed ?? () {},
                )
                : null,
      ),
    );
  }

  // Méthodes de convenance pour chaque type
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static _SnackBarConfig _getSnackBarConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          title: 'Success',
          backgroundColor: const Color(0xFF4CAF50), // Vert
          icon: Icons.check_circle,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          title: 'An Error Occurred',
          backgroundColor: const Color(0xFFE53E3E), // Rouge
          icon: Icons.error,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          title: 'Warning',
          backgroundColor: const Color(0xFFED8936), // Orange
          icon: Icons.warning,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          title: 'Info, Information',
          backgroundColor: const Color(0xFF3182CE), // Bleu
          icon: Icons.info,
        );
    }
  }
}

class _SnackBarConfig {
  final String title;
  final Color backgroundColor;
  final IconData icon;

  _SnackBarConfig({
    required this.title,
    required this.backgroundColor,
    required this.icon,
  });
}
