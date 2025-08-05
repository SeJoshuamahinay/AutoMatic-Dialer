import 'dart:convert';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';

/// Mock implementation of SharedPrefsStorageService for testing
/// This avoids the MissingPluginException that occurs when running unit tests
class MockSharedPrefsStorageService {
  static final Map<String, dynamic> _mockStorage = {};

  static const String _userSessionKey = 'user_session';
  static const String _authTokenKey = 'auth_token';
  static const String _userCredentialsKey = 'user_credentials';
  static const String _rememberMeKey = 'remember_me';

  /// Initialize mock storage (no-op for mock)
  static Future<void> initialize() async {
    // No initialization needed for mock
  }

  /// Save user session to mock storage
  static Future<void> saveUserSession(UserSession userSession) async {
    try {
      final jsonString = jsonEncode(userSession.toJson());

      _mockStorage[_userSessionKey] = jsonString;

      // Also save token separately for quick access
      if (userSession.token != null) {
        _mockStorage[_authTokenKey] = userSession.token!;
      }

      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: User session saved successfully');
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to save user session: $e');
      }
      throw Exception('Failed to save user session: $e');
    }
  }

  /// Get user session from mock storage
  static Future<UserSession?> getUserSession() async {
    try {
      final jsonString = _mockStorage[_userSessionKey] as String?;

      if (jsonString == null) {
        if (EnvironmentConfig.enableLogging) {
          print('MockSharedPrefs: No user session found');
        }
        return null;
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final userSession = UserSession.fromJson(jsonData);

      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: User session retrieved successfully');
      }

      return userSession;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to get user session: $e');
      }
      return null;
    }
  }

  /// Get auth token directly
  static Future<String?> getAuthToken() async {
    try {
      return _mockStorage[_authTokenKey] as String?;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to get auth token: $e');
      }
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
      if (rememberMe) {
        final credentials = {
          'email': email,
          'password': password,
          'saved_at': DateTime.now().toIso8601String(),
        };

        _mockStorage[_userCredentialsKey] = jsonEncode(credentials);
        _mockStorage[_rememberMeKey] = true;

        if (EnvironmentConfig.enableLogging) {
          print('MockSharedPrefs: User credentials saved for remember me');
        }
      } else {
        // Clear saved credentials if remember me is disabled
        await clearUserCredentials();
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to save user credentials: $e');
      }
    }
  }

  /// Get saved user credentials
  static Future<Map<String, String>?> getUserCredentials() async {
    try {
      final rememberMe = _mockStorage[_rememberMeKey] as bool? ?? false;

      if (!rememberMe) return null;

      final credentialsString = _mockStorage[_userCredentialsKey] as String?;
      if (credentialsString == null) return null;

      final credentials = jsonDecode(credentialsString) as Map<String, dynamic>;

      return {
        'email': credentials['email'] as String,
        'password': credentials['password'] as String,
      };
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to get user credentials: $e');
      }
      return null;
    }
  }

  /// Check if remember me is enabled
  static Future<bool> isRememberMeEnabled() async {
    try {
      return _mockStorage[_rememberMeKey] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear user session
  static Future<void> clearUserSession() async {
    try {
      _mockStorage.remove(_userSessionKey);
      _mockStorage.remove(_authTokenKey);

      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: User session cleared');
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to clear user session: $e');
      }
    }
  }

  /// Clear user credentials
  static Future<void> clearUserCredentials() async {
    try {
      _mockStorage.remove(_userCredentialsKey);
      _mockStorage.remove(_rememberMeKey);

      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: User credentials cleared');
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to clear user credentials: $e');
      }
    }
  }

  /// Clear all authentication data
  static Future<void> clearAll() async {
    try {
      await clearUserSession();
      await clearUserCredentials();

      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: All authentication data cleared');
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockSharedPrefs: Failed to clear all data: $e');
      }
    }
  }

  /// Check if user session exists
  static Future<bool> hasUserSession() async {
    try {
      return _mockStorage.containsKey(_userSessionKey);
    } catch (e) {
      return false;
    }
  }

  /// Check if auth token exists
  static Future<bool> hasAuthToken() async {
    try {
      return _mockStorage.containsKey(_authTokenKey);
    } catch (e) {
      return false;
    }
  }

  /// Get all stored keys (for debugging)
  static Future<Set<String>> getAllKeys() async {
    try {
      return _mockStorage.keys.toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Debug method to print all stored data
  static Future<void> debugPrintAll() async {
    if (!EnvironmentConfig.enableLogging) return;

    try {
      print('MockSharedPrefs Debug:');
      for (final key in _mockStorage.keys) {
        if (key.contains('user') ||
            key.contains('auth') ||
            key.contains('remember')) {
          final value = _mockStorage[key];
          if (key.contains('password')) {
            print('  $key: [HIDDEN]');
          } else if (key.contains('token')) {
            final tokenStr = value.toString();
            print(
              '  $key: ${tokenStr.length > 20 ? '${tokenStr.substring(0, 20)}...' : tokenStr}',
            );
          } else {
            print('  $key: $value');
          }
        }
      }
    } catch (e) {
      print('MockSharedPrefs Debug failed: $e');
    }
  }

  /// Clear all mock storage (for testing)
  static void clearMockStorage() {
    _mockStorage.clear();
  }
}
