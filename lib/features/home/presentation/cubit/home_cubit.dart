import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../domain/entities/movie_page.dart';
import '../../../../domain/repositories/movie_repository.dart';

enum HomeStatus { loading, success, failure }

class HomeSection extends Equatable {
  const HomeSection({required this.genre, required this.movies});

  final String genre;
  final List<Movie> movies;

  @override
  List<Object?> get props => [genre, movies];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.availableNow = const [],
    this.sections = const [],
    this.selectedIndex = 0,
    this.errorMessage,
  });

  final HomeStatus status;

  final List<Movie> availableNow;

  final List<HomeSection> sections;

  final int selectedIndex;
  final String? errorMessage;

  Movie? get selectedMovie =>
      availableNow.isEmpty ? null : availableNow[selectedIndex];

  HomeState copyWith({
    HomeStatus? status,
    List<Movie>? availableNow,
    List<HomeSection>? sections,
    int? selectedIndex,
    String? errorMessage,
  }) => HomeState(
    status: status ?? this.status,
    availableNow: availableNow ?? this.availableNow,
    sections: sections ?? this.sections,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    availableNow,
    sections,
    selectedIndex,
    errorMessage,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final MovieRepository _repository;

  Future<void> load() async {
    emit(const HomeState());

    final results = await Future.wait([
      _repository.getMovies(
        limit: 10,
        sortBy: MovieSort.dateAdded,
        minimumRating: 6,
      ),
      for (final genre in AppConstants.homeGenres)
        _repository.getMovies(
          limit: 12,
          sortBy: MovieSort.downloadCount,
          genre: genre,
        ),
    ]);
    if (isClosed) return;

    final latest = results.first;
    final sections = <HomeSection>[
      for (var i = 0; i < AppConstants.homeGenres.length; i++)
        if (results[i + 1] case Success<MoviePage>(
          :final data,
        ) when data.movies.isNotEmpty)
          HomeSection(genre: AppConstants.homeGenres[i], movies: data.movies),
    ];
    final availableNow = switch (latest) {
      Success<MoviePage>(:final data) => data.movies,
      Failed<MoviePage>() => const <Movie>[],
    };

    if (availableNow.isEmpty && sections.isEmpty) {
      final failure = results
          .whereType<Failed<MoviePage>>()
          .map((result) => result.failure)
          .firstOrNull;
      emit(
        HomeState(
          status: HomeStatus.failure,
          errorMessage: (failure ?? const ServerFailure()).message,
        ),
      );
      return;
    }

    emit(
      HomeState(
        status: HomeStatus.success,
        availableNow: availableNow,
        sections: sections,
      ),
    );
  }

  void selectMovie(int index) {
    if (index < 0 || index >= state.availableNow.length) return;
    emit(state.copyWith(selectedIndex: index));
  }
}
