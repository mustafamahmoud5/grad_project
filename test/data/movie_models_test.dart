import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/data/models/movie_details_model.dart';
import 'package:grad_project/data/models/movie_model.dart';

import '../helpers/fixtures.dart';

void main() {
  group('MovieModel.fromJson', () {
    test('parses a YTS movie', () {
      final movie = MovieModel.fromJson(movieJson());

      expect(movie.id, 10);
      expect(movie.title, '13');
      expect(movie.year, 2010);
      expect(movie.rating, 6.0);
      expect(movie.runtime, 91);
      expect(movie.genres, ['Action', 'Crime', 'Drama', 'Thriller']);
      expect(movie.posterUrl, endsWith('medium-cover.jpg'));
      expect(movie.largePosterUrl, endsWith('large-cover.jpg'));
      expect(movie.url, 'https://yts.gg/movies/13-2010');
      expect(movie.isValid, isTrue);
    });

    test('never throws on missing or malformed fields', () {
      final movie = MovieModel.fromJson({
        'id': '42',
        'title': 'Only title',
        'rating': 'not a number',
        'runtime': null,
        'genres': 'Action',
        'medium_cover_image': '',
        'large_cover_image': 'not a url',
      });

      expect(movie.id, 42);
      expect(movie.rating, 0);
      expect(movie.runtime, 0);
      expect(movie.genres, isEmpty);
      expect(movie.posterUrl, isNull);
      expect(movie.largePosterUrl, isNull);
      expect(movie.heroImageUrl, isNull);
    });

    test('is invalid without id or title', () {
      expect(MovieModel.fromJson(const {}).isValid, isFalse);
      expect(MovieModel.fromJson(const {'id': 5}).isValid, isFalse);
    });

    test('round-trips through toJson (watch list / history storage)', () {
      final original = MovieModel.fromJson(movieJson());
      final restored = MovieModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.rating, original.rating);
      expect(restored.posterUrl, original.posterUrl);
      expect(restored.genres, original.genres);
    });
  });

  group('MoviePageModel.fromJson', () {
    test('parses pagination and drops invalid movies', () {
      final page = MoviePageModel.fromJson(
        listResponse(
              movies: [
                movieJson(id: 1),
                movieJson(id: 2),
                {'title': 'no id'},
              ],
              movieCount: 45,
              page: 2,
            )['data']
            as Map<String, dynamic>,
        page: 2,
      );

      expect(page.movies.map((movie) => movie.id), [1, 2]);
      expect(page.page, 2);
      expect(page.totalCount, 45);
      expect(page.hasMore, isTrue);
    });

    test('handles an empty result without a movies key', () {
      final page = MoviePageModel.fromJson(
        listResponse(movieCount: 0)['data'] as Map<String, dynamic>,
        page: 1,
      );

      expect(page.movies, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('reports no more pages on the last page', () {
      final page = MoviePageModel.fromJson(
        listResponse(movies: [movieJson()], movieCount: 41, page: 3)['data']
            as Map<String, dynamic>,
        page: 3,
      );

      expect(page.hasMore, isFalse);
    });
  });

  group('MovieDetailsModel.fromJson', () {
    test('parses details, screenshots and cast', () {
      final details = MovieDetailsModel.fromJson(detailsJson());

      expect(details.likeCount, 79);
      expect(details.trailerCode, 'Y41fFj-P4jI');
      expect(details.overview, contains('Russian roulette'));
      expect(details.screenshots, hasLength(2));
      // Large screenshots are preferred over medium ones.
      expect(details.screenshots.first, endsWith('large-screenshot1.jpg'));
      // Cast members without a name are dropped.
      expect(details.cast, hasLength(1));
      expect(details.cast.single.name, 'Jason Statham');
      expect(details.cast.single.characterName, 'Jasper');
    });

    test('uses the summary when there is no full description', () {
      final details = MovieDetailsModel.fromJson({
        ...movieJson(),
        'description_full': '',
        'description_intro': 'Short intro',
      });

      expect(details.overview, 'Short intro');
    });
  });
}
