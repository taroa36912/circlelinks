import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  /// Optional widget to show when the image fails to load or URL is null/empty.
  /// If null, a default asset image is shown.
  final Widget? errorWidget;

  /// Optional icon to show as a centered fallback. Used when [errorWidget] is
  /// null and no asset fallback is desired. Takes precedence over the default
  /// asset image only when explicitly provided.
  final IconData? fallbackIcon;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.fallbackIcon,
  });

  Widget _buildFallback() {
    if (errorWidget != null) return errorWidget!;
    if (fallbackIcon != null) {
      return Icon(fallbackIcon, size: height * 0.5, color: Colors.grey);
    }
    return Image.asset(
      "assets/images/no-image.jpg",
      fit: fit,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: _buildFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      errorWidget: (context, url, error) => _buildFallback(),
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
