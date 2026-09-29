import '../datasources/local/local_data_source.dart';

class OnboardingRepository {
  const OnboardingRepository(this._local);

  final LocalDataSource _local;

  bool get isCompleted => _local.isOnboardingCompleted;

  Future<void> complete() async {
    try {
      await _local.completeOnboarding();
    } catch (_) {}
  }
}
