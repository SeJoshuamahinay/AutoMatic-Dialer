import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';

class SharedPrefsStorageService {
  static const String _userSessionKey = 'user_session';
  static const String _authTokenKey = 'auth_token';
  static const String _userCredentialsKey = 'user_credentials';
  static const String _rememberMeKey = 'remember_me';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance, initializing if needed
  static Future<SharedPreferences> get _instance async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  /// Save user session to SharedPreferences
  static Future<void> saveUserSession(UserSession userSession) async {
    try {
      final prefs = await _instance;
      final jsonString = jsonEncode(userSession.toJson());

      await prefs.setString(_userSessionKey, jsonString);

      // Also save token separately for quick access
      if (userSession.token != null) {
        await prefs.setString(_authTokenKey, userSession.token!);
      }

      if (EnvironmentConfig.enableLogging) {}
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
      throw Exception('Failed to save user session: $e');
    }
  }

  /// Get user session from SharedPreferences
  static Future<UserSession?> getUserSession() async {
    try {
      final prefs = await _instance;
      final jsonString = prefs.getString(_userSessionKey);

      if (jsonString == null) {
        if (EnvironmentConfig.enableLogging) {}
        return null;
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final userSession = UserSession.fromJson(jsonData);

      if (EnvironmentConfig.enableLogging) {}

      return userSession;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
      return null;
    }
  }

  /// Get auth token directly
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_authTokenKey);
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
      return null;
    }
  }

  /// Save user credentials for "Remember Me" functionality
  static Future<void> saveUserCredentials({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final prefs = await _instance;

      if (rememberMe) {
        final credentials = {
          'email': email,
          'password': password, // In production, consider encrypting this
          'saved_at': DateTime.now().toIso8601String(),
        };

        await prefs.setString(_userCredentialsKey, jsonEncode(credentials));
        await prefs.setBool(_rememberMeKey, true);

        if (EnvironmentConfig.enableLogging) {}
      } else {
        // Clear saved credentials if remember me is disabled
        await clearUserCredentials();
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
    }
  }

  /// Get saved user credentials
  static Future<Map<String, String>?> getUserCredentials() async {
    try {
      final prefs = await _instance;
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (!rememberMe) return null;

      final credentialsString = prefs.getString(_userCredentialsKey);
      if (credentialsString == null) return null;

      final credentials = jsonDecode(credentialsString) as Map<String, dynamic>;

      return {
        'email': credentials['email'] as String,
        'password': credentials['password'] as String,
      };
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
      return null;
    }
  }

  /// Check if remember me is enabled
  static Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await _instance;
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear user session
  static Future<void> clearUserSession() async {
    try {
      final prefs = await _instance;
      await prefs.remove(_userSessionKey);
      await prefs.remove(_authTokenKey);

      if (EnvironmentConfig.enableLogging) {}
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
    }
  }

  /// Clear user credentials
  static Future<void> clearUserCredentials() async {
    try {
      final prefs = await _instance;
      await prefs.remove(_userCredentialsKey);
      await prefs.remove(_rememberMeKey);

      if (EnvironmentConfig.enableLogging) {}
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
    }
  }

  /// Clear all authentication data
  static Future<void> clearAll() async {
    try {
      await clearUserSession();
      await clearUserCredentials();

      if (EnvironmentConfig.enableLogging) {}
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {}
    }
  }

  /// Check if user session exists
  static Future<bool> hasUserSession() async {
    try {
      final prefs = await _instance;
      return prefs.containsKey(_userSessionKey);
    } catch (e) {
      return false;
    }
  }

  /// Check if auth token exists
  static Future<bool> hasAuthToken() async {
    try {
      final prefs = await _instance;
      return prefs.containsKey(_authTokenKey);
    } catch (e) {
      return false;
    }
  }

  /// Get all stored keys (for debugging)
  static Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await _instance;
      return prefs.getKeys();
    } catch (e) {
      return <String>{};
    }
  }

  /// Debug method to print all stored data
  static Future<void> debugPrintAll() async {
    if (!EnvironmentConfig.enableLogging) return;

    try {
      final prefs = await _instance;
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.contains('user') ||
            key.contains('auth') ||
            key.contains('remember')) {
          final value = prefs.get(key);
          if (key.contains('password')) {
          } else if (key.contains('token')) {
            final tokenStr = value.toString();
          } else {}
        }
      }
    } catch (e) {}
  }
}
