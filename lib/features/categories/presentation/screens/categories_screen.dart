import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/state/paged_movies_state.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../cubit/categories_cubit.dart';

/// "Browse" tab.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoriesCubit>();
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) => Column(
          children: [
            GenreTabs(
              genres: cubit.genres,
              selected: state.genre,
              onSelected: cubit.selectGenre,
            ),
            Expanded(
              child: switch (state.status) {
                ListStatus.initial ||
                ListStatus.loading => const MovieGridSkeleton(),
                ListStatus.empty => AppEmpty(
                  message: 'No ${state.genre} movies found.',
                ),
                ListStatus.failure => AppError(
                  message: state.errorMessage ?? 'Could not load movies.',
                  onRetry: cubit.load,
                ),
                ListStatus.success => MovieGrid(
                  key: PageStorageKey(state.genre),
                  movies: state.movies,
                  onMovieTap: (movie) => AppRouter.openMovie(context, movie),
                  onLoadMore: cubit.loadMore,
                  isLoadingMore: state.isLoadingMore,
                  loadMoreError: state.loadMoreError,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal list of genre chips. The selected chip is filled yellow.
class GenreTabs extends StatefulWidget {
  const GenreTabs({
    super.key,
    required this.genres,
    required this.selected,
    required this.onSelected,
  });

  final List<String> genres;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<GenreTabs> createState() => _GenreTabsState();
}

class _GenreTabsState extends State<GenreTabs> {
  final _keys = <String, GlobalKey>{};

  @override
  void didUpdateWidget(covariant GenreTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      // Scroll the selected genre into view (e.g. after "See More").
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _keys[widget.selected]?.currentContext;
        if (context != null && context.mounted) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      scrollDirection: Axis.horizontal,
      itemCount: widget.genres.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final genre = widget.genres[index];
        final selected = genre == widget.selected;
        return InkWell(
          key: _keys.putIfAbsent(genre, GlobalKey.new),
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onSelected(genre),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Text(
              genre,
              style: AppTextStyles.titleMedium.copyWith(
                color: selected ? AppColors.black : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    ),
  );
}
