import 'package:equatable/equatable.dart';

import 'movie.dart';

class MoviePage extends Equatable {
  const MoviePage({
    required this.movies,
    required this.page,
    required this.totalCount,
    required this.limit,
  });

  final List<Movie> movies;
  final int page;
  final int totalCount;
  final int limit;

  bool get hasMore => movies.isNotEmpty && page * limit < totalCount;

  @override
  List<Object?> get props => [movies, page, totalCount, limit];
}
