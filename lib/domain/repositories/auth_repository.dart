import '../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Whether Firebase is available on this platform/build.
  bool get isAvailable;

  /// The id of the signed-in user, or `null`.
  String? get currentUserId;

  /// Waits for Firebase to restore a persisted session and returns the
  /// signed-in user's id, or `null`.
  Future<String?> restoreSession();

  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> register({
    required String name,
    required String email,
    required String password,
    String phone,
    int avatarIndex,
  });

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<AppUser>> getCurrentUser();

  Future<Result<AppUser>> updateProfile({
    required String name,
    required String phone,
    required int avatarIndex,
  });

  Future<Result<void>> deleteAccount();

  Future<void> logout();
}
