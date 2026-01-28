import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferencesService._internal();

  static final SharedPreferencesService _instance = SharedPreferencesService._internal();

  factory SharedPreferencesService() => _instance;

  late final SharedPreferencesWithCache _prefs;
  bool _initialized = false;

  Future<void> init() async{
    if(_initialized) return;

    _prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        "onboarding_completed",
        "analytics_approved",
        "crashlytics_approved",
        "location_analytics_approved",
        "ios_att_approved",
      },
    ),
  );

  _initialized = true;
  }

  // --- SET - Analytics permissions ---
  Future<void> setAnalyticsToApproved(bool value) =>
      _prefs.setBool("analytics_approved", value);

  Future<void> setCrashlyticsToApproved(bool value) =>
      _prefs.setBool("crashlytics_approved", value);

  Future<void> setLocationAnalyticsToApproved(bool value) =>
      _prefs.setBool("location_analytics_approved", value);

  Future<void> setIosAttToApproved(bool value) =>
      _prefs.setBool("ios_att_approved", value);

  // --- GET - Analytics permissions ---
  bool get analyticsIsApproved => 
      _prefs.getBool("analytics_approved") ?? false;

  bool get crashlyticsIsApproved =>
      _prefs.getBool("crashlytics_approved") ?? false;

  bool get locationAnalyticsIsApproved =>
      _prefs.getBool("location_analytics_approved") ?? false;

  bool get iosAttIsApproved => 
      _prefs.getBool("ios_att_approved") ?? false;

  // --- SET & GET - Onboarding ---
    Future<void> setOnboardingToCompleted(bool value) =>
      _prefs.setBool("onboarding_completed", value);

  bool get onboardingIsCompleted =>
      _prefs.getBool("onboarding_completed") ?? false;
}
