import 'dart:convert';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../models/movie_model.dart';

abstract interface class LocalDataSource {
  bool get isOnboardingCompleted;
  Future<void> completeOnboarding();

  List<MovieModel> getHistory(String userId);
  Future<void> saveHistory(String userId, List<MovieModel> movies);
}

class LocalDataSourceImpl implements LocalDataSource {
  const LocalDataSourceImpl(this._storage);

  final LocalStorageService _storage;

  static const _onboardingKey = 'onboarding_completed';
  static String _historyKey(String userId) => 'history_$userId';

  @override
  bool get isOnboardingCompleted => _storage.getBool(_onboardingKey) ?? false;

  @override
  Future<void> completeOnboarding() => _storage.setBool(_onboardingKey, true);

  @override
  List<MovieModel> getHistory(String userId) {
    final raw = _storage.getString(_historyKey(userId));
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((json) => MovieModel.fromJson(Map<String, dynamic>.from(json)))
          .where((movie) => movie.isValid)
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> saveHistory(String userId, List<MovieModel> movies) =>
      _storage.setString(
        _historyKey(userId),
        jsonEncode(
          movies
              .take(AppConstants.historyLimit)
              .map((movie) => movie.toJson())
              .toList(),
        ),
      );
}
