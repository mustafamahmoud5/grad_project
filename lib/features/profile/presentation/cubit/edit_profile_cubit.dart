import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/auth_repository.dart';

enum EditProfileStatus {
  loading,
  ready,
  saving,
  saved,
  resetEmailSent,
  deleting,
  deleted,
  failure,
  loadFailure,
}

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.user,
    this.avatarIndex = 0,
    this.message,
  });

  final EditProfileStatus status;
  final AppUser? user;
  final int avatarIndex;
  final String? message;

  bool get isBusy =>
      status == EditProfileStatus.saving ||
      status == EditProfileStatus.deleting;

  EditProfileState copyWith({
    EditProfileStatus? status,
    AppUser? user,
    int? avatarIndex,
    String? message,
  }) => EditProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    avatarIndex: avatarIndex ?? this.avatarIndex,
    message: message,
  );

  @override
  List<Object?> get props => [status, user, avatarIndex, message];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._auth) : super(const EditProfileState());

  final AuthRepository _auth;

  Future<void> load() async {
    emit(const EditProfileState());
    final result = await _auth.getCurrentUser();
    if (isClosed) return;
    emit(
      result.when(
        success: (user) => EditProfileState(
          status: EditProfileStatus.ready,
          user: user,
          avatarIndex: user.avatarIndex,
        ),
        failure: (failure) => EditProfileState(
          status: EditProfileStatus.loadFailure,
          message: failure.message,
        ),
      ),
    );
  }

  void selectAvatar(int index) =>
      emit(state.copyWith(status: EditProfileStatus.ready, avatarIndex: index));

  Future<void> save({required String name, required String phone}) async {
    if (state.isBusy) return;
    emit(state.copyWith(status: EditProfileStatus.saving));
    final result = await _auth.updateProfile(
      name: name,
      phone: phone,
      avatarIndex: state.avatarIndex,
    );
    if (isClosed) return;
    emit(
      result.when(
        success: (user) =>
            state.copyWith(status: EditProfileStatus.saved, user: user),
        failure: (failure) => state.copyWith(
          status: EditProfileStatus.failure,
          message: failure.message,
        ),
      ),
    );
  }

  Future<void> sendPasswordReset() async {
    final email = state.user?.email ?? '';
    if (state.isBusy || email.isEmpty) return;
    final result = await _auth.sendPasswordResetEmail(email);
    if (isClosed) return;
    emit(
      result.when(
        success: (_) => state.copyWith(
          status: EditProfileStatus.resetEmailSent,
          message: 'We sent a password reset link to $email.',
        ),
        failure: (failure) => state.copyWith(
          status: EditProfileStatus.failure,
          message: failure.message,
        ),
      ),
    );
  }

  Future<void> deleteAccount() async {
    if (state.isBusy) return;
    emit(state.copyWith(status: EditProfileStatus.deleting));
    final result = await _auth.deleteAccount();
    if (isClosed) return;
    emit(
      result.when(
        success: (_) => state.copyWith(status: EditProfileStatus.deleted),
        failure: (failure) => state.copyWith(
          status: EditProfileStatus.failure,
          message: failure.message,
        ),
      ),
    );
  }
}
