import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Initializes Firebase exactly once and remembers whether it succeeded, so
/// the app can keep working (movies, browsing) and show a friendly message on
/// the auth screens when Firebase is not configured for a platform.
abstract final class FirebaseService {
  static Future<bool>? _initialization;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<bool> initialize() => _initialization ??= _initialize();

  static Future<bool> _initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: _options());
      }
      _initialized = true;
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
      _initialized = false;
    }
    return _initialized;
  }

  /// Returns the generated options, or `null` on Android when they have not
  /// been generated yet so the native google-services.json is used instead.
  static FirebaseOptions? _options() {
    try {
      return DefaultFirebaseOptions.currentPlatform;
    } on UnsupportedError {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return null;
      }
      rethrow;
    }
  }
}
