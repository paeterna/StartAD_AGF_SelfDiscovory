import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Local preferences service for persisting simple key-value data
class LocalPrefs {
  LocalPrefs(this._prefs);

  final SharedPreferences _prefs;

  // Locale
  Future<void> setLocale(String locale) async {
    await _prefs.setString(AppConstants.storageKeyLocale, locale);
  }

  String? getLocale() {
    return _prefs.getString(AppConstants.storageKeyLocale);
  }

  // Theme
  Future<void> setTheme(String theme) async {
    await _prefs.setString(AppConstants.storageKeyTheme, theme);
  }

  String? getTheme() {
    return _prefs.getString(AppConstants.storageKeyTheme);
  }

  // User ID
  Future<void> setUserId(String userId) async {
    await _prefs.setString(AppConstants.storageKeyUserId, userId);
  }

  String? getUserId() {
    return _prefs.getString(AppConstants.storageKeyUserId);
  }

  Future<void> clearUserId() async {
    await _prefs.remove(AppConstants.storageKeyUserId);
  }

  // Onboarding
  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(AppConstants.storageKeyOnboarding, complete);
  }

  bool getOnboardingComplete() {
    return _prefs.getBool(AppConstants.storageKeyOnboarding) ?? false;
  }

  // Generic string operations
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Clear all
  Future<void> clear() async {
    await _prefs.clear();
  }
}
