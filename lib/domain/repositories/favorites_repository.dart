import '../../core/utils/result.dart';
import '../entities/movie.dart';

/// The signed-in user's watch list ("Wish List" in the design).
abstract interface class FavoritesRepository {
  Stream<List<Movie>> watchFavorites();

  Future<Result<bool>> isFavorite(int movieId);

  Future<Result<void>> addFavorite(Movie movie);

  Future<Result<void>> removeFavorite(int movieId);
}
