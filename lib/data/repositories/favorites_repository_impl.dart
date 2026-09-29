import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/remote/favorites_remote_data_source.dart';
import '../models/movie_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl({
    required FavoritesRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  }) : _remote = remoteDataSource,
       _auth = authRepository;

  final FavoritesRemoteDataSource _remote;
  final AuthRepository _auth;

  static const _signedOut = AuthFailure(
    'Please log in to use your watch list.',
  );

  @override
  Stream<List<Movie>> watchFavorites() {
    final userId = _auth.currentUserId;
    if (userId == null) return Stream.value(const []);
    return _remote.watchFavorites(userId);
  }

  @override
  Future<Result<bool>> isFavorite(int movieId) =>
      _guard((userId) => _remote.isFavorite(userId, movieId));

  @override
  Future<Result<void>> addFavorite(Movie movie) => _guard(
    (userId) => _remote.addFavorite(userId, MovieModel.fromEntity(movie)),
  );

  @override
  Future<Result<void>> removeFavorite(int movieId) =>
      _guard((userId) => _remote.removeFavorite(userId, movieId));

  Future<Result<T>> _guard<T>(Future<T> Function(String userId) action) async {
    final userId = _auth.currentUserId;
    if (userId == null) return const Failed(_signedOut);
    try {
      return Success(await action(userId));
    } catch (error) {
      return Failed(ErrorMapper.toFailure(error));
    }
  }
}
