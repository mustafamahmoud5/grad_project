import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../injection_container.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_page.dart';

class OnboardingContentData {
  const OnboardingContentData({
    required this.title,
    required this.description,
    required this.button,
  });

  final String title;
  final String description;
  final String button;
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const pages = [
    OnboardingContentData(
      title: 'Find Your Next Favorite Movie Here',
      description:
          'Get access to a huge library of movies to suit all tastes. You will surely like it.',
      button: 'Explore Now',
    ),
    OnboardingContentData(
      title: 'Discover Movies',
      description:
          'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
      button: 'Next',
    ),
    OnboardingContentData(
      title: 'Explore All Genres',
      description:
          'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
      button: 'Next',
    ),
    OnboardingContentData(
      title: 'Create Watchlists',
      description:
          'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
      button: 'Next',
    ),
    OnboardingContentData(
      title: 'Rate, Review, and Learn',
      description:
          'Share your thoughts on the movies you have watched. Dive deep into film details and help others discover great movies with your reviews.',
      button: 'Next',
    ),
    OnboardingContentData(
      title: 'Start Watching Now',
      description: '',
      button: 'Finish',
    ),
  ];

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        OnboardingCubit(repository: getIt(), pageCount: pages.length),
    child: const _OnboardingView(),
  );
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.isLastPage) {
      await cubit.complete();
      if (mounted) AppRouter.goToLogin(context);
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _back() => _pageController.previousPage(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: BlocBuilder<OnboardingCubit, int>(
      builder: (context, currentPage) => PageView.builder(
        controller: _pageController,
        itemCount: OnboardingScreen.pages.length,
        onPageChanged: context.read<OnboardingCubit>().changePage,
        itemBuilder: (context, index) {
          final page = OnboardingScreen.pages[index];
          return OnboardingPage(
            backgroundImage: AssetConstants.onboardingBackground,
            frameImage: AssetConstants.onboardingFrame(index),
            title: page.title,
            description: page.description,
            buttonText: page.button,
            showBack: index > 0,
            currentPage: currentPage,
            pageCount: OnboardingScreen.pages.length,
            onNext: _next,
            onBack: _back,
          );
        },
      ),
    ),
  );
}
