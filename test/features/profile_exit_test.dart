import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/app/router/app_router.dart';
import 'package:grad_project/app/theme/app_theme.dart';
import 'package:grad_project/core/widgets/app_network_image.dart';
import 'package:grad_project/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:grad_project/features/profile/presentation/screens/profile_screen.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(() => AppNetworkImage.useDiskCache = false);

  Future<FakeAuthRepository> pumpProfile(WidgetTester tester) async {
    final auth = FakeAuthRepository(userId: 'u1');
    final favorites = FakeFavoritesRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => switch (settings.name) {
            AppRouter.login => const Scaffold(body: Text('Login page')),
            AppRouter.register => Scaffold(
              appBar: AppBar(),
              body: const Text('Register page'),
            ),
            _ => Scaffold(
              body: BlocProvider(
                create: (_) => ProfileCubit(
                  authRepository: auth,
                  favoritesRepository: favorites,
                  historyRepository: FakeHistoryRepository(),
                )..load(),
                child: const ProfileScreen(),
              ),
            ),
          },
        ),
      ),
    );
    await tester.pump();

    favorites.emitFavorites();
    await tester.pump();
    return auth;
  }

  testWidgets('Exit asks for confirmation and Cancel keeps the user in', (
    tester,
  ) async {
    final auth = await pumpProfile(tester);

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsNothing);
    expect(auth.loggedOut, isFalse);
    expect(find.text('Login page'), findsNothing);
    expect(find.text('Register page'), findsNothing);
  });

  testWidgets('confirming Exit logs out and opens Login', (tester) async {
    final auth = await pumpProfile(tester);

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Exit'));
    await tester.pumpAndSettle();

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(auth.loggedOut, isTrue);
    expect(find.text('Login page'), findsOneWidget);
    expect(find.text('Register page'), findsNothing);
  });
}
