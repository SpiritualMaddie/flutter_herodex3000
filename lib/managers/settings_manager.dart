import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/services/shared_preferences_service.dart';

class SettingsManager extends ChangeNotifier {
  final SharedPreferencesService _prefs;
  SettingsManager(this._prefs);

  Future<void> saveOnboardingPreferences({
    required bool analytics,
    required bool crashlytics,
    required bool location,
    //bool? iosAtt, // TODO make sure we check for ios first
  }) async { // TODO make it faster? // Add specific user to these preferences
    await _prefs.setAnalyticsToApproved(analytics);
    await _prefs.setCrashlyticsToApproved(crashlytics);
    await _prefs.setLocationAnalyticsToApproved(location);
    await _prefs.setOnboardingToCompleted(true);
    notifyListeners(); // TODO is it not refreshing as it should?
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

  bool get analyticsEnabled => _prefs.analyticsIsApproved;
  bool get crashlyticsEnabled => _prefs.crashlyticsIsApproved;
  bool get locationEnabled => _prefs.locationAnalyticsIsApproved;
  bool get onboardingCompleted => _prefs.onboardingIsCompleted;
}

//4. Visa valen i Settings-vyn
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         future: Future.wait([
//           SettingsManager.getStatus(SettingsManager.analyticsKey),
//           SettingsManager.getStatus(SettingsManager.crashlyticsKey),
//           SettingsManager.getStatus(SettingsManager.locationKey),
//         ]),
//         builder: (context, AsyncSnapshot<List<bool>> snapshot) {
//           if (!snapshot.hasData) return const CircularProgressIndicator();
//           return Column(
//             children: [
//               _buildSettingInfoTile("Analytics", snapshot.data![0]),
//               _buildSettingInfoTile("Crashlytics", snapshot.data![1]),
//               _buildSettingInfoTile("Location (VG)", snapshot.data![2]),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSettingInfoTile(String label, bool isEnabled) {
//     return ListTile(
//       title: Text(label, style: const TextStyle(color: Colors.white)),
//       trailing: Text(
//         isEnabled ? "AUTHORIZED" : "DISABLED",
//         style: TextStyle(color: isEnabled ? Colors.cyan : Colors.redAccent),
//       ),
//     );
//   }
// }
