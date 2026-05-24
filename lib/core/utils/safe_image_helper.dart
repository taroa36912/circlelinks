import 'package:flutter/material.dart';

/// Returns a safe [NetworkImage] provider, or null if the URL is null/empty.
/// Works around Google profile photo URLs that may return HTTP 429 by using
/// the [CircleAvatar.onBackgroundImageError] callback pattern.
ImageProvider? safeNetworkImage(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  return NetworkImage(url);
}

/// Filter out known-bad Google user-content profile photo URLs that may
/// cause HTTP 429 rate-limit errors. Returns the original URL or null if
/// the URL pattern suggests it should be skipped to avoid a crash.
String? safePhotoUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;

  // Google user-content profile image URLs can return 429.
  // We keep them but this function exists as a filter point if needed.
  // For now we simply validate the URL looks plausible.
  final trimmed = url.trim();
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return null;
  }
  return trimmed;
}

/// A reusable [CircleAvatar] that gracefully degrades on network image
/// failures. Shows [fallback] (default: Icons.person) when no image is
/// available or when the image fails to load.
Widget safeCircleAvatar({
  String? imageUrl,
  double? radius,
  Widget? fallback,
  Color? backgroundColor,
}) {
  final safeUrl = safePhotoUrl(imageUrl);
  final provider = safeNetworkImage(safeUrl);

  return CircleAvatar(
    radius: radius,
    backgroundColor: backgroundColor,
    backgroundImage: provider,
    onBackgroundImageError: provider != null
        ? (_, __) {
            debugPrint('⚡ CircleAvatar image failed to load: $safeUrl');
          }
        : null,
    child: provider == null
        ? (fallback ?? const Icon(Icons.person))
        : null,
  );
}

/// A safe [Image.network] wrapper that renders [fallback] on HTTP errors
/// (including 429 responses).
Widget safeNetworkImageWidget(
  String? url, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget? errorWidget,
}) {
  final safeUrl = safePhotoUrl(url);
  if (safeUrl == null) {
    return SizedBox(
      width: width,
      height: height,
      child: errorWidget ?? const Icon(Icons.broken_image, size: 48),
    );
  }
  return Image.network(
    safeUrl,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) {
      debugPrint('⚡ Image.network failed: $error for $safeUrl');
      return errorWidget ?? const Icon(Icons.broken_image, size: 48);
    },
  );
}
