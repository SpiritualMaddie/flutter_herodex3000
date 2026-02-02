import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/data/services/shared_preferences_service.dart';

class SettingsManager extends ChangeNotifier {
  final SharedPreferencesService _prefs;
  SettingsManager(this._prefs);

  Future<void> saveOnboardingPreferences({
    required bool analytics,
    required bool crashlytics,
    required bool location,
    bool? iosAtt, // TODO does it work?
  }) async {
    await _prefs.setAnalyticsToApproved(analytics);
    await _prefs.setCrashlyticsToApproved(crashlytics);
    await _prefs.setLocationAnalyticsToApproved(location);
    await _prefs.setOnboardingToCompleted(true);
    notifyListeners();
  }

  Future<void> saveAnalyticsPreferences({required bool value}) async {
    await _prefs.setAnalyticsToApproved(value);
    notifyListeners();
  }

  Future<void> saveCrashAnalyticsPreferences({required bool value}) async {
    await _prefs.setCrashlyticsToApproved(value);
    notifyListeners();
  }

  Future<void> saveLocationAnalyticsPreferences({required bool value}) async {
    await _prefs.setLocationAnalyticsToApproved(value);
    notifyListeners();
  }

    Future<void> saveCurrentAppTheme({required String value}) async {
    await _prefs.setAppTheme(value);
    notifyListeners();
  }

  //   Future<void> saveSplashShown({required bool value}) async {
  //   await _prefs.setSplashShown(value);
  //   notifyListeners();
  // }

  bool get analyticsEnabled => _prefs.analyticsIsApproved;
  bool get crashlyticsEnabled => _prefs.crashlyticsIsApproved;
  bool get locationEnabled => _prefs.locationAnalyticsIsApproved;
  bool get onboardingCompleted => _prefs.onboardingIsCompleted;
  String get appTheme => _prefs.currentAppTheme;
  //bool get splashShown => _prefs.splashShown;
}