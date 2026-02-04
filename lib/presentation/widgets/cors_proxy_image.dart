import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Displays images with automatic CORS proxy on web.
/// 
/// On mobile/desktop: loads image directly from URL
/// On web: proxies through cors-anywhere to bypass CORS
/// 
/// Usage:
/// ```dart
/// CorsProxyImage(
///   imageUrl: agent.image.url,
///   width: 100,
///   height: 100,
///   fit: BoxFit.cover,
/// )
/// ```
class CorsProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CorsProxyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  // CORS proxy for web. Uses a public proxy service.
  // Alternative proxies if this one goes down:
  // - https://corsproxy.io/?
  /// - https://api.allorigins.win/raw?url=
  static const String _corsProxy = 'https://api.allorigins.win/raw?url=';

  String? get _proxiedUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    
    // On web, prepend the CORS proxy
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(imageUrl!)}';
    }
    
    // On mobile/desktop, use original URL
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final url = _proxiedUrl;

    if (url == null) {
      return _buildFallback();
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ CorsProxyImage failed to load: $imageUrl\nError: $error');
        return errorWidget ?? _buildFallback();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF121F2B),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.cyan,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF121F2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.shield,
          color: Colors.cyan,
          size: 32,
        ),
      ),
    );
  }
}