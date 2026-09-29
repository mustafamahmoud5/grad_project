import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/cubit/search_cubit.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../widgets/app_bottom_navigation.dart';

enum MainTab { home, search, browse, profile }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialTab = MainTab.home});

  final MainTab initialTab;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MainTab _tab = widget.initialTab;
  late final Set<MainTab> _visited = {widget.initialTab};

  void _select(MainTab tab) => setState(() {
    _tab = tab;
    _visited.add(tab);
  });

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => HomeCubit(getIt())..load()),
      BlocProvider(create: (_) => SearchCubit(getIt())),
      BlocProvider(create: (_) => CategoriesCubit(getIt())..load()),
      BlocProvider(
        create: (_) => ProfileCubit(
          authRepository: getIt(),
          favoritesRepository: getIt(),
          historyRepository: getIt(),
        )..load(),
      ),
    ],
    child: Builder(
      builder: (context) => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _tab.index,
          children: [
            for (final tab in MainTab.values)
              _visited.contains(tab)
                  ? _buildTab(context, tab)
                  : const SizedBox(),
          ],
        ),
        bottomNavigationBar: AppBottomNavigation(
          selectedIndex: _tab.index,
          onSelected: (index) => _select(MainTab.values[index]),
        ),
      ),
    ),
  );

  Widget _buildTab(BuildContext context, MainTab tab) => switch (tab) {
    MainTab.home => HomeScreen(
      onSeeMore: (genre) {
        context.read<CategoriesCubit>().selectGenre(genre);
        _select(MainTab.browse);
      },
    ),
    MainTab.search => const SearchScreen(),
    MainTab.browse => const CategoriesScreen(),
    MainTab.profile => const ProfileScreen(),
  };
}
