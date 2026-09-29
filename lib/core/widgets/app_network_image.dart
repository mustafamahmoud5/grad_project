import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_shimmer.dart';

/// Network image with a shimmer placeholder, a graceful fallback for missing
/// or broken images and disk caching on mobile.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.fallbackIcon = Icons.movie_creation_outlined,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;

  /// Disk caching relies on platform plugins that do not exist in widget
  /// tests. Tests switch this off to use a plain [Image.network].
  @visibleForTesting
  static bool useDiskCache = true;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    final Widget image;
    if (imageUrl == null || imageUrl.isEmpty) {
      image = _fallback();
    } else if (kIsWeb || !useDiskCache) {
      image = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Lets the browser render posters from hosts without CORS headers.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _fallback(),
      );
    }
    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  Widget _placeholder() => AppShimmer(
    child: Container(width: width, height: height, color: AppColors.white),
  );

  Widget _fallback() => Container(
    width: width,
    height: height,
    color: AppColors.surfaceLight,
    alignment: Alignment.center,
    child: Icon(fallbackIcon, color: AppColors.primary, size: 36),
  );
}
