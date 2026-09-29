import '../../core/utils/helpers.dart';
import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.avatarIndex,
    super.photoUrl,
  });

  /// Builds the user from its Firestore profile document, falling back to the
  /// Firebase Auth values when the document is missing fields.
  factory UserModel.fromFirestore(
    Map<String, dynamic>? data, {
    required String id,
    required String email,
    String? authName,
    String? photoUrl,
  }) => UserModel(
    id: id,
    email: Helpers.string(data?['email'], email),
    name: Helpers.string(data?['name'], authName ?? ''),
    phone: Helpers.string(data?['phone']),
    avatarIndex: Helpers.integer(data?['avatarIndex']),
    photoUrl: photoUrl,
  );

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'phone': phone,
    'avatarIndex': avatarIndex,
  };
}
