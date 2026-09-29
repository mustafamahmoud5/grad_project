// Firebase options for the existing "gradproject" Firebase project
// (project id: gradproject-7f8d0).
//
// The iOS values below are copied from ios/Runner/GoogleService-Info.plist.
// Android and Web are not configured yet. Run the following to regenerate this
// file for every platform (it will overwrite this file):
//
//   flutterfire configure --project=gradproject-7f8d0 \
//     --platforms=android,ios,web \
//     --android-package-name=com.example.grad_project \
//     --ios-bundle-id=com.example.gradProject
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run `flutterfire configure` to add the web app.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'run `flutterfire configure` to add the android app.',
        );
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemwe4F6stvbXoZjUG3zm88cPb_g_DPZ4',
    appId: '1:489934243389:ios:37c4e4da959a44bc018c54',
    messagingSenderId: '489934243389',
    projectId: 'gradproject-7f8d0',
    storageBucket: 'gradproject-7f8d0.firebasestorage.app',
    iosClientId:
        '489934243389-uel9a24a3lli8enn9rm98s0rvnn8vnhq.apps.googleusercontent.com',
    iosBundleId: 'com.example.gradProject',
  );
}
