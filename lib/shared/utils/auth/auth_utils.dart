import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soxo_chat/feature/auth/domain/models/auth_res/auth_response.dart';

class AuthUtils {
  AuthUtils._();
  static AuthUtils? _instance;
  static final AuthUtils instance = (_instance ??= AuthUtils._());

  Future<void> writeUserData(AuthResponse user) async {
    await _writePreference('result', jsonEncode(user.toJson()));
  }

  Future<AuthResponse?> readUserData() async {
    final String? userData = await _readPreference('result');
    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      return AuthResponse.fromJson(userMap);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _clearPreference('result');
  }

  Future<void> _clearPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> writeAccessTokens(String token) async {
    await _writePreference('jwtToken', token);
  }

  Future<String?> get readAccessToken async {
    return await _readPreference('jwtToken');
  }

  Future<void> writeRefreshTokens(String token) async {
    await _writePreference('refresh_token', token);
  }

  Future<String?> get readRefreshTokens async {
    return await _readPreference('refresh_token');
  }

  Future<bool> get isSignedIn async {
    final String? token = await _readPreference('jwtToken');
    return token != null;
  }

  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Debug: Check if anything left behind
    final remainingKeys = prefs.getKeys();
    if (remainingKeys.isNotEmpty) {
      log(
        "SharedPreferences not cleared fully. Keys still present: $remainingKeys",
      );
    } else {
      log("All SharedPreferences successfully cleared.");
    }
  }

  Future<void> _writePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _readPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
