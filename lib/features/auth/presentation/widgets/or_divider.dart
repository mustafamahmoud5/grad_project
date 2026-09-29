import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: _Line()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'OR',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        ),
      ),
      const Expanded(child: _Line()),
    ],
  );
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(color: AppColors.primary, thickness: 1),
  );
}
