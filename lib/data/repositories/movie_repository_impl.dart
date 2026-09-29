import '../../core/constants/api_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/entities/movie_page.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl({
    required MovieRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remote = remoteDataSource,
       _networkInfo = networkInfo;

  final MovieRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<MoviePage>> getMovies({
    int page = 1,
    int limit = ApiConstants.pageSize,
    MovieSort sortBy = MovieSort.dateAdded,
    String? genre,
    double? minimumRating,
  }) => _guard(
    () => _remote.getMovies(
      page: page,
      limit: limit,
      sortBy: sortBy,
      genre: genre,
      minimumRating: minimumRating,
    ),
  );

  @override
  Future<Result<MoviePage>> searchMovies(String query, {int page = 1}) =>
      _guard(
        () => _remote.getMovies(
          page: page,
          queryTerm: query,
          sortBy: MovieSort.downloadCount,
        ),
      );

  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) =>
      _guard(() => _remote.getMovieDetails(movieId));

  @override
  Future<Result<List<Movie>>> getMovieSuggestions(int movieId) =>
      _guard(() => _remote.getMovieSuggestions(movieId));

  Future<Result<T>> _guard<T>(Future<T> Function() request) async {
    if (!await _networkInfo.isConnected) {
      return const Failed(NetworkFailure());
    }
    try {
      return Success(await request());
    } catch (error) {
      return Failed(ErrorMapper.toFailure(error));
    }
  }
}
