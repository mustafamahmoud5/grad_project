import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/movie_details/presentation/screens/movie_details_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../injection_container.dart';

abstract final class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String movieDetails = '/movie-details';
  static const String editProfile = '/edit-profile';

  static const _protected = {home, movieDetails, editProfile};

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
    _page(const RouteSettings(name: splash), const SplashScreen()),
  ];

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (_protected.contains(settings.name) &&
        getIt<AuthRepository>().currentUserId == null) {
      return _page(const RouteSettings(name: login), const LoginScreen());
    }

    final Widget screen = switch (settings.name) {
      splash => const SplashScreen(),
      onboarding => const OnboardingScreen(),
      login => const LoginScreen(),
      register => const RegisterScreen(),
      forgotPassword => const ForgotPasswordScreen(),
      home => MainScreen(
        initialTab: settings.arguments is MainTab
            ? settings.arguments! as MainTab
            : MainTab.home,
      ),
      movieDetails => _movieDetails(settings.arguments),
      editProfile => const EditProfileScreen(),
      _ => const SplashScreen(),
    };
    return _page(settings, screen);
  }

  static Widget _movieDetails(Object? arguments) => switch (arguments) {
    final Movie movie => MovieDetailsScreen(movie: movie),
    final int id => MovieDetailsScreen(
      movie: Movie(id: id, title: ''),
    ),
    _ => const MainScreen(),
  };

  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    Widget screen,
  ) => MaterialPageRoute<dynamic>(settings: settings, builder: (_) => screen);

  static Future<void> openMovie(BuildContext context, Movie movie) =>
      Navigator.of(context).pushNamed(movieDetails, arguments: movie);

  static void goHome(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(home, (route) => false);

  static void goToLogin(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
}
