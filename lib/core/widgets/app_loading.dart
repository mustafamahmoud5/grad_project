import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: size,
      child: const CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    ),
  );
}
