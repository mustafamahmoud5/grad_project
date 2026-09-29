import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection_container.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/or_divider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => AuthCubit(getIt()), child: const LoginView());
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.failure && state.message != null) {
        context.showSnackBar(state.message!, isError: true);
      } else if (state.status == AuthStatus.authenticated) {
        AppRouter.goHome(context);
      }
    },
    builder: (context, state) => AuthScaffold(
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  AssetConstants.moviesLogo,
                  width: 121,
                  height: 118,
                ),
              ),
              const SizedBox(height: 60),
              AppTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 22),
              AppTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_rounded,
                isPassword: true,
                validator: (value) => Validators.required(value, 'Password'),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                autofillHints: const [AutofillHints.password],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRouter.forgotPassword),
                  child: Text(
                    'Forget Password ?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Login',
                isLoading: state.isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 16),
              AuthLink(
                text: "Don't Have Account ? ",
                action: 'Create One',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.register),
              ),
              const SizedBox(height: 16),
              const OrDivider(),
              const SizedBox(height: 24),
              AppButton(
                label: 'Login With Google',
                icon: const _GoogleMark(),
                onPressed: state.isLoading
                    ? null
                    : context.read<AuthCubit>().signInWithGoogle,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: AppColors.black,
      shape: BoxShape.circle,
    ),
    child: Text(
      'G',
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
    ),
  );
}
