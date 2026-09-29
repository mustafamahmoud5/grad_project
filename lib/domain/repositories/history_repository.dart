import '../entities/movie.dart';

abstract interface class HistoryRepository {
  Stream<List<Movie>> watchHistory();

  Future<void> addToHistory(Movie movie);
}
