abstract final class AppConstants {
  static const appName = 'Movies App';

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

  static const homeGenres = ['Action', 'Adventure', 'Animation', 'Comedy'];

  static const searchDebounce = Duration(milliseconds: 500);
  static const historyLimit = 50;
}
