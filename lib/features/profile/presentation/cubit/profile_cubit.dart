import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/repositories/favorites_repository.dart';
import '../../../../domain/repositories/history_repository.dart';

enum ProfileStatus { loading, success, failure, loggedOut }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.watchlist = const [],
    this.history = const [],
    this.isWatchlistLoading = true,
    this.watchlistError,
    this.errorMessage,
  });

  final ProfileStatus status;
  final AppUser? user;
  final List<Movie> watchlist;
  final List<Movie> history;
  final bool isWatchlistLoading;
  final String? watchlistError;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    AppUser? user,
    List<Movie>? watchlist,
    List<Movie>? history,
    bool? isWatchlistLoading,
    String? Function()? watchlistError,
    String? errorMessage,
  }) => ProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    watchlist: watchlist ?? this.watchlist,
    history: history ?? this.history,
    isWatchlistLoading: isWatchlistLoading ?? this.isWatchlistLoading,
    watchlistError: watchlistError != null
        ? watchlistError()
        : this.watchlistError,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    user,
    watchlist,
    history,
    isWatchlistLoading,
    watchlistError,
    errorMessage,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthRepository authRepository,
    required FavoritesRepository favoritesRepository,
    required HistoryRepository historyRepository,
  }) : _auth = authRepository,
       _favorites = favoritesRepository,
       _history = historyRepository,
       super(const ProfileState());

  final AuthRepository _auth;
  final FavoritesRepository _favorites;
  final HistoryRepository _history;

  StreamSubscription<List<Movie>>? _watchlistSubscription;
  StreamSubscription<List<Movie>>? _historySubscription;

  Future<void> load() async {
    _listen();
    await refreshUser();
  }

  Future<void> refreshUser() async {
    final result = await _auth.getCurrentUser();
    if (isClosed) return;
    emit(
      result.when(
        success: (user) =>
            state.copyWith(status: ProfileStatus.success, user: user),
        failure: (failure) => state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void updateUser(AppUser user) =>
      emit(state.copyWith(status: ProfileStatus.success, user: user));

  void _listen() {
    _watchlistSubscription?.cancel();
    _historySubscription?.cancel();
    _watchlistSubscription = _favorites.watchFavorites().listen(
      (movies) => emit(
        state.copyWith(
          watchlist: movies,
          isWatchlistLoading: false,
          watchlistError: () => null,
        ),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          isWatchlistLoading: false,
          watchlistError: () => ErrorMapper.toFailure(error).message,
        ),
      ),
    );
    _historySubscription = _history.watchHistory().listen(
      (movies) => emit(state.copyWith(history: movies)),
    );
  }

  Future<void> logout() async {
    await _watchlistSubscription?.cancel();
    await _historySubscription?.cancel();
    await _auth.logout();
    if (!isClosed) emit(state.copyWith(status: ProfileStatus.loggedOut));
  }

  @override
  Future<void> close() async {
    await _watchlistSubscription?.cancel();
    await _historySubscription?.cancel();
    return super.close();
  }
}
