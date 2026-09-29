import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/app/theme/app_theme.dart';
import 'package:grad_project/core/errors/failures.dart';
import 'package:grad_project/core/utils/result.dart';
import 'package:grad_project/core/widgets/app_error.dart';
import 'package:grad_project/core/widgets/app_network_image.dart';
import 'package:grad_project/core/widgets/movie_poster_card.dart';
import 'package:grad_project/domain/entities/movie.dart';
import 'package:grad_project/domain/entities/movie_details.dart';
import 'package:grad_project/domain/entities/movie_page.dart';
import 'package:grad_project/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:grad_project/features/auth/presentation/screens/login_screen.dart';
import 'package:grad_project/features/movie_details/presentation/cubit/movie_details_cubit.dart';
import 'package:grad_project/features/movie_details/presentation/screens/movie_details_screen.dart';
import 'package:grad_project/features/search/presentation/cubit/search_cubit.dart';
import 'package:grad_project/features/search/presentation/screens/search_screen.dart';

import '../helpers/fakes.dart';

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.darkTheme,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() => AppNetworkImage.useDiskCache = false);

  group('LoginView', () {
    testWidgets('validates the form before calling Firebase', (tester) async {
      final repository = FakeAuthRepository();
      await tester.pumpWidget(
        _app(
          BlocProvider(
            create: (_) => AuthCubit(repository),
            child: const LoginView(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(repository.loginCalls, isEmpty);
    });

    testWidgets('submits valid credentials', (tester) async {
      final repository = FakeAuthRepository()
        ..loginResult = const Failed(_WrongPassword());
      await tester.pumpWidget(
        _app(
          BlocProvider(
            create: (_) => AuthCubit(repository),
            child: const LoginView(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'me@mail.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(repository.loginCalls, [('me@mail.com', 'secret1')]);

      expect(find.text('Email or password is incorrect.'), findsOneWidget);
    });
  });

  testWidgets('MoviePosterCard shows the rating and handles taps', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _app(
        Center(
          child: MoviePosterCard(
            width: 150,
            movie: const Movie(id: 1, title: 'Dune', rating: 8.04),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('8.0'), findsOneWidget);
    expect(tester.getSize(find.byType(MoviePosterCard)), const Size(150, 225));
    await tester.tap(find.byType(MoviePosterCard));
    expect(tapped, isTrue);
  });

  testWidgets('AppError shows the message and retries', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      _app(AppError(message: 'No internet', onRetry: () => retried++)),
    );

    expect(find.text('No internet'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });

  testWidgets('SearchScreen searches after typing and shows results', (
    tester,
  ) async {
    final repository = FakeMovieRepository()
      ..onSearch = (query, page) async => Success(
        MoviePage(
          movies: query == 'dune'
              ? const [Movie(id: 1, title: 'Dune', rating: 8)]
              : const [],
          page: 1,
          totalCount: 1,
          limit: 20,
        ),
      );
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => SearchCubit(
            repository,
            debounce: const Duration(milliseconds: 50),
          ),
          child: const SearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.byType(MoviePosterCard), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nothing');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('No movies found for "nothing".'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.byType(MoviePosterCard), findsNothing);
    expect(repository.searchCalls, [('dune', 1), ('nothing', 1)]);
  });

  testWidgets('MovieDetailsView renders the real movie sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final repository = FakeMovieRepository()
      ..detailsResult = const Success(
        MovieDetails(
          id: 10,
          title: '13',
          year: 2010,
          rating: 6,
          runtime: 91,
          likeCount: 79,
          genres: ['Action', 'Crime'],
          description: 'A desperate man takes part in Russian roulette.',
          trailerCode: 'abc',
          cast: [CastMember(name: 'Jason Statham', characterName: 'Jasper')],
        ),
      )
      ..suggestionsResult = const Success([Movie(id: 11, title: 'Chaos')]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider(
          create: (_) => MovieDetailsCubit(
            movie: const Movie(id: 10, title: '13'),
            movieRepository: repository,
            favoritesRepository: FakeFavoritesRepository(),
            historyRepository: FakeHistoryRepository(),
          )..load(),
          child: const MovieDetailsView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('2010'), findsOneWidget);
    expect(find.text('79'), findsOneWidget);
    expect(find.text('1h 31m'), findsOneWidget);
    expect(find.text('Similar'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Name : Jason Statham'), findsOneWidget);
    expect(find.text('Crime'), findsOneWidget);
    expect(find.bySemanticsLabel('Play trailer'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to watch list'));
    await tester.pump();
    expect(find.byTooltip('Remove from watch list'), findsOneWidget);
  });
}

class _WrongPassword extends AuthFailure {
  const _WrongPassword() : super('Email or password is incorrect.');
}
