import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection_container.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/avatar_picker.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AuthCubit(getIt()),
    child: const RegisterView(),
  );
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  int _avatarIndex = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      avatarIndex: _avatarIndex,
    );
  }

  void _goToLogin() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRouter.login);
    }
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
      title: 'Register',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AvatarCarousel(
              selectedIndex: _avatarIndex,
              onChanged: (index) => setState(() => _avatarIndex = index),
            ),
            const SizedBox(height: 8),
            const Text(
              'Avatar',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              hint: 'Name',
              icon: Icons.badge_rounded,
              validator: Validators.name,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_rounded,
              isPassword: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _confirmPasswordController,
              hint: 'Confirm Password',
              icon: Icons.lock_rounded,
              isPassword: true,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _phoneController,
              hint: 'Phone Number',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              validator: Validators.optionalPhone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _register(),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Create Account',
              isLoading: state.isLoading,
              onPressed: _register,
            ),
            const SizedBox(height: 12),
            AuthLink(
              text: 'Already Have Account ? ',
              action: 'Login',
              onTap: _goToLogin,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
