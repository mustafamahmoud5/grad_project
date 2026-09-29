abstract final class AppConstants {
  static const appName = 'Movies App';

  /// Genres supported by the YTS `genre` filter.
  static const genres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Musical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];

  static const defaultGenre = 'Action';

  /// Genre rows shown on the Home screen.
  static const homeGenres = ['Action', 'Adventure', 'Animation', 'Comedy'];

  static const searchDebounce = Duration(milliseconds: 500);
  static const historyLimit = 50;
}
