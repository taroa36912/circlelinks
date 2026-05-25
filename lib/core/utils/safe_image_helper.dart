import 'package:flutter/material.dart';

/// Returns a safe [NetworkImage] provider, or null if the URL is null/empty.
ImageProvider? safeNetworkImage(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  return NetworkImage(url);
}

/// Filter out known-bad or invalid image URLs. Returns the original URL
/// or null if the URL should be skipped.
String? safePhotoUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final trimmed = url.trim();
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return null;
  }
  return trimmed;
}

/// A reusable circular avatar that gracefully degrades on network image
/// failures (including HTTP 429 from Google profile photo URLs).
/// Uses [Image.network] with [errorBuilder] internally for robust
/// fallback, avoiding the limitations of [CircleAvatar.onBackgroundImageError].
Widget safeCircleAvatar({
  String? imageUrl,
  double? radius,
  double? size,
  Widget? fallback,
  Color? backgroundColor,
}) {
  final safeUrl = safePhotoUrl(imageUrl);
  final double effectiveSize = size ?? (radius != null ? radius * 2 : 48);
  final double effectiveRadius = radius ?? effectiveSize / 2;

  if (safeUrl == null) {
    return CircleAvatar(
      radius: effectiveRadius,
      backgroundColor: backgroundColor,
      child: fallback ?? const Icon(Icons.person),
    );
  }

  return ClipOval(
    child: Image.network(
      safeUrl,
      width: effectiveSize,
      height: effectiveSize,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return CircleAvatar(
          radius: effectiveRadius,
          backgroundColor: backgroundColor,
          child: fallback ?? const Icon(Icons.person),
        );
      },
    ),
  );
}

/// A safe [Image.network] wrapper that renders [errorWidget] on HTTP errors
/// (including 429 responses). If the URL is null/empty/invalid, renders
/// the errorWidget immediately.
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
      return errorWidget ?? const Icon(Icons.broken_image, size: 48);
    },
  );
}
