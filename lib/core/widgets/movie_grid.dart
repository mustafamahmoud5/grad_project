import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';
import 'app_loading.dart';
import 'movie_poster_card.dart';

class MovieGrid extends StatefulWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    required this.onMovieTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.maxPosterWidth = 190,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final String? loadMoreError;
  final double maxPosterWidth;
  final EdgeInsets padding;

  @override
  State<MovieGrid> createState() => _MovieGridState();
}

class _MovieGridState extends State<MovieGrid> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null || widget.isLoadingMore) return;
    if (widget.loadMoreError != null) return;
    if (_controller.position.extentAfter < 400) widget.onLoadMore!();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    controller: _controller,
    slivers: [
      SliverPadding(
        padding: widget.padding,
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: widget.maxPosterWidth,
            childAspectRatio: MoviePosterCard.aspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: widget.movies.length,
          itemBuilder: (context, index) {
            final movie = widget.movies[index];
            return MoviePosterCard(
              movie: movie,
              onTap: () => widget.onMovieTap(movie),
            );
          },
        ),
      ),
      if (widget.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: AppLoading(size: 28),
          ),
        ),
      if (widget.loadMoreError != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: TextButton.icon(
                onPressed: widget.onLoadMore,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(widget.loadMoreError!),
              ),
            ),
          ),
        ),
    ],
  );
}

class MovieGridSkeleton extends StatelessWidget {
  const MovieGridSkeleton({super.key, this.maxPosterWidth = 190});

  final double maxPosterWidth;

  @override
  Widget build(BuildContext context) => GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxPosterWidth,
      childAspectRatio: MoviePosterCard.aspectRatio,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemCount: 9,
    itemBuilder: (context, index) => const MoviePosterSkeleton(),
  );
}
