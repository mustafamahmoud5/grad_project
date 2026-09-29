import '../entities/movie.dart';

/// Movies the signed-in user opened, most recent first.
abstract interface class HistoryRepository {
  Stream<List<Movie>> watchHistory();

  Future<void> addToHistory(Movie movie);
}
