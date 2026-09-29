import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../domain/entities/movie.dart';
import 'app_network_image.dart';
import 'app_shimmer.dart';

/// Movie poster with the rating badge used across Home, Browse, Search and
/// Profile. Posters always keep the 2:3 aspect ratio.
class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width,
    this.radius = 16,
  });

  final Movie movie;
  final VoidCallback? onTap;
  final double? width;
  final double radius;

  static const aspectRatio = 2 / 3;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Semantics(
      button: onTap != null,
      label: movie.title,
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Material(
            color: AppColors.surfaceLight,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(url: movie.posterUrl ?? movie.largePosterUrl),
                  if (movie.rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: RatingBadge(rating: movie.rating),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.overlay,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
        ],
      ),
    ),
  );
}

class MoviePosterSkeleton extends StatelessWidget {
  const MoviePosterSkeleton({super.key, this.width, this.radius = 16});

  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: MoviePosterCard.aspectRatio,
        child: ShimmerBox(radius: radius),
      ),
    ),
  );
}
