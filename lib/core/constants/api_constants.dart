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
