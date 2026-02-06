import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;    // Phones
  static const double tablet = 900;    // Tablets  
  static const double desktop = 1200;  // Desktop/Web
}

/// Device type based on width
enum DeviceType { mobile, tablet, desktop }

/// Extension on BuildContext to easily access responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get current device type
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Check if mobile (< 600px)
  bool get isMobile => deviceType == DeviceType.mobile;

  /// Check if tablet (600-1200px)
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Check if desktop (> 1200px) — includes web on desktop browsers
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Get responsive padding based on device
  EdgeInsets get responsivePadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(32);
      case DeviceType.desktop:
        return const EdgeInsets.all(48);
    }
  }

  /// Get max content width for centered layouts on larger screens
  /// Mobile: full width, Tablet/Desktop: constrained for readability
  double get maxContentWidth {
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity; // Full width
      case DeviceType.tablet:
        return 800; // Constrained for readability
      case DeviceType.desktop:
        return 700; // Even more constrained on desktop
    }
  }
}