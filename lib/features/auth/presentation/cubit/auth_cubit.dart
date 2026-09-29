import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, passwordResetSent, failure }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.user, this.message});

  final AuthStatus status;
  final AppUser? user;

  final String? message;

  bool get isLoading => status == AuthStatus.loading;

  @override
  List<Object?> get props => [status, user, message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({required String email, required String password}) =>
      _authenticate(() => _repository.login(email: email, password: password));

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    int avatarIndex = 0,
  }) => _authenticate(
    () => _repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      avatarIndex: avatarIndex,
    ),
  );

  Future<void> signInWithGoogle() =>
      _authenticate(_repository.signInWithGoogle);

  Future<void> resetPassword(String email) async {
    if (state.isLoading) return;
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.sendPasswordResetEmail(email);
    if (isClosed) return;
    emit(
      result.when(
        success: (_) => const AuthState(status: AuthStatus.passwordResetSent),
        failure: (failure) =>
            AuthState(status: AuthStatus.failure, message: failure.message),
      ),
    );
  }

  Future<void> _authenticate(Future<Result<AppUser>> Function() action) async {
    if (state.isLoading) return;
    emit(const AuthState(status: AuthStatus.loading));
    final result = await action();
    if (isClosed) return;
    emit(
      result.when(
        success: (user) =>
            AuthState(status: AuthStatus.authenticated, user: user),
        failure: (failure) =>
            AuthState(status: AuthStatus.failure, message: failure.message),
      ),
    );
  }
}
