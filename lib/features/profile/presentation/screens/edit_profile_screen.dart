import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/widgets/avatar_picker.dart';
import '../cubit/edit_profile_cubit.dart';
import '../widgets/user_avatar.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => EditProfileCubit(getIt())..load(),
    child: const EditProfileView(),
  );
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(EditProfileState state) async {
    final cubit = context.read<EditProfileCubit>();
    final index = await showAvatarPicker(context, state.avatarIndex);
    if (index != null) cubit.selectAvatar(index);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<EditProfileCubit>().save(
      name: _nameController.text,
      phone: _phoneController.text,
    );
  }

  Future<void> _confirmDelete() async {
    final cubit = context.read<EditProfileCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Your account, profile and watch list will be permanently deleted. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.deleteAccount();
  }

  void _onStateChanged(BuildContext context, EditProfileState state) {
    switch (state.status) {
      case EditProfileStatus.ready
          when state.user != null &&
              _nameController.text.isEmpty &&
              _phoneController.text.isEmpty:
        _nameController.text = state.user!.name;
        _phoneController.text = state.user!.phone;
      case EditProfileStatus.saved:
        context.showSnackBar('Profile updated successfully.');
        Navigator.of(context).pop(state.user);
      case EditProfileStatus.deleted:
        context.showSnackBar('Your account was deleted.');
        AppRouter.goToLogin(context);
      case EditProfileStatus.resetEmailSent:
        context.showSnackBar(state.message!);
      case EditProfileStatus.failure:
        context.showSnackBar(state.message!, isError: true);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: _onStateChanged,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: SafeArea(
            child: switch (state.status) {
              EditProfileStatus.loading => const AppLoading(),
              EditProfileStatus.loadFailure => AppError(
                message: state.message ?? 'Could not load your profile.',
                onRetry: context.read<EditProfileCubit>().load,
              ),
              _ => _form(state),
            },
          ),
        ),
      );

  Widget _form(EditProfileState state) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: ResponsiveCenter(
      maxWidth: 480,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Semantics(
                button: true,
                label: 'Change avatar',
                child: GestureDetector(
                  onTap: state.isBusy ? null : () => _pickAvatar(state),
                  child: Stack(
                    children: [
                      UserAvatar(
                        user: state.user,
                        avatarIndex: state.avatarIndex,
                        size: 150,
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _nameController,
              hint: 'Name',
              icon: Icons.person_rounded,
              validator: Validators.name,
              enabled: !state.isBusy,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _phoneController,
              hint: 'Phone Number',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              validator: Validators.optionalPhone,
              textInputAction: TextInputAction.done,
              enabled: !state.isBusy,
              onSubmitted: (_) => _save(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: state.isBusy
                    ? null
                    : context.read<EditProfileCubit>().sendPasswordReset,
                child: Text(
                  'Reset Password',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            AppButton(
              label: 'Delete Account',
              variant: AppButtonVariant.danger,
              isLoading: state.status == EditProfileStatus.deleting,
              onPressed: state.isBusy ? null : _confirmDelete,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Update Data',
              isLoading: state.status == EditProfileStatus.saving,
              onPressed: state.isBusy ? null : _save,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
