import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../domain/entities/movie_details.dart';
import '../../../../injection_container.dart';
import '../cubit/movie_details_cubit.dart';
import '../widgets/details_sections.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MovieDetailsCubit(
      movie: movie,
      movieRepository: getIt(),
      favoritesRepository: getIt(),
      historyRepository: getIt(),
    )..load(),
    child: const MovieDetailsView(),
  );
}

class MovieDetailsView extends StatelessWidget {
  const MovieDetailsView({super.key});

  Future<void> _open(BuildContext context, String? url) async {
    final uri = url == null ? null : Uri.tryParse(url);
    final opened =
        uri != null &&
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        ).catchError((_) => false);
    if (!opened && context.mounted) {
      context.showSnackBar('Could not open the link.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<MovieDetailsCubit, MovieDetailsState>(
        listenWhen: (previous, current) =>
            current.message != null && previous.message != current.message,
        listener: (context, state) => context.showSnackBar(state.message!),
        builder: (context, state) {
          final movie = state.movie;
          final details = state.details;
          final trailer = details?.trailerCode;
          final trailerUrl = trailer == null
              ? null
              : '${ApiConstants.youtubeWatchUrl}$trailer';

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    movie: movie,
                    isFavorite: state.isFavorite,
                    onToggleFavorite: context
                        .read<MovieDetailsCubit>()
                        .toggleFavorite,
                    onPlay: trailerUrl == null
                        ? null
                        : () => _open(context, trailerUrl),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    maxWidth: 800,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: _Body(
                        state: state,
                        onWatch: movie.url == null
                            ? null
                            : () => _open(context, movie.url),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.movie,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onPlay,
  });

  final Movie movie;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = (size.height * 0.72).clamp(420.0, 680.0);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(url: movie.heroImageUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33121312),
                  Color(0x99121312),
                  AppColors.background,
                ],
                stops: [0, 0.6, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  IconButton(
                    tooltip: isFavorite
                        ? 'Remove from watch list'
                        : 'Add to watch list',
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isFavorite ? AppColors.primary : AppColors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onPlay != null)
            Center(
              child: Semantics(
                button: true,
                label: 'Play trailer',
                child: InkResponse(
                  onTap: onPlay,
                  radius: 50,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: 56,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 8,
            child: Column(
              children: [
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium,
                ),
                if (movie.year > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${movie.year}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, this.onWatch});

  final MovieDetailsState state;
  final VoidCallback? onWatch;

  @override
  Widget build(BuildContext context) {
    final MovieDetails? details = state.details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'Watch',
          variant: AppButtonVariant.danger,
          onPressed: onWatch,
        ),
        const SizedBox(height: 16),
        MovieStats(movie: state.movie),
        switch (state.status) {
          DetailsStatus.loading => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: AppLoading(),
          ),
          DetailsStatus.failure => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AppError(
              message: state.errorMessage ?? 'Could not load this movie.',
              onRetry: context.read<MovieDetailsCubit>().load,
            ),
          ),
          DetailsStatus.success => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (details!.screenshots.isNotEmpty) ...[
                const SectionTitle('Screen Shots'),
                ScreenshotsList(screenshots: details.screenshots),
              ],
              if (state.similar.isNotEmpty) ...[
                const SectionTitle('Similar'),
                SimilarGrid(movies: state.similar),
              ],
              if (details.overview.isNotEmpty) ...[
                const SectionTitle('Summary'),
                Text(
                  details.overview,
                  style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                ),
              ],
              if (details.cast.isNotEmpty) ...[
                const SectionTitle('Cast'),
                CastList(cast: details.cast),
              ],
              if (details.genres.isNotEmpty) ...[
                const SectionTitle('Genres'),
                GenreChips(genres: details.genres),
              ],
            ],
          ),
        },
      ],
    );
  }
}
