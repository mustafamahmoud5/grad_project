import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

extension AppSnackBar on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.surfaceLight,
        ),
      );
  }
}
