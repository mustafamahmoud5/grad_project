import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum AppButtonVariant { primary, danger, outlined }

/// Full width button from the design with a built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = switch (variant) {
      AppButtonVariant.primary => AppColors.black,
      AppButtonVariant.danger => AppColors.white,
      AppButtonVariant.outlined => AppColors.primary,
    };
    final child = isLoading
        ? SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 3, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 10)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
    final onTap = isLoading ? null : onPressed;

    if (variant == AppButtonVariant.outlined) {
      return OutlinedButton(onPressed: onTap, child: child);
    }
    return ElevatedButton(
      onPressed: onTap,
      style: variant == AppButtonVariant.danger
          ? ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
              disabledForegroundColor: AppColors.white,
            )
          : null,
      child: child,
    );
  }
}
