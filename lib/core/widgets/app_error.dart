import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Friendly error state with an optional retry button.
class AppError extends StatelessWidget {
  const AppError({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 48),
                  textStyle: AppTextStyles.labelLarge,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
