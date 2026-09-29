import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/core/errors/failures.dart';
import 'package:grad_project/core/state/paged_movies_state.dart';
import 'package:grad_project/core/utils/result.dart';
import 'package:grad_project/data/datasources/local/local_data_source.dart';
import 'package:grad_project/data/repositories/onboarding_repository.dart';
import 'package:grad_project/domain/entities/movie.dart';
import 'package:grad_project/domain/entities/movie_details.dart';
import 'package:grad_project/domain/entities/movie_page.dart';
import 'package:grad_project/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:grad_project/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:grad_project/features/home/presentation/cubit/home_cubit.dart';
import 'package:grad_project/features/movie_details/presentation/cubit/movie_details_cubit.dart';
import 'package:grad_project/features/search/presentation/cubit/search_cubit.dart';
import 'package:grad_project/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:grad_project/features/splash/presentation/cubit/splash_state.dart';

import '../helpers/fakes.dart';

void main() {
  group('SearchCubit', () {
    late FakeMovieRepository repository;
    late SearchCubit cubit;

    setUp(() {
      repository = FakeMovieRepository()
        ..onSearch = (query, page) async => Success(
          MoviePage(
            movies: movies(20, start: page * 100),
            page: page,
            totalCount: 45,
            limit: 20,
          ),
        );
      cubit = SearchCubit(
        repository,
        debounce: const Duration(milliseconds: 300),
      );
    });

    tearDown(() => cubit.close());

    test('debounces keystrokes into a single request', () async {
      cubit
        ..queryChanged('b')
        ..queryChanged('ba')
        ..queryChanged('bat');
      expect(cubit.state.status, ListStatus.loading);
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(repository.searchCalls, [('bat', 1)]);
      expect(cubit.state.status, ListStatus.success);
      expect(cubit.state.movies, hasLength(20));
      expect(cubit.state.hasMore, isTrue);
    });

    test('clearing the field cancels the pending request', () async {
      cubit
        ..queryChanged('batman')
        ..queryChanged('');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(repository.searchCalls, isEmpty);
      expect(cubit.state.status, ListStatus.initial);
    });

    test('ignores a stale response for an old query', () async {
      final slow = Completer<Result<MoviePage>>();
      repository.onSearch = (query, page) => query == 'old'
          ? slow.future
          : Future.value(Success(page2(movies(1, start: 9))));

      cubit.queryChanged('old');
      cubit.submit();
      cubit.queryChanged('new');
      cubit.submit();
      await Future<void>.delayed(Duration.zero);
      slow.complete(Success(page2(movies(5))));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.query, 'new');
      expect(cubit.state.movies.single.id, 9);
    });

    test('shows the empty state when nothing matches', () async {
      repository.onSearch = (query, page) async => Success(page2(const []));
      cubit.queryChanged('zzzz');
      cubit.submit();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, ListStatus.empty);
    });

    test('loads the next page and keeps an inline error on failure', () async {
      cubit.queryChanged('bat');
      cubit.submit();
      await Future<void>.delayed(Duration.zero);

      await cubit.loadMore();
      expect(cubit.state.movies, hasLength(40));
      expect(cubit.state.page, 2);

      repository.onSearch = (query, page) async =>
          const Failed(NetworkFailure());
      await cubit.loadMore();
      expect(cubit.state.movies, hasLength(40));
      expect(cubit.state.loadMoreError, const NetworkFailure().message);
      expect(cubit.state.status, ListStatus.success);
    });
  });

  group('CategoriesCubit', () {
    test('loads the selected genre', () async {
      final requestedGenres = <String?>[];
      final repository = FakeMovieRepository()
        ..onGetMovies = (page, genre) async {
          requestedGenres.add(genre);
          return Success(page2(movies(3)));
        };
      final cubit = CategoriesCubit(repository);

      await cubit.load();
      cubit.selectGenre('Horror');
      await Future<void>.delayed(Duration.zero);

      expect(requestedGenres, ['Action', 'Horror']);
      expect(cubit.state.genre, 'Horror');
      expect(cubit.state.status, ListStatus.success);
      await cubit.close();
    });
  });

  group('HomeCubit', () {
    test('builds the carousel and genre sections', () async {
      final repository = FakeMovieRepository()
        ..onGetMovies = (page, genre) async => genre == 'Comedy'
            ? const Failed(ServerFailure())
            : Success(page2(movies(4)));
      final cubit = HomeCubit(repository);

      await cubit.load();

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.availableNow, hasLength(4));

      expect(cubit.state.sections.map((section) => section.genre), [
        'Action',
        'Adventure',
        'Animation',
      ]);
      cubit.selectMovie(2);
      expect(cubit.state.selectedMovie?.id, 3);
      await cubit.close();
    });

    test('fails with a friendly message when everything fails', () async {
      final repository = FakeMovieRepository()
        ..onGetMovies = (page, genre) async => const Failed(NetworkFailure());
      final cubit = HomeCubit(repository);

      await cubit.load();

      expect(cubit.state.status, HomeStatus.failure);
      expect(cubit.state.errorMessage, const NetworkFailure().message);
      await cubit.close();
    });
  });

  group('MovieDetailsCubit', () {
    const preview = Movie(id: 10, title: '13');
    const details = MovieDetails(id: 10, title: '13', likeCount: 5);

    late FakeMovieRepository movieRepository;
    late FakeFavoritesRepository favorites;
    late FakeHistoryRepository history;

    MovieDetailsCubit build() => MovieDetailsCubit(
      movie: preview,
      movieRepository: movieRepository,
      favoritesRepository: favorites,
      historyRepository: history,
    );

    setUp(() {
      movieRepository = FakeMovieRepository()
        ..detailsResult = const Success(details)
        ..suggestionsResult = Success(movies(4, start: 20));
      favorites = FakeFavoritesRepository();
      history = FakeHistoryRepository();
    });

    test('loads details, similar movies and records history', () async {
      favorites.favorites[10] = preview;
      final cubit = build();

      await cubit.load();

      expect(cubit.state.status, DetailsStatus.success);
      expect(cubit.state.details, details);
      expect(cubit.state.similar, hasLength(4));
      expect(cubit.state.isFavorite, isTrue);
      expect(history.added.single.id, 10);
      await cubit.close();
    });

    test('shows the error state when details fail', () async {
      movieRepository.detailsResult = const Failed(TimeoutFailure());
      final cubit = build();

      await cubit.load();

      expect(cubit.state.status, DetailsStatus.failure);
      expect(cubit.state.errorMessage, const TimeoutFailure().message);
      expect(history.added, isEmpty);
      await cubit.close();
    });

    test('toggles the watch list and rolls back on failure', () async {
      final cubit = build();
      await cubit.load();

      await cubit.toggleFavorite();
      expect(cubit.state.isFavorite, isTrue);
      expect(favorites.favorites, contains(10));

      favorites.nextWriteResult = const Failed(NetworkFailure());
      await cubit.toggleFavorite();
      expect(cubit.state.isFavorite, isTrue);
      expect(cubit.state.message, const NetworkFailure().message);
      await cubit.close();
    });
  });

  group('AuthCubit', () {
    test('emits loading then authenticated', () async {
      final cubit = AuthCubit(FakeAuthRepository());
      final states = cubit.stream.take(2).toList();

      await cubit.login(email: 'a@b.com', password: 'secret');

      expect((await states).map((state) => state.status), [
        AuthStatus.loading,
        AuthStatus.authenticated,
      ]);
      await cubit.close();
    });

    test('exposes the failure message', () async {
      final repository = FakeAuthRepository()
        ..loginResult = const Failed(
          AuthFailure('Email or password is incorrect.'),
        );
      final cubit = AuthCubit(repository);

      await cubit.login(email: 'a@b.com', password: 'bad');

      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.message, 'Email or password is incorrect.');
      await cubit.close();
    });
  });

  group('SplashCubit', () {
    Future<SplashDestination> destination({
      required bool onboarded,
      String? userId,
    }) async {
      final storage = InMemoryStorage();
      final onboarding = OnboardingRepository(LocalDataSourceImpl(storage));
      if (onboarded) await onboarding.complete();
      var firebaseInitialized = 0;
      final cubit = SplashCubit(
        authRepository: FakeAuthRepository(userId: userId),
        onboardingRepository: onboarding,
        initializeFirebase: () async {
          firebaseInitialized++;
          return true;
        },
        minimumDuration: Duration.zero,
      );
      await cubit.start();
      expect(firebaseInitialized, 1);
      final state = cubit.state as SplashFinished;
      await cubit.close();
      return state.destination;
    }

    test('first launch goes to onboarding', () async {
      expect(await destination(onboarded: false), SplashDestination.onboarding);
    });

    test('signed out user goes to login', () async {
      expect(await destination(onboarded: true), SplashDestination.login);
    });

    test('signed in user goes straight home', () async {
      expect(
        await destination(onboarded: true, userId: 'u1'),
        SplashDestination.home,
      );
    });
  });
}

MoviePage page2(List<Movie> items) =>
    MoviePage(movies: items, page: 1, totalCount: items.length, limit: 20);
