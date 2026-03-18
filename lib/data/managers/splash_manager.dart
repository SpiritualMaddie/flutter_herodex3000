///
/// Handles Splashscreen and how long it should be shown
/// TODO implement to be shown fullscreen on other platforms than Android (instead of the small circle)
///

// ignore_for_file: dangling_library_doc_comments

class SplashManager {
  static DateTime? _splashStartTime;
  static const Duration minimumSplashDuration = Duration(seconds: 8);
  
  static void start() {
    _splashStartTime = DateTime.now();
  }
  
  static bool get shouldShowSplash {
    if (_splashStartTime == null) return true;
    
    final elapsed = DateTime.now().difference(_splashStartTime!);
    return elapsed < minimumSplashDuration;
  }
}