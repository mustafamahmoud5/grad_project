import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/core/errors/exceptions.dart';
import 'package:grad_project/core/errors/failures.dart';
import 'package:grad_project/core/utils/result.dart';
import 'package:grad_project/data/datasources/local/local_data_source.dart';
import 'package:grad_project/data/datasources/remote/movie_remote_data_source.dart';
import 'package:grad_project/data/repositories/history_repository_impl.dart';
import 'package:grad_project/data/repositories/movie_repository_impl.dart';
import 'package:grad_project/data/repositories/onboarding_repository.dart';
import 'package:grad_project/domain/entities/movie.dart';
import 'package:grad_project/domain/entities/movie_page.dart';

import '../helpers/fakes.dart';
import '../helpers/fixtures.dart';

void main() {
  group('MovieRepositoryImpl', () {
    late FakeNetworkInfo network;
    late FakeApiClient client;
    late MovieRepositoryImpl repository;

    setUp(() {
      network = FakeNetworkInfo();
      client = FakeApiClient(
        (path, query) async => listResponse(movies: [movieJson()]),
      );
      repository = MovieRepositoryImpl(
        remoteDataSource: YtsMovieRemoteDataSource(client),
        networkInfo: network,
      );
    });

    test('returns movies on success', () async {
      final result = await repository.getMovies();

      expect(result, isA<Success<MoviePage>>());
      expect((result as Success<MoviePage>).data.movies.single.id, 10);
    });

    test(
      'returns NetworkFailure without calling the API when offline',
      () async {
        network.connected = false;

        final result = await repository.getMovies();

        expect((result as Failed).failure, isA<NetworkFailure>());
        expect(client.calls, isEmpty);
      },
    );

    test('converts exceptions into user-friendly failures', () async {
      client.handler = (path, query) async => throw const TimeoutException();
      expect(
        ((await repository.getMovies()) as Failed).failure,
        isA<TimeoutFailure>(),
      );

      client.handler = (path, query) async => throw const ParsingException();
      expect(
        ((await repository.getMovies()) as Failed).failure,
        isA<InvalidDataFailure>(),
      );

      client.handler = (path, query) async => throw StateError('unexpected');
      final failure = ((await repository.getMovies()) as Failed).failure;
      expect(failure, isA<UnknownFailure>());
      expect(failure.message, isNot(contains('StateError')));
    });

    test('searchMovies sends the query term', () async {
      await repository.searchMovies('batman', page: 3);

      expect(client.calls.single.$2, containsPair('query_term', 'batman'));
      expect(client.calls.single.$2, containsPair('page', 3));
    });
  });

  group('HistoryRepositoryImpl', () {
    late FakeAuthRepository auth;
    late HistoryRepositoryImpl repository;

    setUp(() {
      auth = FakeAuthRepository(userId: 'user-1');
      repository = HistoryRepositoryImpl(
        localDataSource: LocalDataSourceImpl(InMemoryStorage()),
        authRepository: auth,
      );
    });

    test('keeps the most recent movie first without duplicates', () async {
      await repository.addToHistory(const Movie(id: 1, title: 'One'));
      await repository.addToHistory(const Movie(id: 2, title: 'Two'));
      await repository.addToHistory(const Movie(id: 1, title: 'One'));

      final history = await repository.watchHistory().first;
      expect(history.map((movie) => movie.id), [1, 2]);
    });

    test('keeps history per user', () async {
      await repository.addToHistory(const Movie(id: 1, title: 'One'));
      auth.userId = 'user-2';

      expect(await repository.watchHistory().first, isEmpty);
    });

    test('emits updates to listeners', () async {
      final updates = repository.watchHistory().take(2).toList();
      await Future<void>.delayed(Duration.zero);
      await repository.addToHistory(const Movie(id: 7, title: 'Seven'));

      final emitted = await updates;
      expect(emitted.last.single.id, 7);
    });

    test('ignores history when signed out', () async {
      auth.userId = null;
      await repository.addToHistory(const Movie(id: 1, title: 'One'));

      expect(await repository.watchHistory().first, isEmpty);
    });
  });

  test('OnboardingRepository persists completion', () async {
    final storage = InMemoryStorage();
    final repository = OnboardingRepository(LocalDataSourceImpl(storage));

    expect(repository.isCompleted, isFalse);
    await repository.complete();
    expect(
      OnboardingRepository(LocalDataSourceImpl(storage)).isCompleted,
      isTrue,
    );
  });
}
