// lib/core/shared_preferences/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _roleKey = 'userRole';
  static const String _userJsonKey = 'userJson';
  static const String _themeModeKey = 'themeMode';

  PreferencesService(this._prefs, this._secureStorage);

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> saveUserRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  String? getUserRole() {
    return _prefs.getString(_roleKey);
  }

  Future<void> saveUserJson(String json) async {
    await _prefs.setString(_userJsonKey, json);
  }

  String? getUserJson() {
    return _prefs.getString(_userJsonKey);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_userJsonKey);
  }
}
