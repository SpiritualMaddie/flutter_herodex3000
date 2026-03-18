import 'package:flutter/foundation.dart';
import 'package:flutter_herodex3000/barrel_files/firebase.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

///
/// Centralized service for Firebase Analytics and Crashlytics.
/// Respects user permissions set in onboarding/settings.
/// 
/// IMPORTANT: Crashlytics only works on Android/iOS — all Crashlytics calls
/// are guarded to prevent crashes on web/desktop.
///

class FirebaseService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Whether Crashlytics is supported on this platform
  static final bool _crashlyticsSupported = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Initialize Firebase services based on user permissions.
  /// Call this in main.dart after Firebase.initializeApp().
  static Future<void> initialize({
    required bool analyticsEnabled,
    required bool crashlyticsEnabled,
  }) async {
    /// Configure Analytics (works on web, Android, iOS, macOS)
    try {
      final bool analyticsSupported = kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS;

      if (analyticsSupported) {
        await _analytics.setAnalyticsCollectionEnabled(analyticsEnabled);
        debugPrint(
          '🔥 Firebase Analytics: ${analyticsEnabled ? "ENABLED" : "DISABLED"}',
        );
      } else {
        debugPrint(
          '⚠️ Firebase Analytics: skipping on unsupported platform: $defaultTargetPlatform',
        );
      }
    } catch (e, st) {
      debugPrint('⚠️ Firebase Analytics: error toggling collection: $e\n$st');
    }

    /// Configure Crashlytics (ONLY on Android/iOS — never on web)
    if (!_crashlyticsSupported) {
      debugPrint(
        '⚠️ Firebase Crashlytics: not supported on platform: $defaultTargetPlatform',
      );
      return; /// Exit early — don't attempt any Crashlytics calls
    }

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        crashlyticsEnabled,
      );
      debugPrint(
        '🔥 Firebase Crashlytics: ${crashlyticsEnabled ? "ENABLED" : "DISABLED"}',
      );

      /// Set up error handlers only if enabled AND supported
      if (crashlyticsEnabled) {
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (e, st) {
      debugPrint('⚠️ Firebase Crashlytics: failed to initialize: $e\n$st');
    }
  }

  /// Update Analytics permission at runtime
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      debugPrint(
        '🔥 Firebase Analytics updated: ${enabled ? "ENABLED" : "DISABLED"}',
      );
    } catch (e, st) {
      debugPrint('⚠️ Firebase Analytics: error updating: $e\n$st');
    }
  }

  /// Update Crashlytics permission at runtime
  static Future<void> setCrashlyticsEnabled(bool enabled) async {
    if (!_crashlyticsSupported) {
      debugPrint('⚠️ Firebase Crashlytics: setCrashlytics skipped (unsupported platform)');
      return;
    }

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
      debugPrint(
        '🔥 Firebase Crashlytics updated: ${enabled ? "ENABLED" : "DISABLED"}',
      );
    } catch (e, st) {
      debugPrint('⚠️ Firebase Crashlytics: error updating: $e\n$st');
    }
  }

  /// --- Analytics event helpers ---

  static Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      debugPrint('🔥 Firebase Analytics: logLogin()');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Analytics: logLogin error: $e\n$st');
    }
  }

  static Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      debugPrint('🔥 Firebase Analytics: logSignUp()');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Analytics: logSignUp error: $e\n$st');
    }
  }

  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      debugPrint('🔥 Firebase Analytics: logScreenView($screenName)');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Analytics: logScreenView error: $e\n$st');
    }
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('🔥 Firebase Analytics: logEvent($name)');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Analytics: logEvent error: $e\n$st');
    }
  }

  /// --- Crashlytics helpers (all guarded) ---

  static Future<void> recordError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (!_crashlyticsSupported) return; /// Skip on web

    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: false,
      );
      debugPrint('🔥 Firebase Crashlytics: recordError($error)');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Crashlytics: recordError failed: $e\n$st');
    }
  }

  static Future<void> setUserId(String? userId) async {
    if (!_crashlyticsSupported) return; /// Skip on web

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
      debugPrint('🔥 Firebase Crashlytics: setUserId()');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Crashlytics: setUserId failed: $e\n$st');
    }
  }

  static Future<void> setCustomKey(String key, dynamic value) async {
    if (!_crashlyticsSupported) return; /// Skip on web

    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
      debugPrint('🔥 Firebase Crashlytics: setCustomKey($key)');
    } catch (e, st) {
      debugPrint('⚠️ Firebase Crashlytics: setCustomKey failed: $e\n$st');
    }
  }
}