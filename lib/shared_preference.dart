import 'package:shared_preferences/shared_preferences.dart';

import 'model/user.dart';

class SharedPreference {
  static Future<bool> getUserDetailFromPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("id")) {
      AppUser.sharedInstance.id = prefs.getInt("id")!;
      AppUser.sharedInstance.contact = prefs.getString("contact")!;
      AppUser.sharedInstance.name = prefs.getString("name")!;
      AppUser.sharedInstance.location = prefs.getString("vendor_location")!;
      AppUser.sharedInstance.user_type = prefs.getInt("user_type")!;
      AppUser.sharedInstance.email = prefs.getString("email")!;

      return true;
    }
    return false;
  }

  static Future<void> isFirstTimeOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("isOpenFirstTime")) {
    } else {
      // AnalyticsHelper.sendEvent('category_detail', null);
      prefs.setString("isOpenFirstTime", "1");
    }
  }

  static Future<void> setCameraPermissionPopupStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("camera_permission")) {
      prefs.setString("camera_permission", "1");
    } else {
      // AnalyticsHelper.sendEvent('category_detail', null);
      prefs.setString("camera_permission", "1");
    }
  }

  static Future<String> getCameraPermissionPopupStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("camera_permission")) {
      return prefs.getString("camera_permission") ?? "";
    }
    return "";
  }

  static Future<void> setGooglePermissionPopupStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("google_permission")) {
    } else {
      // AnalyticsHelper.sendEvent('category_detail', null);
      prefs.setString("google_permission", "1");
    }
  }

  static Future<String> getGooglePermissionPopupStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("google_permission")) {
      return prefs.getString("google_permission") ?? "";
    }
    return "";
  }

  static Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("language")) {
      return prefs.getString("language") ?? "";
    }
    return "";
  }

  static Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<void> setUserDetailInPreference(AppUser objUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("id", objUser.id);
    prefs.setString("contact", objUser.contact);
    prefs.setString("name", objUser.name);
    prefs.setString("vendor_location", objUser.location);
    prefs.setInt("user_type", objUser.user_type);
    prefs.setString("email", objUser.email);
  }

  static Future<void> setLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", language);
  }

  static Future<void> setBaseURL(String baseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("base_url", baseUrl);
  }

  static Future<String> getBaseURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("base_url")) {
      return prefs.getString("base_url") ?? "";
    }
    return "";
  }
}
