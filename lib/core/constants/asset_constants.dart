abstract final class AssetConstants {
  static const moviesLogo = 'assets/logos/movies_logo.png';
  static const routeLogo = 'assets/logos/route_logo.png';

  static const forgotPassword = 'assets/images/forgot2.png';

  static const onboardingBackground = 'assets/images/onboarding/images.jpeg';

  static String onboardingFrame(int index) =>
      'assets/images/onboarding/onboarding_frame_${index + 1}.png';

  /// Avatars a user can pick on register / edit profile. The index is what
  /// gets stored in the user's profile document.
  static const avatars = [
    'assets/images/gamer1.png',
    'assets/images/gamer2.png',
    'assets/images/gamer3.png',
  ];

  static String avatar(int? index) =>
      avatars[(index ?? 0).clamp(0, avatars.length - 1)];
}
