import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../injection_container.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SplashCubit(
      authRepository: getIt(),
      onboardingRepository: getIt(),
      initializeFirebase: FirebaseService.initialize,
    )..start(),
    child: const SplashView(),
  );
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<SplashCubit, SplashState>(
    listener: (context, state) {
      if (state is! SplashFinished) return;
      final route = switch (state.destination) {
        SplashDestination.onboarding => AppRouter.onboarding,
        SplashDestination.login => AppRouter.login,
        SplashDestination.home => AppRouter.home,
      };
      Navigator.of(context).pushReplacementNamed(route);
    },
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  AssetConstants.moviesLogo,
                  width: 121,
                  height: 118,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Image.asset(
              AssetConstants.routeLogo,
              width: 180,
              height: 76,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              'Supervised by Mohamed Nabil',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
