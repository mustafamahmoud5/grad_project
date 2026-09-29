import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../cubit/home_cubit.dart';

/// Genre row: "Action ........ See More ->" with a horizontal poster list.
class HomeSectionView extends StatelessWidget {
  const HomeSectionView({
    super.key,
    required this.section,
    required this.onSeeMore,
  });

  final HomeSection section;
  final VoidCallback onSeeMore;

  static const posterWidth = 146.0;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(title: section.genre, onSeeMore: onSeeMore),
      const SizedBox(height: 12),
      SizedBox(
        height: posterWidth / MoviePosterCard.aspectRatio,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: section.movies.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final movie = section.movies[index];
            return MoviePosterCard(
              movie: movie,
              width: posterWidth,
              onTap: () => AppRouter.openMovie(context, movie),
            );
          },
        ),
      ),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeMore});

  final String title;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 16, right: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeMore,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See More',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    ),
  );
}

class HomeSectionSkeleton extends StatelessWidget {
  const HomeSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: AppShimmer(child: ShimmerBox(width: 120, height: 24, radius: 8)),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: HomeSectionView.posterWidth / MoviePosterCard.aspectRatio,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) =>
              const MoviePosterSkeleton(width: HomeSectionView.posterWidth),
        ),
      ),
    ],
  );
}
