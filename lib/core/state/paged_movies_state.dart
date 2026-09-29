import 'package:equatable/equatable.dart';

import '../../domain/entities/movie.dart';

enum ListStatus { initial, loading, success, empty, failure }

class PagedMoviesState extends Equatable {
  const PagedMoviesState({
    this.status = ListStatus.initial,
    this.movies = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final ListStatus status;
  final List<Movie> movies;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  final String? errorMessage;

  final String? loadMoreError;

  PagedMoviesState copyWith({
    ListStatus? status,
    List<Movie>? movies,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? Function()? errorMessage,
    String? Function()? loadMoreError,
  }) => PagedMoviesState(
    status: status ?? this.status,
    movies: movies ?? this.movies,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    loadMoreError: loadMoreError != null ? loadMoreError() : this.loadMoreError,
  );

  @override
  List<Object?> get props => [
    status,
    movies,
    page,
    hasMore,
    isLoadingMore,
    errorMessage,
    loadMoreError,
  ];
}
