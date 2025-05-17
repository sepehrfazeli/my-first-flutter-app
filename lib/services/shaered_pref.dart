import 'package:shared_preferences/shared_preferences.dart';

class ShaeredPreferenceHelper {
  static String userNameKey = "USERNAMEKEY";

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
