import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    initialRoute: AppRouter.splash,
    onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
    onGenerateRoute: AppRouter.onGenerateRoute,
  );
}
