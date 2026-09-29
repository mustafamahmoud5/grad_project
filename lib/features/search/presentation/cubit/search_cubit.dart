import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/state/paged_movies_state.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/movie_page.dart';
import '../../../../domain/repositories/movie_repository.dart';

class SearchState extends PagedMoviesState {
  const SearchState({
    this.query = '',
    super.status,
    super.movies,
    super.page,
    super.hasMore,
    super.isLoadingMore,
    super.errorMessage,
    super.loadMoreError,
  });

  factory SearchState.fromPaged(String query, PagedMoviesState paged) =>
      SearchState(
        query: query,
        status: paged.status,
        movies: paged.movies,
        page: paged.page,
        hasMore: paged.hasMore,
        isLoadingMore: paged.isLoadingMore,
        errorMessage: paged.errorMessage,
        loadMoreError: paged.loadMoreError,
      );

  final String query;

  @override
  List<Object?> get props => [query, ...super.props];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._repository, {
    Duration debounce = AppConstants.searchDebounce,
  }) : _debouncer = Debouncer(debounce),
       super(const SearchState());

  final MovieRepository _repository;
  final Debouncer _debouncer;

  void queryChanged(String value) {
    final query = value.trim();
    if (query == state.query && state.status != ListStatus.failure) return;
    if (query.isEmpty) {
      _debouncer.cancel();
      emit(const SearchState());
      return;
    }
    emit(SearchState(query: query, status: ListStatus.loading));
    _debouncer.run(() => _search(query));
  }

  void submit() {
    if (state.query.isEmpty) return;
    _debouncer.cancel();
    _search(state.query);
  }

  void clear() {
    _debouncer.cancel();
    emit(const SearchState());
  }

  Future<void> _search(String query) async {
    emit(SearchState(query: query, status: ListStatus.loading));
    final result = await _repository.searchMovies(query);

    if (isClosed || state.query != query) return;
    switch (result) {
      case Success<MoviePage>(:final data):
        emit(
          SearchState(
            query: query,
            status: data.movies.isEmpty ? ListStatus.empty : ListStatus.success,
            movies: data.movies,
            page: data.page,
            hasMore: data.hasMore,
          ),
        );
      case Failed<MoviePage>(:final failure):
        emit(
          SearchState(
            query: query,
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
      SearchState.fromPaged(
        current.query,
        current.copyWith(isLoadingMore: true, loadMoreError: () => null),
      ),
    );
    final result = await _repository.searchMovies(
      current.query,
      page: current.page + 1,
    );
    if (isClosed || state.query != current.query) return;
    switch (result) {
      case Success<MoviePage>(:final data):
        final known = current.movies.map((movie) => movie.id).toSet();
        emit(
          SearchState.fromPaged(
            current.query,
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
          SearchState.fromPaged(
            current.query,
            current.copyWith(
              isLoadingMore: false,
              loadMoreError: () => failure.message,
            ),
          ),
        );
    }
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
