import '../../core/utils/helpers.dart';
import '../../domain/entities/movie_details.dart';
import 'movie_model.dart';

class MovieDetailsModel extends MovieDetails {
  const MovieDetailsModel({
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
    super.likeCount,
    super.description,
    super.trailerCode,
    super.language,
    super.mpaRating,
    super.screenshots,
    super.cast,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    final base = MovieModel.fromJson(json);
    return MovieDetailsModel(
      id: base.id,
      title: base.title,
      year: base.year,
      rating: base.rating,
      runtime: base.runtime,
      genres: base.genres,
      summary: Helpers.string(json['description_intro'], base.summary),
      posterUrl: base.posterUrl,
      largePosterUrl: base.largePosterUrl,
      backgroundUrl: base.backgroundUrl,
      url: base.url,
      likeCount: Helpers.integer(json['like_count']),
      description: Helpers.string(json['description_full']),
      trailerCode: Helpers.nullableString(json['yt_trailer_code']),
      language: Helpers.nullableString(json['language']),
      mpaRating: Helpers.nullableString(json['mpa_rating']),
      screenshots: [
        for (var i = 1; i <= 3; i++)
          Helpers.url(json['large_screenshot_image$i']) ??
              Helpers.url(json['medium_screenshot_image$i']),
      ].whereType<String>().toList(),
      cast: Helpers.mapList(json['cast'])
          .map(CastMemberModel.fromJson)
          .where((member) => member.name.isNotEmpty)
          .toList(),
    );
  }

  bool get isValid => id > 0 && title.isNotEmpty;
}

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.name,
    super.characterName,
    super.imageUrl,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) =>
      CastMemberModel(
        name: Helpers.string(json['name']),
        characterName: Helpers.nullableString(json['character_name']),
        imageUrl: Helpers.url(json['url_small_image']),
      );
}
