import '../../core/constants/api_constants.dart';
import '../../core/utils/result.dart';
import '../entities/movie.dart';
import '../entities/movie_details.dart';
import '../entities/movie_page.dart';

abstract interface class MovieRepository {
  Future<Result<MoviePage>> getMovies({
    int page = 1,
    int limit,
    MovieSort sortBy = MovieSort.dateAdded,
    String? genre,
    double? minimumRating,
  });

  Future<Result<MoviePage>> searchMovies(String query, {int page = 1});

  Future<Result<MovieDetails>> getMovieDetails(int movieId);

  Future<Result<List<Movie>>> getMovieSuggestions(int movieId);
}
