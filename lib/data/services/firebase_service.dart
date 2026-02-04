import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Centralized service for Firebase Analytics and Crashlytics.
// Respects user permissions set in onboarding/settings.
class FirebaseService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize Firebase services based on user permissions.
  // Call this in main.dart after Firebase.initializeApp(). // TODO
  static Future<void> initialize({
    required bool analyticsEnabled,
    required bool crashlyticsEnabled,
  }) async {
    // Configure Analytics
    await _analytics.setAnalyticsCollectionEnabled(analyticsEnabled);
    debugPrint('🔥 Firebase Analytics: ${analyticsEnabled ? "ENABLED" : "DISABLED"}');

    // Configure Crashlytics
    await _crashlytics.setCrashlyticsCollectionEnabled(crashlyticsEnabled);
    debugPrint('🔥 Firebase Crashlytics: ${crashlyticsEnabled ? "ENABLED" : "DISABLED"}');

    // Catch Flutter framework errors and send to Crashlytics if enabled
    if (crashlyticsEnabled) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Catch async errors outside Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  // Update Analytics permission at runtime (when user changes setting).
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    debugPrint('🔥 Firebase Analytics updated: ${enabled ? "ENABLED" : "DISABLED"}');
  }

  // Update Crashlytics permission at runtime.
  static Future<void> setCrashlyticsEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    debugPrint('🔥 Firebase Crashlytics updated: ${enabled ? "ENABLED" : "DISABLED"}');
  }

  // --- Analytics event helpers (only log if enabled) ---

  // Log when user signs in
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
    debugPrint('🔥 Firebase Analytics: logLogin()');
  }

  // Log when user signs up
  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
    debugPrint('🔥 Firebase Analytics: logSignUp()');
  }

  // Log screen views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
    debugPrint('🔥 Firebase Analytics: logScreenView()');
  }

  // Log custom events (e.g., "agent_saved", "agent_removed")
  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
    debugPrint('🔥 Firebase Analytics: logEvent($name)');
  }

  // --- Crashlytics helpers ---

  // Manually log an error (non-fatal)
  static Future<void> recordError(dynamic error, StackTrace? stack, {String? reason}) async {
    await _crashlytics.recordError(error, stack, reason: reason, fatal: false);
    debugPrint('🔥 Firebase Analytics: recordError($error)');
  }

  // Set user ID for crash reports
  static Future<void> setUserId(String? userId) async {
    await _crashlytics.setUserIdentifier(userId ?? '');
    debugPrint('🔥 Firebase Analytics: setUserId()');
  }

  // Add custom key-value data to crash reports
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
    debugPrint('🔥 Firebase Analytics: setCustomKey($key)');
  }
}