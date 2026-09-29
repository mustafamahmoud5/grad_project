import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.name = '',
    this.phone = '',
    this.avatarIndex = 0,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final int avatarIndex;

  final String? photoUrl;

  String get displayName => name.isNotEmpty
      ? name
      : (email.contains('@') ? email.split('@').first : email);

  AppUser copyWith({String? name, String? phone, int? avatarIndex}) => AppUser(
    id: id,
    email: email,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    avatarIndex: avatarIndex ?? this.avatarIndex,
    photoUrl: photoUrl,
  );

  @override
  List<Object?> get props => [id, email, name, phone, avatarIndex, photoUrl];
}
