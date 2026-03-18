import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

///
/// Image widget with automatic CORS proxy fallback on web.
/// 
/// Problem: SuperHeroAPI blocks direct web requests (CORS policy)
/// Solution: Try multiple CORS proxy services as fallbacks
/// 
/// Behavior by platform:
/// - Mobile/Desktop: Use direct URL
/// - Web: Try proxy chain (corsproxy.io → allorigins.win → direct)
/// 
/// Features:
/// - Automatic proxy fallback on error
/// - Loading spinner with progress (if available)
/// - Error handling with placeholder fallback
/// - Prevents "setState during build" errors with addPostFrameCallback
/// 

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

  /// List of CORS proxies to try in order.
  /// 
  /// Order:
  /// 1. corsproxy.io: Usually most reliable
  /// 2. cors-anywhere: Backup proxy 
  /// 3. api.codetabs: Backup proxy
  /// 4. Empty string: Direct URL as last resort
  static const List<String> _corsProxies = [
    'https://corsproxy.io/?url=',
    'https://cors-anywhere.com/',
    'https://api.codetabs.com/v1/proxy/?quest=',
    '',
  ];

  int _currentProxyIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// Gets current proxied URL based on platform and proxy index.
  /// 
  /// Returns:
  /// - null: If imageUrl is null/empty
  /// - Direct URL: On mobile/desktop
  /// - Proxied URL: On web, with current proxy prefix
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

  /// Initiates image loading with current proxy.
  /// 
  /// Sets loading state, actual loading happens in Image.network.
  void _loadImage() {
    final url = _currentProxiedUrl;
    if (url == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Image.network will handle actual loading
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
  }

  /// Tries next proxy in chain when current one fails.
  /// 
  /// Flow:
  /// 1. If more proxies available → increment index, try next
  /// 2. If all proxies exhausted → set error state, show fallback
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

        // Still loading - show spinner or custom placeholder
        return widget.placeholder ?? _buildLoadingSpinner(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ CorsProxyImage error (proxy ${_currentProxyIndex + 1}/${_corsProxies.length}): ${widget.imageUrl}\nError: $error');

        // Try next proxy using addPostFrameCallback to avoid setState during build
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

  /// Loading spinner with optional progress indicator.
  /// 
  /// Shows:
  /// - Circular progress indicator (cyan)
  /// - Download progress in KB (if available)
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
            // Show KB downloaded if size is known
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

  /// Fallback widget when all image loading attempts fail.
  /// 
  /// Shows: Person icon (white) on dark background.
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