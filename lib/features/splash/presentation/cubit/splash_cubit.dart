import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/onboarding_repository.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required AuthRepository authRepository,
    required OnboardingRepository onboardingRepository,
    required Future<bool> Function() initializeFirebase,
    this.minimumDuration = const Duration(milliseconds: 1800),
  }) : _auth = authRepository,
       _onboarding = onboardingRepository,
       _initializeFirebase = initializeFirebase,
       super(const SplashInitial());

  final AuthRepository _auth;
  final OnboardingRepository _onboarding;
  final Future<bool> Function() _initializeFirebase;
  final Duration minimumDuration;

  Future<void> start() async {
    final minimumDelay = Future<void>.delayed(minimumDuration);

    // Initialization errors are handled inside FirebaseService: the app keeps
    // running and the auth screens explain the problem.
    await _initializeFirebase();
    final userId = await _auth.restoreSession();
    await minimumDelay;
    if (isClosed) return;

    final SplashDestination destination;
    if (!_onboarding.isCompleted) {
      destination = SplashDestination.onboarding;
    } else if (userId != null) {
      destination = SplashDestination.home;
    } else {
      destination = SplashDestination.login;
    }
    emit(SplashFinished(destination));
  }
}
