import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lenderly_dialer/commons/services/environment_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late http.Client _client;
  String? _authToken;

  void initialize() {
    _client = http.Client();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(EnvironmentConfig.getFullUrl(endpoint));

    if (EnvironmentConfig.enableLogging) {
      print('GET: $url');
    }

    try {
      final response = await _client
          .get(url, headers: {..._defaultHeaders, ...?headers})
          .timeout(Duration(milliseconds: EnvironmentConfig.apiTimeout));

      if (EnvironmentConfig.enableLogging) {
        print('Response: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('GET Error: $e');
      }
      rethrow;
    }
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(EnvironmentConfig.getFullUrl(endpoint));

    if (EnvironmentConfig.enableLogging) {
      print('POST: $url');
      print('Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .post(
            url,
            headers: {..._defaultHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(milliseconds: EnvironmentConfig.apiTimeout));

      if (EnvironmentConfig.enableLogging) {
        print('Response: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('POST Error: $e');
      }
      rethrow;
    }
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(EnvironmentConfig.getFullUrl(endpoint));

    if (EnvironmentConfig.enableLogging) {
      print('PUT: $url');
      print('Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .put(
            url,
            headers: {..._defaultHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(milliseconds: EnvironmentConfig.apiTimeout));

      if (EnvironmentConfig.enableLogging) {
        print('Response: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('PUT Error: $e');
      }
      rethrow;
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(EnvironmentConfig.getFullUrl(endpoint));

    if (EnvironmentConfig.enableLogging) {
      print('DELETE: $url');
    }

    try {
      final response = await _client
          .delete(url, headers: {..._defaultHeaders, ...?headers})
          .timeout(Duration(milliseconds: EnvironmentConfig.apiTimeout));

      if (EnvironmentConfig.enableLogging) {
        print('Response: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('DELETE Error: $e');
      }
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
