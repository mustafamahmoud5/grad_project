import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../domain/entities/movie_details.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(title, style: AppTextStyles.headlineMedium),
  );
}

class MovieStats extends StatelessWidget {
  const MovieStats({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final likes = movie is MovieDetails ? (movie as MovieDetails).likeCount : 0;
    final stats = [
      (Icons.favorite_rounded, '$likes'),
      (Icons.access_time_filled_rounded, movie.runtime.asRuntime),
      (Icons.star_rounded, movie.rating.toStringAsFixed(1)),
    ].where((stat) => stat.$2.isNotEmpty).toList();

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(stats[i].$1, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        stats[i].$2,
                        style: AppTextStyles.headlineSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ScreenshotsList extends StatelessWidget {
  const ScreenshotsList({super.key, required this.screenshots});

  final List<String> screenshots;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final url in screenshots)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppNetworkImage(
              url: url,
              borderRadius: BorderRadius.circular(16),
              fallbackIcon: Icons.image_not_supported_outlined,
            ),
          ),
        ),
    ],
  );
}

class SimilarGrid extends StatelessWidget {
  const SimilarGrid({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 220,
      childAspectRatio: MoviePosterCard.aspectRatio,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemCount: movies.length,
    itemBuilder: (context, index) => MoviePosterCard(
      movie: movies[index],
      onTap: () => AppRouter.openMovie(context, movies[index]),
    ),
  );
}

class CastList extends StatelessWidget {
  const CastList({super.key, required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final member in cast)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppNetworkImage(
                url: member.imageUrl,
                width: 70,
                height: 70,
                borderRadius: BorderRadius.circular(10),
                fallbackIcon: Icons.person_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name : ${member.name}',
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                    ),
                    if (member.characterName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Character : ${member.characterName}',
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class GenreChips extends StatelessWidget {
  const GenreChips({super.key, required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 12,
    children: [
      for (final genre in genres)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(genre, style: AppTextStyles.bodyLarge),
        ),
    ],
  );
}
