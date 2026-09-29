import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/state/paged_movies_state.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../cubit/search_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ResponsiveCenter(
              maxWidth: 700,
              child: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, child) => TextField(
                  controller: _controller,
                  onChanged: cubit.queryChanged,
                  onSubmitted: (_) => cubit.submit(),
                  textInputAction: TextInputAction.search,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search_rounded, size: 28),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _controller.clear();
                              cubit.clear();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => switch (state.status) {
                ListStatus.initial => const AppEmpty(),
                ListStatus.loading => const MovieGridSkeleton(),
                ListStatus.empty => AppEmpty(
                  message: 'No movies found for "${state.query}".',
                ),
                ListStatus.failure => AppError(
                  message: state.errorMessage ?? 'Search failed.',
                  onRetry: cubit.submit,
                ),
                ListStatus.success => MovieGrid(
                  movies: state.movies,
                  onMovieTap: (movie) => AppRouter.openMovie(context, movie),
                  onLoadMore: cubit.loadMore,
                  isLoadingMore: state.isLoadingMore,
                  loadMoreError: state.loadMoreError,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
