import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/services/firebase_service.dart';
import '../../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  bool get isAvailable;
  String? get currentUserId;

  Future<String?> restoreSession();

  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarIndex,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required int avatarIndex,
  });

  Future<void> deleteAccount();

  Future<void> logout();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void>? _googleInitialization;

  DocumentReference<Map<String, dynamic>> _profile(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  bool get isAvailable => FirebaseService.isInitialized;

  @override
  String? get currentUserId => isAvailable ? _auth.currentUser?.uid : null;

  @override
  Future<String?> restoreSession() async {
    if (!isAvailable) return null;
    final user = await _auth.authStateChanges().first.timeout(
      const Duration(seconds: 5),
      onTimeout: () => _auth.currentUser,
    );
    return user?.uid;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    _ensureAvailable();
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _loadProfile(_requireUser(credential.user));
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarIndex,
  }) async {
    _ensureAvailable();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = _requireUser(credential.user);
    await user.updateDisplayName(name.trim());

    final profile = UserModel(
      id: user.uid,
      email: user.email ?? email.trim(),
      name: name.trim(),
      phone: phone.trim(),
      avatarIndex: avatarIndex,
    );
    try {
      await _profile(user.uid).set(profile.toFirestore());
    } catch (error) {
      debugPrint('Could not save user profile: $error');
    }
    return profile;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    _ensureAvailable();
    final UserCredential result;
    if (kIsWeb) {
      result = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      await (_googleInitialization ??= _googleSignIn.initialize());
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Google Sign-In did not return a token.');
      }
      result = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    }
    final user = _requireUser(result.user);
    if (result.additionalUserInfo?.isNewUser ?? false) {
      try {
        await _profile(user.uid).set(
          UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
          ).toFirestore(),
          SetOptions(merge: true),
        );
      } catch (error) {
        debugPrint('Could not save user profile: $error');
      }
    }
    return _loadProfile(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    _ensureAvailable();
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<UserModel> getCurrentUser() async {
    _ensureAvailable();
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Your session has ended. Please log in again.');
    }
    return _loadProfile(user);
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required int avatarIndex,
  }) async {
    _ensureAvailable();
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Your session has ended. Please log in again.');
    }
    await user.updateDisplayName(name.trim());
    final profile = UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: name.trim(),
      phone: phone.trim(),
      avatarIndex: avatarIndex,
      photoUrl: user.photoURL,
    );
    await _profile(
      user.uid,
    ).set(profile.toFirestore(), SetOptions(merge: true));
    return profile;
  }

  @override
  Future<void> deleteAccount() async {
    _ensureAvailable();
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _profile(user.uid).delete();
    } catch (error) {
      debugPrint('Could not delete user profile: $error');
    }
    await user.delete();
    await _signOutGoogle();
  }

  @override
  Future<void> logout() async {
    if (!isAvailable) return;
    await _signOutGoogle();
    await _auth.signOut();
  }

  Future<void> _signOutGoogle() async {
    if (kIsWeb || _googleInitialization == null) return;
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Google sign out failed: $error');
    }
  }

  Future<UserModel> _loadProfile(User user) async {
    Map<String, dynamic>? data;
    try {
      data = (await _profile(user.uid).get()).data();
    } catch (error) {
      debugPrint('Could not load user profile: $error');
    }
    return UserModel.fromFirestore(
      data,
      id: user.uid,
      email: user.email ?? '',
      authName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  User _requireUser(User? user) {
    if (user == null) {
      throw const AuthException('Authentication failed. Please try again.');
    }
    return user;
  }

  void _ensureAvailable() {
    if (!isAvailable) {
      throw const AuthException(
        'Sign in is not available right now. Firebase is not configured '
        'for this platform.',
      );
    }
  }
}
