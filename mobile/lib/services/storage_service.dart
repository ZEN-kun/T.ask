import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mobile/core/constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUser() {
    final str = _prefs.getString(AppConstants.userKey);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userKey);
  }

  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(AppConstants.rememberMeKey, value);
  }

  bool getRememberMe() {
    return _prefs.getBool(AppConstants.rememberMeKey) ?? true;
  }

  Future<void> setSavedEmail(String email) async {
    await _prefs.setString(AppConstants.savedEmailKey, email);
  }

  String? getSavedEmail() {
    return _prefs.getString(AppConstants.savedEmailKey);
  }
}
