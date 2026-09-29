import '../../core/errors/error_mapper.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  bool get isAvailable => _remote.isAvailable;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Future<String?> restoreSession() async {
    try {
      return await _remote.restoreSession();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) => _guard(() => _remote.login(email: email, password: password));

  @override
  Future<Result<AppUser>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    int avatarIndex = 0,
  }) => _guard(
    () => _remote.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      avatarIndex: avatarIndex,
    ),
  );

  @override
  Future<Result<AppUser>> signInWithGoogle() =>
      _guard(_remote.signInWithGoogle);

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      _guard(() => _remote.sendPasswordResetEmail(email));

  @override
  Future<Result<AppUser>> getCurrentUser() => _guard(_remote.getCurrentUser);

  @override
  Future<Result<AppUser>> updateProfile({
    required String name,
    required String phone,
    required int avatarIndex,
  }) => _guard(
    () => _remote.updateProfile(
      name: name,
      phone: phone,
      avatarIndex: avatarIndex,
    ),
  );

  @override
  Future<Result<void>> deleteAccount() => _guard(_remote.deleteAccount);

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Logging out locally must never fail from the user's point of view.
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failed(ErrorMapper.toFailure(error));
    }
  }
}
