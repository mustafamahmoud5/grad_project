import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/helpers.dart';
import '../../../domain/entities/movie_page.dart';
import '../../models/movie_details_model.dart';
import '../../models/movie_model.dart';

abstract interface class MovieRemoteDataSource {
  Future<MoviePage> getMovies({
    int page = 1,
    int limit = ApiConstants.pageSize,
    MovieSort sortBy = MovieSort.dateAdded,
    String? genre,
    double? minimumRating,
    String? queryTerm,
  });

  Future<MovieDetailsModel> getMovieDetails(int movieId);

  Future<List<MovieModel>> getMovieSuggestions(int movieId);
}

class YtsMovieRemoteDataSource implements MovieRemoteDataSource {
  const YtsMovieRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<MoviePage> getMovies({
    int page = 1,
    int limit = ApiConstants.pageSize,
    MovieSort sortBy = MovieSort.dateAdded,
    String? genre,
    double? minimumRating,
    String? queryTerm,
  }) async {
    final json = await _client.get(
      ApiConstants.listMovies,
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy.apiValue,
        'order_by': 'desc',
        if (genre != null && genre.isNotEmpty) 'genre': genre,
        if (minimumRating != null) 'minimum_rating': minimumRating.floor(),
        if (queryTerm != null && queryTerm.trim().isNotEmpty)
          'query_term': queryTerm.trim(),
      },
    );
    return MoviePageModel.fromJson(_data(json), page: page);
  }

  @override
  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    final json = await _client.get(
      ApiConstants.movieDetails,
      queryParameters: {
        'movie_id': movieId,
        'with_images': true,
        'with_cast': true,
      },
    );
    final movie = Helpers.map(_data(json)['movie']);
    if (movie == null) throw const ParsingException();
    final details = MovieDetailsModel.fromJson(movie);
    // YTS answers unknown ids with an empty movie object.
    if (!details.isValid) throw const ServerException('Movie not found.');
    return details;
  }

  @override
  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    final json = await _client.get(
      ApiConstants.movieSuggestions,
      queryParameters: {'movie_id': movieId},
    );
    return Helpers.mapList(_data(json)['movies'])
        .map(MovieModel.fromJson)
        .where((movie) => movie.isValid && movie.id != movieId)
        .toList();
  }

  Map<String, dynamic> _data(Map<String, dynamic> json) {
    if (json['status'] != 'ok') {
      throw ServerException(
        Helpers.string(json['status_message'], 'The movie service failed.'),
      );
    }
    final data = Helpers.map(json['data']);
    if (data == null) throw const ParsingException();
    return data;
  }
}
