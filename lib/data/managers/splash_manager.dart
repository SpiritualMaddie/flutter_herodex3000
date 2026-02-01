class SplashManager { // TODO look over
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