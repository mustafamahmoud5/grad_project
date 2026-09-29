import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/core/constants/api_constants.dart';
import 'package:grad_project/core/errors/exceptions.dart';
import 'package:grad_project/data/datasources/remote/movie_remote_data_source.dart';

import '../helpers/fakes.dart';
import '../helpers/fixtures.dart';

void main() {
  test('getMovies sends the YTS query and parses the page', () async {
    final client = FakeApiClient(
      (path, query) async => listResponse(movies: [movieJson()]),
    );
    final source = YtsMovieRemoteDataSource(client);

    final page = await source.getMovies(
      page: 2,
      genre: 'Action',
      sortBy: MovieSort.downloadCount,
      queryTerm: '  batman ',
    );

    expect(page.movies.single.title, '13');
    final (path, query) = client.calls.single;
    expect(path, ApiConstants.listMovies);
    expect(query, containsPair('page', 2));
    expect(query, containsPair('genre', 'Action'));
    expect(query, containsPair('sort_by', 'download_count'));
    expect(query, containsPair('query_term', 'batman'));
  });

  test('omits empty filters', () async {
    final client = FakeApiClient((path, query) async => listResponse());
    await YtsMovieRemoteDataSource(client).getMovies(queryTerm: '   ');

    final query = client.calls.single.$2!;
    expect(query.containsKey('genre'), isFalse);
    expect(query.containsKey('query_term'), isFalse);
  });

  test('throws ServerException when the API status is not ok', () {
    final client = FakeApiClient(
      (path, query) async => {'status': 'error', 'status_message': 'Bad'},
    );

    expect(
      YtsMovieRemoteDataSource(client).getMovies(),
      throwsA(isA<ServerException>()),
    );
  });

  test('throws ParsingException when data is missing', () {
    final client = FakeApiClient((path, query) async => {'status': 'ok'});

    expect(
      YtsMovieRemoteDataSource(client).getMovies(),
      throwsA(isA<ParsingException>()),
    );
  });

  test('getMovieDetails requests images and cast', () async {
    final client = FakeApiClient(
      (path, query) async => {
        'status': 'ok',
        'data': {'movie': detailsJson()},
      },
    );

    final details = await YtsMovieRemoteDataSource(client).getMovieDetails(10);

    expect(details.cast, isNotEmpty);
    expect(client.calls.single.$2, {
      'movie_id': 10,
      'with_images': true,
      'with_cast': true,
    });
  });

  test('getMovieDetails treats an empty movie as not found', () {
    final client = FakeApiClient(
      (path, query) async => {
        'status': 'ok',
        'data': {
          'movie': {'id': 0, 'title': ''},
        },
      },
    );

    expect(
      YtsMovieRemoteDataSource(client).getMovieDetails(999999),
      throwsA(isA<ServerException>()),
    );
  });

  test('getMovieSuggestions excludes the movie itself', () async {
    final client = FakeApiClient(
      (path, query) async =>
          listResponse(movies: [movieJson(id: 10), movieJson(id: 11)]),
    );

    final similar = await YtsMovieRemoteDataSource(
      client,
    ).getMovieSuggestions(10);

    expect(similar.map((movie) => movie.id), [11]);
  });
}
