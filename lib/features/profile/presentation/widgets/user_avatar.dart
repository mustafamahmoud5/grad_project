import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../domain/entities/user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.avatarIndex,
    this.size = 118,
  });

  final AppUser? user;
  final int? avatarIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    final index = avatarIndex ?? user?.avatarIndex;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && avatarIndex == null && (index ?? 0) == 0
          ? AppNetworkImage(url: photoUrl, fallbackIcon: Icons.person_rounded)
          : Image.asset(AssetConstants.avatar(index), fit: BoxFit.cover),
    );
  }
}
