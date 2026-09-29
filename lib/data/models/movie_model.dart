import '../../core/utils/helpers.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_page.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    super.year,
    super.rating,
    super.runtime,
    super.genres,
    super.summary,
    super.posterUrl,
    super.largePosterUrl,
    super.backgroundUrl,
    super.url,
  });

  /// Parses a movie object from the YTS API (or one saved with [toJson]).
  /// Missing or malformed fields fall back to safe defaults.
  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: Helpers.integer(json['id']),
    title: Helpers.string(
      json['title_english'] ?? json['title'],
      Helpers.string(json['title']),
    ),
    year: Helpers.integer(json['year']),
    rating: Helpers.decimal(json['rating']),
    runtime: Helpers.integer(json['runtime']),
    genres: Helpers.stringList(json['genres']),
    summary: Helpers.string(json['summary'] ?? json['description_full']),
    posterUrl: Helpers.url(json['medium_cover_image']),
    largePosterUrl: Helpers.url(json['large_cover_image']),
    backgroundUrl: Helpers.url(
      json['background_image'] ?? json['background_image_original'],
    ),
    url: Helpers.url(json['url']),
  );

  factory MovieModel.fromEntity(Movie movie) => MovieModel(
    id: movie.id,
    title: movie.title,
    year: movie.year,
    rating: movie.rating,
    runtime: movie.runtime,
    genres: movie.genres,
    summary: movie.summary,
    posterUrl: movie.posterUrl,
    largePosterUrl: movie.largePosterUrl,
    backgroundUrl: movie.backgroundUrl,
    url: movie.url,
  );

  /// A movie is usable only when it has an id and a title.
  bool get isValid => id > 0 && title.isNotEmpty;

  /// Compact representation used for the watch list and history.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'year': year,
    'rating': rating,
    'runtime': runtime,
    'genres': genres,
    'medium_cover_image': posterUrl,
    'large_cover_image': largePosterUrl,
    'background_image': backgroundUrl,
    'url': url,
  };
}

abstract final class MoviePageModel {
  /// Parses the `data` object of a `list_movies.json` response.
  static MoviePage fromJson(Map<String, dynamic> data, {required int page}) {
    final movies = Helpers.mapList(
      data['movies'],
    ).map(MovieModel.fromJson).where((movie) => movie.isValid).toList();
    final limit = Helpers.integer(data['limit']);
    return MoviePage(
      movies: movies,
      page: Helpers.integer(data['page_number'], page),
      totalCount: Helpers.integer(data['movie_count']),
      limit: limit > 0 ? limit : movies.length,
    );
  }
}
