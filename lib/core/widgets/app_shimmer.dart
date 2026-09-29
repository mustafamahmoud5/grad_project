import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    child: child,
  );
}

/// Grey rounded block used to build loading skeletons.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.radius = 16});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
