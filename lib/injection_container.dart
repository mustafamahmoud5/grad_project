import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/services/local_storage_service.dart';
import 'data/datasources/local/local_data_source.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/datasources/remote/favorites_remote_data_source.dart';
import 'data/datasources/remote/movie_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/history_repository_impl.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'data/repositories/onboarding_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/favorites_repository.dart';
import 'domain/repositories/history_repository.dart';
import 'domain/repositories/movie_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<MovieRepository>()) return;

  final preferences = await SharedPreferences.getInstance();

  getIt
    ..registerLazySingleton<ApiClient>(DioApiClient.new)
    ..registerLazySingleton<NetworkInfo>(ConnectivityNetworkInfo.new)
    ..registerLazySingleton<LocalStorageService>(
      () => SharedPreferencesStorage(preferences),
    )
    ..registerLazySingleton<MovieRemoteDataSource>(
      () => YtsMovieRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      FirebaseAuthRemoteDataSource.new,
    )
    ..registerLazySingleton<FavoritesRemoteDataSource>(
      FirestoreFavoritesDataSource.new,
    )
    ..registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(getIt()))
    ..registerLazySingleton<MovieRepository>(
      () =>
          MovieRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        remoteDataSource: getIt(),
        authRepository: getIt(),
      ),
    )
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(
        localDataSource: getIt(),
        authRepository: getIt(),
      ),
    )
    ..registerLazySingleton(() => OnboardingRepository(getIt()));
}
