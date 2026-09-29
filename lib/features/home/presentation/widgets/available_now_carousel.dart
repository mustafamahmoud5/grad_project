import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../../../../domain/entities/movie.dart';

class AvailableNowCarousel extends StatelessWidget {
  const AvailableNowCarousel({
    super.key,
    required this.movies,
    required this.onPageChanged,
    required this.height,
  });

  final List<Movie> movies;
  final ValueChanged<int> onPageChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final posterWidth = height * MoviePosterCard.aspectRatio;
    return CarouselSlider.builder(
      itemCount: movies.length,
      options: CarouselOptions(
        height: height,
        viewportFraction: (posterWidth / width).clamp(0.2, 0.62),
        enlargeCenterPage: true,
        enlargeFactor: 0.28,
        enableInfiniteScroll: movies.length > 2,
        onPageChanged: (index, reason) => onPageChanged(index),
      ),
      itemBuilder: (context, index, realIndex) {
        final movie = movies[index];
        return MoviePosterCard(
          movie: movie,
          radius: 20,
          onTap: () => AppRouter.openMovie(context, movie),
        );
      },
    );
  }
}
