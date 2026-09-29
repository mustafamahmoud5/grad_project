import '../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  bool get isAvailable;

  String? get currentUserId;

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
