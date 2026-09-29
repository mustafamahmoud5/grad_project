import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../domain/entities/user.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final updated = await Navigator.of(
      context,
    ).pushNamed(AppRouter.editProfile);
    if (updated is AppUser) {
      cubit.updateUser(updated);
    } else {
      await cubit.refreshUser();
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.logout();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ProfileStatus.loggedOut) {
            AppRouter.goToLogin(context);
          }
        },
        builder: (context, state) {
          final bottom = MediaQuery.paddingOf(context).bottom + 16;
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _ProfileHeader(
                  state: state,
                  onEdit: () => _editProfile(context),
                  onExit: () => _confirmExit(context),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _MoviesTab(
                        movies: state.watchlist,
                        isLoading: state.isWatchlistLoading,
                        error: state.watchlistError,
                        emptyMessage: 'Movies you bookmark will appear here.',
                        bottomPadding: bottom,
                      ),
                      _MoviesTab(
                        movies: state.history,
                        emptyMessage: 'Movies you open will appear here.',
                        bottomPadding: bottom,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.state,
    required this.onEdit,
    required this.onExit,
  });

  final ProfileState state;
  final VoidCallback onEdit;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.surfaceLight.withValues(alpha: 0.6),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        UserAvatar(user: state.user, size: 110),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 130,
                          child: Text(
                            state.status == ProfileStatus.loading
                                ? ''
                                : state.user?.displayName ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        value: state.watchlist.length,
                        label: 'Wish List',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        value: state.history.length,
                        label: 'History',
                      ),
                    ),
                  ],
                ),
                if (state.status == ProfileStatus.failure &&
                    state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppButton(
                        label: 'Edit Profile',
                        onPressed: onEdit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Exit',
                        variant: AppButtonVariant.danger,
                        icon: const Icon(Icons.logout_rounded),
                        onPressed: onExit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppColors.transparent,
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.white,
                  labelStyle: AppTextStyles.titleMedium,
                  unselectedLabelStyle: AppTextStyles.titleMedium,
                  tabs: [
                    Tab(
                      height: 72,
                      icon: Icon(
                        Icons.format_list_bulleted_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      text: 'Watch List',
                    ),
                    Tab(
                      height: 72,
                      icon: Icon(
                        Icons.folder_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      text: 'History',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: AppTextStyles.headlineLarge.copyWith(fontSize: 36)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: AppTextStyles.headlineSmall),
      ),
    ],
  );
}

class _MoviesTab extends StatelessWidget {
  const _MoviesTab({
    required this.movies,
    required this.emptyMessage,
    required this.bottomPadding,
    this.isLoading = false,
    this.error,
  });

  final List<Movie> movies;
  final String emptyMessage;
  final double bottomPadding;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoading && movies.isEmpty) return const AppLoading();
    if (error != null && movies.isEmpty) {
      return AppError(message: error!, icon: Icons.cloud_off_rounded);
    }
    if (movies.isEmpty) return AppEmpty(message: emptyMessage);
    return MovieGrid(
      movies: movies,
      maxPosterWidth: 150,
      onMovieTap: (movie) => AppRouter.openMovie(context, movie),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
    );
  }
}
