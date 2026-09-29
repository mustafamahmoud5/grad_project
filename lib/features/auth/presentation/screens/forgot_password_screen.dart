import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection_container.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AuthCubit(getIt()),
    child: const ForgotPasswordView(),
  );
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().resetPassword(_emailController.text);
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.failure && state.message != null) {
        context.showSnackBar(state.message!, isError: true);
      } else if (state.status == AuthStatus.passwordResetSent) {
        context.showSnackBar(
          'We sent a password reset link to ${_emailController.text.trim()}.',
        );
        Navigator.of(context).maybePop();
      }
    },
    builder: (context, state) => AuthScaffold(
      title: 'Forget Password',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Image.asset(
              AssetConstants.forgotPassword,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Verify Email',
              isLoading: state.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
