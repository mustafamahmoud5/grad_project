import 'package:equatable/equatable.dart';

import 'movie.dart';

class MovieDetails extends Movie {
  const MovieDetails({
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
    this.likeCount = 0,
    this.description = '',
    this.trailerCode,
    this.language,
    this.mpaRating,
    this.screenshots = const [],
    this.cast = const [],
  });

  final int likeCount;
  final String description;

  final String? trailerCode;
  final String? language;
  final String? mpaRating;
  final List<String> screenshots;
  final List<CastMember> cast;

  String get overview => description.isNotEmpty ? description : summary;
}

class CastMember extends Equatable {
  const CastMember({required this.name, this.characterName, this.imageUrl});

  final String name;
  final String? characterName;
  final String? imageUrl;

  @override
  List<Object?> get props => [name, characterName, imageUrl];
}
