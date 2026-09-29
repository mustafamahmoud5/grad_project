import 'dart:async';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/movie_model.dart';

/// History is kept on the device (per user) with SharedPreferences.
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({
    required LocalDataSource localDataSource,
    required AuthRepository authRepository,
  }) : _local = localDataSource,
       _auth = authRepository;

  final LocalDataSource _local;
  final AuthRepository _auth;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<Movie>> watchHistory() async* {
    yield _current();
    await for (final _ in _changes.stream) {
      yield _current();
    }
  }

  @override
  Future<void> addToHistory(Movie movie) async {
    final userId = _auth.currentUserId;
    if (userId == null) return;
    final history = _local.getHistory(userId)
      ..removeWhere((item) => item.id == movie.id)
      ..insert(0, MovieModel.fromEntity(movie));
    try {
      await _local.saveHistory(userId, history);
      _changes.add(null);
    } catch (_) {
      // History is a convenience; failing to store it must not break the UI.
    }
  }

  List<Movie> _current() {
    final userId = _auth.currentUserId;
    return userId == null ? const [] : _local.getHistory(userId);
  }
}
