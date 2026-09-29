import 'dart:async';

import 'package:grad_project/core/constants/api_constants.dart';
import 'package:grad_project/core/errors/failures.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/core/network/network_info.dart';
import 'package:grad_project/core/services/local_storage_service.dart';
import 'package:grad_project/core/utils/result.dart';
import 'package:grad_project/domain/entities/movie.dart';
import 'package:grad_project/domain/entities/movie_details.dart';
import 'package:grad_project/domain/entities/movie_page.dart';
import 'package:grad_project/domain/entities/user.dart';
import 'package:grad_project/domain/repositories/auth_repository.dart';
import 'package:grad_project/domain/repositories/favorites_repository.dart';
import 'package:grad_project/domain/repositories/history_repository.dart';
import 'package:grad_project/domain/repositories/movie_repository.dart';

List<Movie> movies(int count, {int start = 1}) => [
  for (var i = start; i < start + count; i++) Movie(id: i, title: 'Movie $i'),
];

MoviePage page(List<Movie> items, {int page = 1, int total = 100}) =>
    MoviePage(movies: items, page: page, totalCount: total, limit: 20);

class FakeApiClient implements ApiClient {
  FakeApiClient(this.handler);

  Future<Map<String, dynamic>> Function(String path, Map<String, dynamic>? q)
  handler;
  final calls = <(String, Map<String, dynamic>?)>[];

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    calls.add((path, queryParameters));
    return handler(path, queryParameters);
  }
}

class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({this.connected = true});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class InMemoryStorage implements LocalStorageService {
  final values = <String, Object>{};

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;
}

class FakeMovieRepository implements MovieRepository {
  Future<Result<MoviePage>> Function(int page, String? genre)? onGetMovies;
  Future<Result<MoviePage>> Function(String query, int page)? onSearch;
  Result<MovieDetails> detailsResult = const Failed(ServerFailure());
  Result<List<Movie>> suggestionsResult = const Success([]);
  final searchCalls = <(String, int)>[];

  @override
  Future<Result<MoviePage>> getMovies({
    int page = 1,
    int limit = 20,
    MovieSort sortBy = MovieSort.dateAdded,
    String? genre,
    double? minimumRating,
  }) async => onGetMovies?.call(page, genre) ?? Success(this.page(const []));

  MoviePage page(List<Movie> items) =>
      MoviePage(movies: items, page: 1, totalCount: items.length, limit: 20);

  @override
  Future<Result<MoviePage>> searchMovies(String query, {int page = 1}) {
    searchCalls.add((query, page));
    return onSearch?.call(query, page) ?? Future.value(Success(this.page([])));
  }

  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) async =>
      detailsResult;

  @override
  Future<Result<List<Movie>>> getMovieSuggestions(int movieId) async =>
      suggestionsResult;
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.userId});

  String? userId;
  Result<AppUser> loginResult = const Success(
    AppUser(id: 'u1', email: 'a@b.com'),
  );
  final loginCalls = <(String, String)>[];
  bool loggedOut = false;

  @override
  bool get isAvailable => true;

  @override
  String? get currentUserId => userId;

  @override
  Future<String?> restoreSession() async => userId;

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    loginCalls.add((email, password));
    return loginResult;
  }

  @override
  Future<Result<AppUser>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    int avatarIndex = 0,
  }) async => loginResult;

  @override
  Future<Result<AppUser>> signInWithGoogle() async => loginResult;

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async =>
      const Success(null);

  @override
  Future<Result<AppUser>> getCurrentUser() async => loginResult;

  @override
  Future<Result<AppUser>> updateProfile({
    required String name,
    required String phone,
    required int avatarIndex,
  }) async => loginResult;

  @override
  Future<Result<void>> deleteAccount() async => const Success(null);

  @override
  Future<void> logout() async => loggedOut = true;
}

class FakeFavoritesRepository implements FavoritesRepository {
  final favorites = <int, Movie>{};
  Result<void>? nextWriteResult;
  final _controller = StreamController<List<Movie>>.broadcast();

  @override
  Stream<List<Movie>> watchFavorites() => _controller.stream;

  void emitFavorites() => _controller.add(favorites.values.toList());

  @override
  Future<Result<bool>> isFavorite(int movieId) async =>
      Success(favorites.containsKey(movieId));

  @override
  Future<Result<void>> addFavorite(Movie movie) async {
    final result = nextWriteResult ?? const Success(null);
    if (result is Success) favorites[movie.id] = movie;
    return result;
  }

  @override
  Future<Result<void>> removeFavorite(int movieId) async {
    final result = nextWriteResult ?? const Success(null);
    if (result is Success) favorites.remove(movieId);
    return result;
  }
}

class FakeHistoryRepository implements HistoryRepository {
  final added = <Movie>[];

  @override
  Future<void> addToHistory(Movie movie) async => added.add(movie);

  @override
  Stream<List<Movie>> watchHistory() => Stream.value(added);
}
