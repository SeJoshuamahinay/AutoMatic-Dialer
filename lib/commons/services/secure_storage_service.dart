import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _userSessionKey = 'user_session';

  /// Save user session information
  Future<void> saveUserSession(UserSession userSession) async {
    try {
      await _storage.write(
        key: _userSessionKey,
        value: jsonEncode(userSession.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to save user session: $e');
    }
  }

  /// Get user session information
  Future<UserSession?> getUserSession() async {
    try {
      final userSessionJson = await _storage.read(key: _userSessionKey);
      if (userSessionJson == null) return null;

      final userSessionMap =
          jsonDecode(userSessionJson) as Map<String, dynamic>;
      return UserSession.fromJson(userSessionMap);
    } catch (e) {
      // If there's an error reading, clear the corrupted data
      await clearUserSession();
      return null;
    }
  }

  /// Update user session with new data
  Future<void> updateUserSession(UserSession userSession) async {
    try {
      await saveUserSession(userSession);
    } catch (e) {
      throw Exception('Failed to update user session: $e');
    }
  }

  /// Clear user session information
  Future<void> clearUserSession() async {
    try {
      await _storage.delete(key: _userSessionKey);
    } catch (e) {
      // Even if there's an error, try to clear what we can
      try {
        await _storage.deleteAll();
      } catch (e) {
        // Log error but don't throw - clearing is a cleanup operation
      }
    }
  }

  /// Get auth token from stored user session
  Future<String?> getAuthToken() async {
    try {
      final userSession = await getUserSession();
      return userSession?.token;
    } catch (e) {
      return null;
    }
  }

  /// Check if user session exists
  Future<bool> hasUserSession() async {
    try {
      final userSession = await _storage.read(key: _userSessionKey);
      return userSession != null;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored data (for logout or app reset)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}
