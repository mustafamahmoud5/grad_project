import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'exceptions.dart';
import 'failures.dart';

abstract final class ErrorMapper {
  static Failure toFailure(Object error) => switch (error) {
    NetworkException() => const NetworkFailure(),
    TimeoutException() => const TimeoutFailure(),
    ParsingException() => const InvalidDataFailure(),
    ServerException(:final message) when message == 'Movie not found.' =>
      const ServerFailure('This movie could not be found.'),
    ServerException() => const ServerFailure(),
    CacheException() => const CacheFailure(),
    AuthException(:final message) => AuthFailure(message),
    FirebaseAuthException() => AuthFailure(authMessage(error)),
    GoogleSignInException() => AuthFailure(_googleMessage(error)),
    FirebaseException() => _firebaseFailure(error),
    _ => const UnknownFailure(),
  };

  static String authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'For your security, please log in again and retry.';
      case 'operation-not-allowed':
        return 'This sign in method is not enabled for the app.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google Sign-In was cancelled.';
      case 'popup-blocked':
        return 'Your browser blocked the sign in popup. Allow popups and retry.';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a different sign in method.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _googleMessage(GoogleSignInException error) =>
      switch (error.code) {
        GoogleSignInExceptionCode.canceled => 'Google Sign-In was cancelled.',
        GoogleSignInExceptionCode.clientConfigurationError =>
          'Google Sign-In is not configured for this platform yet.',
        GoogleSignInExceptionCode.uiUnavailable =>
          'Google Sign-In is not available on this device.',
        _ => 'Google Sign-In failed. Please try again.',
      };

  static Failure _firebaseFailure(FirebaseException error) =>
      switch (error.code) {
        'unavailable' => const NetworkFailure(),
        'permission-denied' => const ServerFailure(
          'You do not have permission to do this.',
        ),
        'unauthenticated' => const AuthFailure(
          'Your session has ended. Please log in again.',
        ),
        _ => const ServerFailure(),
      };
}
