import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    this.year = 0,
    this.rating = 0,
    this.runtime = 0,
    this.genres = const [],
    this.summary = '',
    this.posterUrl,
    this.largePosterUrl,
    this.backgroundUrl,
    this.url,
  });

  final int id;
  final String title;
  final int year;
  final double rating;

  /// Runtime in minutes, 0 when unknown.
  final int runtime;
  final List<String> genres;
  final String summary;
  final String? posterUrl;
  final String? largePosterUrl;
  final String? backgroundUrl;

  /// Public YTS page of the movie.
  final String? url;

  /// Best image for large headers.
  String? get heroImageUrl => largePosterUrl ?? posterUrl ?? backgroundUrl;

  @override
  List<Object?> get props => [id];
}
