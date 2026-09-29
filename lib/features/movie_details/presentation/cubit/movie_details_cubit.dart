import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../domain/entities/movie_details.dart';
import '../../../../domain/repositories/favorites_repository.dart';
import '../../../../domain/repositories/history_repository.dart';
import '../../../../domain/repositories/movie_repository.dart';

enum DetailsStatus { loading, success, failure }

class MovieDetailsState extends Equatable {
  const MovieDetailsState({
    required this.preview,
    this.status = DetailsStatus.loading,
    this.details,
    this.similar = const [],
    this.isFavorite = false,
    this.isFavoriteBusy = false,
    this.errorMessage,
    this.message,
  });

  final Movie preview;
  final DetailsStatus status;
  final MovieDetails? details;
  final List<Movie> similar;
  final bool isFavorite;
  final bool isFavoriteBusy;
  final String? errorMessage;

  final String? message;

  Movie get movie => details ?? preview;

  MovieDetailsState copyWith({
    DetailsStatus? status,
    MovieDetails? details,
    List<Movie>? similar,
    bool? isFavorite,
    bool? isFavoriteBusy,
    String? errorMessage,
    String? message,
  }) => MovieDetailsState(
    preview: preview,
    status: status ?? this.status,
    details: details ?? this.details,
    similar: similar ?? this.similar,
    isFavorite: isFavorite ?? this.isFavorite,
    isFavoriteBusy: isFavoriteBusy ?? this.isFavoriteBusy,
    errorMessage: errorMessage ?? this.errorMessage,
    message: message,
  );

  @override
  List<Object?> get props => [
    preview,
    status,
    details,
    similar,
    isFavorite,
    isFavoriteBusy,
    errorMessage,
    message,
  ];
}

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit({
    required Movie movie,
    required MovieRepository movieRepository,
    required FavoritesRepository favoritesRepository,
    required HistoryRepository historyRepository,
  }) : _movies = movieRepository,
       _favorites = favoritesRepository,
       _history = historyRepository,
       super(MovieDetailsState(preview: movie));

  final MovieRepository _movies;
  final FavoritesRepository _favorites;
  final HistoryRepository _history;

  int get _id => state.preview.id;

  Future<void> load() async {
    emit(
      MovieDetailsState(preview: state.preview, isFavorite: state.isFavorite),
    );
    final detailsRequest = _movies.getMovieDetails(_id);
    final similarRequest = _movies.getMovieSuggestions(_id);
    final favoriteRequest = _favorites.isFavorite(_id);

    final details = await detailsRequest;
    if (isClosed) return;
    switch (details) {
      case Failed<MovieDetails>(:final failure):
        emit(
          state.copyWith(
            status: DetailsStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return;
      case Success<MovieDetails>(:final data):
        emit(state.copyWith(status: DetailsStatus.success, details: data));
        await _history.addToHistory(data);
    }

    final similar = await similarRequest;
    final favorite = await favoriteRequest;
    if (isClosed) return;
    emit(
      state.copyWith(
        similar: similar is Success<List<Movie>> ? similar.data : const [],
        isFavorite: favorite is Success<bool> ? favorite.data : null,
      ),
    );
  }

  Future<void> toggleFavorite() async {
    if (state.isFavoriteBusy) return;
    final wasFavorite = state.isFavorite;

    emit(state.copyWith(isFavorite: !wasFavorite, isFavoriteBusy: true));
    final result = wasFavorite
        ? await _favorites.removeFavorite(_id)
        : await _favorites.addFavorite(state.movie);
    if (isClosed) return;
    emit(
      result.when(
        success: (_) => state.copyWith(
          isFavoriteBusy: false,
          message: wasFavorite
              ? 'Removed from your watch list'
              : 'Added to your watch list',
        ),
        failure: (failure) => state.copyWith(
          isFavorite: wasFavorite,
          isFavoriteBusy: false,
          message: failure.message,
        ),
      ),
    );
  }
}
