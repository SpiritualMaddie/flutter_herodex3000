import 'package:flutter_herodex3000/barrel_files/services.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

class SettingsManager extends ChangeNotifier {
  final SharedPreferencesService _prefs;
  SettingsManager(this._prefs);

  Future<void> saveOnboardingPreferences({
    required bool analytics,
    required bool crashlytics,
    //required bool location,
    required String appThemeChosen,
    bool iosAtt = false,
  }) async {
    await _prefs.setAnalyticsToApproved(analytics);
    await _prefs.setCrashlyticsToApproved(crashlytics);
    //await _prefs.setLocationAnalyticsToApproved(location);
    await _prefs.setAppTheme(appThemeChosen);
    await _prefs.setIosAttToApproved(iosAtt);
    await _prefs.setOnboardingToCompleted(true);
    //await _prefs.setRosterSwipeHintSeen(false);

    // Update Firebase services with new permissions
    await FirebaseService.setAnalyticsEnabled(analytics);
    await FirebaseService.setCrashlyticsEnabled(crashlytics);

    notifyListeners();
  }

  Future<void> saveAnalyticsPreferences({required bool value}) async {
    await _prefs.setAnalyticsToApproved(value);
    await FirebaseService.setAnalyticsEnabled(value);
    notifyListeners();
  }

  Future<void> saveCrashAnalyticsPreferences({required bool value}) async {
    await _prefs.setCrashlyticsToApproved(value);
    await FirebaseService.setCrashlyticsEnabled(value);
    notifyListeners();
  }

  // Future<void> saveLocationAnalyticsPreferences({required bool value}) async {
  //   await _prefs.setLocationAnalyticsToApproved(value);
  //   notifyListeners();
  // }

    Future<void> saveCurrentAppTheme({required String value}) async {
    await _prefs.setAppTheme(value);
    notifyListeners();
  }

  Future<void> saveRosterSwipeHintSeen({required bool value}) async {
    await _prefs.setRosterSwipeHintSeen(value);
    notifyListeners();
  }

  //   Future<void> saveSplashShown({required bool value}) async {
  //   await _prefs.setSplashShown(value);
  //   notifyListeners();
  // }

  bool get analyticsEnabled => _prefs.analyticsIsApproved;
  bool get crashlyticsEnabled => _prefs.crashlyticsIsApproved;
  //bool get locationEnabled => _prefs.locationAnalyticsIsApproved;
  bool get onboardingCompleted => _prefs.onboardingIsCompleted;
  bool get iosAttEnabled => _prefs.iosAttIsApproved;
  String get appTheme => _prefs.currentAppTheme;
  bool get rosterSwipeHintSeen => _prefs.rosterSwipeHintSeen;
  //bool get splashShown => _prefs.splashShown;
}