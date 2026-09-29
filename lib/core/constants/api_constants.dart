/// YTS API configuration.
///
/// `https://yts.lt/api/v2/` now answers with a 301 redirect (without CORS
/// headers, which breaks Flutter Web). The API itself announces
/// `movies-api.accel.li` as its new official base URL in every response, so
/// the app talks to it directly. It serves the exact same YTS v2 API.
abstract final class ApiConstants {
  static const baseUrl = 'https://movies-api.accel.li/api/v2/';

  static const listMovies = 'list_movies.json';
  static const movieDetails = 'movie_details.json';
  static const movieSuggestions = 'movie_suggestions.json';

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  static const pageSize = 20;

  static const youtubeWatchUrl = 'https://www.youtube.com/watch?v=';
}

/// Values accepted by the `sort_by` query parameter of `list_movies.json`.
enum MovieSort {
  dateAdded('date_added'),
  downloadCount('download_count'),
  likeCount('like_count'),
  rating('rating'),
  year('year'),
  title('title');

  const MovieSort(this.apiValue);

  final String apiValue;
}
