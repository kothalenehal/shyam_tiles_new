import 'package:shared_preferences/shared_preferences.dart';
import '../common/api_constant.dart';
import '../common/request.dart';

class AppSettings {
  static final sharedInstance = AppSettings();

  static const _kSignupEnabled = 'cached_signup_enabled';

  /// Whether the admin has enabled the sign-up flow in the mobile app.
  bool signupEnabled = false;

  /// Load the cached value immediately (call before async fetch)
  Future<void> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    signupEnabled = prefs.getBool(_kSignupEnabled) ?? false;
  }

  /// Fetches app settings from the admin panel API and updates the singleton.
  /// On success: updates both in-memory value and the cache.
  /// On failure: falls back to the cached value (last known good state).
  Future<bool> fetchSettings() async {
    try {
      final response =
          await Request.sharedInstance.getRequest(APIConstant.appSettings);

      if (response.status && response.body != null) {
        final data = response.body as Map<String, dynamic>;
        final val = data['signup_enabled'];
        signupEnabled = (val == '1' || val == 1 || val == true);
        print('AppSettings fetched from API: signupEnabled = $signupEnabled');

        // ✅ Persist the value so future failures fall back to this
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kSignupEnabled, signupEnabled);

        return true;
      } else {
        print('AppSettings API failed — using cached value: $signupEnabled');
        // Keep existing in-memory value (loaded from cache)
        return false;
      }
    } catch (e) {
      print('AppSettings fetch error — using cached value: $signupEnabled');
      // Keep existing in-memory value (loaded from cache)
      return false;
    }
  }
}
