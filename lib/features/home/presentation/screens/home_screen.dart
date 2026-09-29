import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../cubit/home_cubit.dart';
import '../widgets/available_now_carousel.dart';
import '../widgets/home_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeMore});

  /// Opens the Browse tab filtered by the given genre.
  final ValueChanged<String> onSeeMore;

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
    builder: (context, state) => switch (state.status) {
      HomeStatus.loading => const _HomeSkeleton(),
      HomeStatus.failure => SafeArea(
        child: AppError(
          message: state.errorMessage ?? 'Could not load movies.',
          onRetry: context.read<HomeCubit>().load,
        ),
      ),
      HomeStatus.success => _HomeContent(state: state, onSeeMore: onSeeMore),
    },
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.onSeeMore});

  final HomeState state;
  final ValueChanged<String> onSeeMore;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final carouselHeight = (size.height * 0.42).clamp(260.0, 420.0);
    final headerHeight = carouselHeight + 190;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight + 60,
          child: _BlurredBackdrop(url: state.selectedMovie?.heroImageUrl),
        ),
        RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceLight,
          onRefresh: context.read<HomeCubit>().load,
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 16,
            ),
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              const _FadedTitle('Available Now'),
              const SizedBox(height: 12),
              if (state.availableNow.isNotEmpty)
                AvailableNowCarousel(
                  movies: state.availableNow,
                  height: carouselHeight,
                  onPageChanged: context.read<HomeCubit>().selectMovie,
                ),
              const SizedBox(height: 12),
              const _FadedTitle('Watch Now'),
              const SizedBox(height: 16),
              for (final section in state.sections) ...[
                HomeSectionView(
                  section: section,
                  onSeeMore: () => onSeeMore(section.genre),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The selected carousel poster, blurred and faded into the background.
class _BlurredBackdrop extends StatelessWidget {
  const _BlurredBackdrop({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: ImageFiltered(
          key: ValueKey(url),
          imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AppNetworkImage(url: url),
        ),
      ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x99121312),
              Color(0xCC121312),
              AppColors.background,
            ],
            stops: [0, 0.6, 1],
          ),
        ),
      ),
    ],
  );
}

/// Large headline that fades out towards the bottom, like the design.
class _FadedTitle extends StatelessWidget {
  const _FadedTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.white, AppColors.white.withValues(alpha: 0.25)],
    ).createShader(bounds),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.headlineLarge.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    ),
  );
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      260.0,
      420.0,
    );
    return SafeArea(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: AppShimmer(
              child: ShimmerBox(width: 240, height: 40, radius: 8),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: MoviePosterSkeleton(
              width: height * MoviePosterCard.aspectRatio,
              radius: 20,
            ),
          ),
          const SizedBox(height: 32),
          const HomeSectionSkeleton(),
        ],
      ),
    );
  }
}
