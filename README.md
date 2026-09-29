# Movies App

Flutter graduation project: browse, search and save movies from the
[YTS API](https://yts.lt/api) with Firebase Authentication.

## Features

- Splash, onboarding (shown once) and auth-aware startup
- Email/password login, register (avatar, name, phone), password reset,
  Google Sign-In
- Home: "Available Now" carousel of the latest movies and popular movies per genre
- Browse: genre tabs with an infinitely scrolling grid
- Search: debounced live search with pagination
- Movie details: trailer, rating, runtime, likes, screenshots, similar movies,
  summary, cast and genres
- Watch list (Firestore, synced per user) and history (on device, per user)
- Profile and edit profile (avatar, name, phone, reset password, delete account)
- Loading, empty and error states everywhere; offline and timeout handling

## Architecture

```
lib/
  app/        MaterialApp, router (with protected routes), theme
  core/       constants, errors (exceptions -> failures), network (Dio),
              services (Firebase, SharedPreferences), shared state, widgets
  domain/     entities and repository contracts
  data/       models (JSON parsing), remote/local data sources, repositories
  features/   one folder per feature, each with cubit/ + screens/ + widgets/
```

Flow: `Screen -> Cubit -> Repository -> Data source -> YTS API / Firebase / local storage`.
Repositories return `Result<T>` (`Success` / `Failed(Failure)`), so screens
only ever show user-friendly messages. Dependencies are wired in
`lib/injection_container.dart` with `get_it`; state management is `flutter_bloc`.

The YTS API base URL is `https://movies-api.accel.li/api/v2/`, the base the
YTS API itself announces (`yts.lt` now redirects without CORS headers, which
breaks Flutter Web).

## Firebase setup

The app uses the existing Firebase project `gradproject-7f8d0`.

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=gradproject-7f8d0 \
  --platforms=android,ios,web \
  --android-package-name=com.example.grad_project \
  --ios-bundle-id=com.example.gradProject
```

Then in the Firebase Console:

1. Authentication > Sign-in method: enable **Email/Password** and **Google**.
2. Project settings > Android app: add your debug/release **SHA-1** (needed for
   Google Sign-In on Android).
3. Firestore Database: create the database and publish `firestore.rules`.
4. Authentication > Settings > Authorized domains: add your web hosting domain.

## Run and test

```bash
flutter pub get
flutter run
flutter analyze
flutter test                          # unit + widget tests (offline)
flutter test --run-skipped -t live    # end-to-end check against the real YTS API
```
