@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/core/constants/api_constants.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/core/utils/result.dart';
import 'package:grad_project/data/datasources/remote/movie_remote_data_source.dart';
import 'package:grad_project/data/repositories/movie_repository_impl.dart';
import 'package:grad_project/domain/entities/movie.dart';
import 'package:grad_project/domain/entities/movie_details.dart';
import 'package:grad_project/domain/entities/movie_page.dart';

import '../helpers/fakes.dart';

void main() {
  final repository = MovieRepositoryImpl(
    remoteDataSource: YtsMovieRemoteDataSource(DioApiClient()),
    networkInfo: FakeNetworkInfo(),
  );

  test(
    'lists, filters, searches and loads details from YTS',
    () async {
      final latest = await repository.getMovies(limit: 5, minimumRating: 6);
      final page = (latest as Success<MoviePage>).data;
      expect(page.movies, isNotEmpty);
      expect(page.totalCount, greaterThan(1000));
      expect(page.movies.first.posterUrl, startsWith('https://'));

      final action = await repository.getMovies(
        genre: 'Action',
        sortBy: MovieSort.downloadCount,
        page: 2,
      );
      final actionPage = (action as Success<MoviePage>).data;
      expect(actionPage.page, 2);
      expect(
        actionPage.movies.every((m) => m.genres.contains('Action')),
        isTrue,
      );

      final search = await repository.searchMovies('inception');
      final found = (search as Success<MoviePage>).data.movies;
      expect(found.map((m) => m.title.toLowerCase()), contains('inception'));

      final details = await repository.getMovieDetails(found.first.id);
      final movie = (details as Success<MovieDetails>).data;
      expect(movie.overview, isNotEmpty);
      expect(movie.cast, isNotEmpty);
      expect(movie.screenshots, isNotEmpty);

      final similar = await repository.getMovieSuggestions(movie.id);
      expect((similar as Success<List<Movie>>).data, isNotEmpty);

      final empty = await repository.searchMovies('zzqqxxnotamovie');
      expect((empty as Success<MoviePage>).data.movies, isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
