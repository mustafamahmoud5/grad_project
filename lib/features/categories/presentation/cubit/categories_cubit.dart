import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/state/paged_movies_state.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/movie_page.dart';
import '../../../../domain/repositories/movie_repository.dart';

class CategoriesState extends PagedMoviesState {
  const CategoriesState({
    this.genre = AppConstants.defaultGenre,
    super.status,
    super.movies,
    super.page,
    super.hasMore,
    super.isLoadingMore,
    super.errorMessage,
    super.loadMoreError,
  });

  factory CategoriesState.fromPaged(String genre, PagedMoviesState paged) =>
      CategoriesState(
        genre: genre,
        status: paged.status,
        movies: paged.movies,
        page: paged.page,
        hasMore: paged.hasMore,
        isLoadingMore: paged.isLoadingMore,
        errorMessage: paged.errorMessage,
        loadMoreError: paged.loadMoreError,
      );

  final String genre;

  @override
  List<Object?> get props => [genre, ...super.props];
}

/// Browse tab: movies of the selected genre, most downloaded first.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesState());

  final MovieRepository _repository;

  List<String> get genres => AppConstants.genres;

  void selectGenre(String genre) {
    if (genre == state.genre && state.status == ListStatus.success) return;
    _load(genre);
  }

  Future<void> load() => _load(state.genre);

  Future<void> _load(String genre) async {
    emit(CategoriesState(genre: genre, status: ListStatus.loading));
    final result = await _fetch(genre, 1);
    if (isClosed || state.genre != genre) return;
    switch (result) {
      case Success<MoviePage>(:final data):
        emit(
          CategoriesState(
            genre: genre,
            status: data.movies.isEmpty ? ListStatus.empty : ListStatus.success,
            movies: data.movies,
            page: data.page,
            hasMore: data.hasMore,
          ),
        );
      case Failed<MoviePage>(:final failure):
        emit(
          CategoriesState(
            genre: genre,
            status: ListStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (!current.hasMore || current.isLoadingMore) return;
    if (current.status != ListStatus.success) return;
    emit(
      CategoriesState.fromPaged(
        current.genre,
        current.copyWith(isLoadingMore: true, loadMoreError: () => null),
      ),
    );
    final result = await _fetch(current.genre, current.page + 1);
    if (isClosed || state.genre != current.genre) return;
    switch (result) {
      case Success<MoviePage>(:final data):
        final known = current.movies.map((movie) => movie.id).toSet();
        emit(
          CategoriesState.fromPaged(
            current.genre,
            current.copyWith(
              movies: [
                ...current.movies,
                ...data.movies.where((movie) => !known.contains(movie.id)),
              ],
              page: data.page,
              hasMore: data.hasMore,
              isLoadingMore: false,
              loadMoreError: () => null,
            ),
          ),
        );
      case Failed<MoviePage>(:final failure):
        emit(
          CategoriesState.fromPaged(
            current.genre,
            current.copyWith(
              isLoadingMore: false,
              loadMoreError: () => failure.message,
            ),
          ),
        );
    }
  }

  Future<Result<MoviePage>> _fetch(String genre, int page) => _repository
      .getMovies(page: page, genre: genre, sortBy: MovieSort.downloadCount);
}
