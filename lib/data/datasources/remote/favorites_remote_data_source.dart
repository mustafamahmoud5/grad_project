import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/exceptions.dart';
import '../../models/movie_model.dart';

abstract interface class FavoritesRemoteDataSource {
  Stream<List<MovieModel>> watchFavorites(String userId);
  Future<bool> isFavorite(String userId, int movieId);
  Future<void> addFavorite(String userId, MovieModel movie);
  Future<void> removeFavorite(String userId, int movieId);
}

class FirestoreFavoritesDataSource implements FavoritesRemoteDataSource {
  FirestoreFavoritesDataSource({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _watchlist(String userId) =>
      _firestore.collection('users').doc(userId).collection('watchlist');

  @override
  Stream<List<MovieModel>> watchFavorites(String userId) => _watchlist(userId)
      .orderBy('addedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => MovieModel.fromJson(doc.data()))
            .where((movie) => movie.isValid)
            .toList(),
      );

  @override
  Future<bool> isFavorite(String userId, int movieId) async {
    final document = await _watchlist(userId).doc('$movieId').get();
    return document.exists;
  }

  @override
  Future<void> addFavorite(String userId, MovieModel movie) async {
    if (!movie.isValid) throw const ParsingException();
    await _watchlist(userId).doc('${movie.id}').set({
      ...movie.toJson(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFavorite(String userId, int movieId) =>
      _watchlist(userId).doc('$movieId').delete();
}
