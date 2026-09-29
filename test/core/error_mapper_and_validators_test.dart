import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/core/errors/error_mapper.dart';
import 'package:grad_project/core/errors/exceptions.dart';
import 'package:grad_project/core/errors/failures.dart';
import 'package:grad_project/core/utils/extensions.dart';
import 'package:grad_project/core/utils/validators.dart';

void main() {
  group('ErrorMapper', () {
    test('maps Firebase auth codes to friendly messages', () {
      Failure map(String code) =>
          ErrorMapper.toFailure(FirebaseAuthException(code: code));

      expect(
        map('invalid-credential').message,
        'Email or password is incorrect.',
      );
      expect(
        map('email-already-in-use').message,
        'An account already exists for this email.',
      );
      expect(map('network-request-failed').message, contains('internet'));
      expect(map('some-new-code'), isA<AuthFailure>());
    });

    test('maps data layer exceptions', () {
      expect(
        ErrorMapper.toFailure(const NetworkException()),
        isA<NetworkFailure>(),
      );
      expect(
        ErrorMapper.toFailure(
          const ServerException('Movie not found.'),
        ).message,
        'This movie could not be found.',
      );
      expect(
        ErrorMapper.toFailure(const AuthException('Custom')).message,
        'Custom',
      );
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('nope'), 'Enter a valid email');
      expect(Validators.email(' user@mail.com '), isNull);
    });

    test('password and confirmation', () {
      expect(Validators.password('12345'), contains('at least 6'));
      expect(Validators.password('123456'), isNull);
      expect(
        Validators.confirmPassword('abc', 'abd'),
        'Passwords do not match',
      );
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
    });

    test('name and optional phone', () {
      expect(Validators.name('Al'), contains('at least 3'));
      expect(Validators.name('Ali'), isNull);
      expect(Validators.optionalPhone(''), isNull);
      expect(Validators.optionalPhone('+20 100 123 4567'), isNull);
      expect(Validators.optionalPhone('abc'), 'Enter a valid phone number');
    });
  });

  test('runtime formatting', () {
    expect(0.asRuntime, '');
    expect(45.asRuntime, '45m');
    expect(120.asRuntime, '2h');
    expect(135.asRuntime, '2h 15m');
  });
}
