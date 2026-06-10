import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'environment_config.dart';
import 'shared_prefs_storage_service.dart';

/// Thrown when the server responds with 302 or 401.
/// Navigation to /login is already handled by ApiClient before throwing.
class AuthSessionExpiredException implements Exception {
  const AuthSessionExpiredException();
}

/// Thrown when the server rejects the request due to an outdated app version.
class AppVersionOutdatedException implements Exception {
  final String minVersion;
  const AppVersionOutdatedException(this.minVersion);
  @override
  String toString() => 'App version outdated. Minimum required: $minVersion';
}

/// Centralized HTTP client.
/// Automatically attaches Bearer token and handles session expiry globally.
class ApiClient {
  /// Provide this to MaterialApp's navigatorKey so ApiClient can navigate.
  static final navigatorKey = GlobalKey<NavigatorState>();

  // ── GET ────────────────────────────────────────────────────────────────────

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? extraHeaders,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final token = await SharedPrefsStorageService.getAuthToken();
    final baseUrl = EnvironmentConfig.apiBaseUrl;
    final response = await http
        .get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'X-App-Version': AppConfig.version,
            ...?extraHeaders,
          },
        )
        .timeout(timeout);
    await _checkAuth(response);
    return response;
  }

  // ── POST ───────────────────────────────────────────────────────────────────

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final token = await SharedPrefsStorageService.getAuthToken();
    final baseUrl = EnvironmentConfig.apiBaseUrl;
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'X-App-Version': AppConfig.version,
            ...?extraHeaders,
          },
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
    await _checkAuth(response);
    return response;
  }

  // ── PUT ────────────────────────────────────────────────────────────────────

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final token = await SharedPrefsStorageService.getAuthToken();
    final baseUrl = EnvironmentConfig.apiBaseUrl;
    final response = await http
        .put(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'X-App-Version': AppConfig.version,
            ...?extraHeaders,
          },
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
    await _checkAuth(response);
    return response;
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _checkAuth(http.Response response) async {
    // ── Version outdated ──────────────────────────────────────────────────
    if (response.body.isNotEmpty) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == false && body['min_version'] != null) {
          final minVersion = body['min_version'].toString();
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            showDialog<void>(
              context: ctx,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('Update Required'),
                content: Text(
                  'Your app version (${AppConfig.version}) is outdated.\n'
                  'Please update to v$minVersion or higher to continue.',
                ),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('OK')),
                ],
              ),
            );
          }
          throw AppVersionOutdatedException(minVersion);
        }
      } on AppVersionOutdatedException {
        rethrow;
      } catch (_) {
        // Body is not JSON or doesn't match the version-outdated shape — ignore.
      }
    }

    // ── Session expired ───────────────────────────────────────────────────
    if (response.statusCode == 302 || response.statusCode == 401) {
      await SharedPrefsStorageService.clearUserSession();
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (_) => false,
      );
      throw const AuthSessionExpiredException();
    }
  }
}
