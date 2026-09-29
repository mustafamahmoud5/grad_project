import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Text field styled like the design, with validation and a password
/// visibility toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.enabled = true,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    validator: widget.validator,
    obscureText: _obscured,
    enabled: widget.enabled,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    onFieldSubmitted: widget.onSubmitted,
    autofillHints: widget.autofillHints,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    style: AppTextStyles.bodyLarge.copyWith(
      color: widget.enabled ? AppColors.white : AppColors.textSecondary,
    ),
    decoration: InputDecoration(
      hintText: widget.hint,
      prefixIcon: Icon(widget.icon, size: 26),
      suffixIcon: widget.isPassword
          ? IconButton(
              tooltip: _obscured ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscured = !_obscured),
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
            )
          : null,
    ),
  );
}
