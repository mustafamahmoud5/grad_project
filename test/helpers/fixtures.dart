/// JSON fixtures mirroring real YTS API v2 responses.
Map<String, dynamic> movieJson({
  int id = 10,
  String title = '13',
  double rating = 6,
}) => {
  'id': id,
  'url': 'https://yts.gg/movies/13-2010',
  'imdb_code': 'tt0798817',
  'title': title,
  'title_english': title,
  'title_long': '$title (2010)',
  'year': 2010,
  'rating': rating,
  'runtime': 91,
  'genres': ['Action', 'Crime', 'Drama', 'Thriller'],
  'summary': 'A desperate man takes part in an underworld game.',
  'yt_trailer_code': 'Y41fFj-P4jI',
  'background_image':
      'https://yts.gg/assets/images/movies/13_2010/background.jpg',
  'medium_cover_image':
      'https://yts.gg/assets/images/movies/13_2010/medium-cover.jpg',
  'large_cover_image':
      'https://yts.gg/assets/images/movies/13_2010/large-cover.jpg',
};

Map<String, dynamic> listResponse({
  List<Map<String, dynamic>>? movies,
  int movieCount = 45,
  int page = 1,
  int limit = 20,
}) => {
  'status': 'ok',
  'status_message': 'Query was successful',
  'data': {
    'movie_count': movieCount,
    'limit': limit,
    'page_number': page,
    'movies': ?movies,
  },
};

Map<String, dynamic> detailsJson() => {
  ...movieJson(),
  'like_count': 79,
  'description_intro': 'A desperate man takes part in Russian roulette.',
  'description_full':
      'A desperate man takes part in an underworld game of '
      'Russian roulette.',
  'mpa_rating': 'R',
  'language': 'en',
  'medium_screenshot_image1':
      'https://yts.gg/assets/images/movies/13_2010/medium-screenshot1.jpg',
  'medium_screenshot_image2':
      'https://yts.gg/assets/images/movies/13_2010/medium-screenshot2.jpg',
  'large_screenshot_image1':
      'https://yts.gg/assets/images/movies/13_2010/large-screenshot1.jpg',
  'cast': [
    {
      'name': 'Jason Statham',
      'character_name': 'Jasper',
      'url_small_image':
          'https://yts.gg/assets/images/actors/thumb/nm0005458.jpg',
      'imdb_code': '0005458',
    },
    {'name': '', 'character_name': 'Nobody'},
  ],
};
