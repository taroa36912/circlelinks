import 'package:flutter/material.dart';

import '../core/utils/safe_image_helper.dart';

/// A safe circular avatar widget that gracefully handles network image
/// failures (including HTTP 429 from Google profile photo URLs).
///
/// Uses [Image.network] with [errorBuilder] internally for robust
/// fallback, avoiding the limitations of [CircleAvatar.onBackgroundImageError].
///
/// When [imageUrl] is null, empty, invalid, or fails to load, the
/// [fallback] widget is displayed instead.
class SafeAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? fallback;
  final Color? backgroundColor;

  const SafeAvatarWidget({
    super.key,
    this.imageUrl,
    required this.radius,
    this.fallback,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return safeCircleAvatar(
      imageUrl: imageUrl,
      radius: radius,
      fallback: fallback,
      backgroundColor: backgroundColor,
    );
  }
}
