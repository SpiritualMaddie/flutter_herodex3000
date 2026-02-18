import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Displays images with automatic CORS proxy on web + in-memory caching.
///
/// On mobile/desktop: loads image directly from URL
/// On web: tries multiple CORS proxies as fallback
///
/// Features:
/// - Loading spinner while fetching
/// - Automatic proxy fallback
/// - Error handling
/// - Placeholder/Fallback if image wont show up

class CorsProxyImage extends StatefulWidget {
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

  @override
  State<CorsProxyImage> createState() => _CorsProxyImageState();
}

class _CorsProxyImageState extends State<CorsProxyImage> {

  // List of CORS proxies to try (in order)
  static const List<String> _corsProxies = [
    'https://corsproxy.io/?url=', // Usually more reliable
    'https://api.allorigins.win/raw?url=',
    '', // Last attempt: try direct URL (might work for some images)
  ];

  int _currentProxyIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  String? get _currentProxiedUrl {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) return null;

    // On mobile/desktop, always use direct URL
    if (!kIsWeb) return widget.imageUrl;

    // On web, try current proxy
    final proxy = _corsProxies[_currentProxyIndex];
    if (proxy.isEmpty) return widget.imageUrl; // Direct attempt

    // Encode URL for proxy
    return '$proxy${Uri.encodeComponent(widget.imageUrl!)}';
  }

  void _loadImage() {
    final url = _currentProxiedUrl;
    if (url == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Otherwise, Image.network will handle loading
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
  }

  void _tryNextProxy() {
    if (_currentProxyIndex < _corsProxies.length - 1) {
      setState(() {
        _currentProxyIndex++;
        debugPrint('🔄 Trying next CORS proxy (${_currentProxyIndex + 1}/${_corsProxies.length})');
      });
      _loadImage();
    } else {
      // All proxies failed
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      debugPrint('❌ All CORS proxies failed for: ${widget.imageUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _currentProxiedUrl;

    if (url == null || _hasError) {
      return _buildFallback();
    }

    return Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {

          // Defer state change to avoid "setState during build" error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          });
          return child;
        }

        // Still loading - show spinner
        return widget.placeholder ?? _buildLoadingSpinner(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ CorsProxyImage error (proxy ${_currentProxyIndex + 1}/${_corsProxies.length}): ${widget.imageUrl}\nError: $error');

        // Try next proxy
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _tryNextProxy();
          }
        });

        // Show loading spinner while trying next proxy
        if (_currentProxyIndex < _corsProxies.length - 1) {
          return _buildLoadingSpinner(null);
        }

        // All proxies failed - show fallback
        return widget.errorWidget ?? _buildFallback();
      },
    );
  }

  Widget _buildLoadingSpinner(ImageChunkEvent? loadingProgress) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF121F2B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.cyan,
                strokeWidth: 2,
                value: loadingProgress?.expectedTotalBytes != null
                    ? loadingProgress!.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
            if (loadingProgress?.expectedTotalBytes != null) ...[
              const SizedBox(height: 8),
              Text(
                '${(loadingProgress!.cumulativeBytesLoaded / 1024).toStringAsFixed(0)} KB',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF121F2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}