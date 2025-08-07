import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/secure_storage_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class AuthApiService {
  static const int timeoutSeconds = 30;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Login with email/password to get Bearer token
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // Fallback URL construction if environment is not loaded properly
      String baseUrl = EnvironmentConfig.apiBaseUrl;
      String endpoint = EnvironmentConfig.authEndpoint;
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(responseData);

        // Save user session if login is successful
        if (loginResponse.success &&
            loginResponse.userData != null &&
            loginResponse.token != null) {
          print('Login successful, saving user session...');

          // Create user session
          final userSession = UserSession.fromUserData(
            loginResponse.userData!,
            token: loginResponse.token,
          );

          // Save to SharedPreferences
          await SharedPrefsStorageService.saveUserSession(userSession);

          print('User session saved successfully');
          print('User: ${userSession.fullName} (${userSession.email})');
          print('Token: ${userSession.token?.substring(0, 20)}...');
        }

        return loginResponse;
      } else if (response.statusCode == 422) {
        // Validation errors
        final errors = responseData['errors'] as Map<String, dynamic>?;
        String errorMessage = 'Validation failed';

        if (errors != null) {
          final allErrors = <String>[];
          errors.forEach((field, messages) {
            if (messages is List) {
              allErrors.addAll(messages.cast<String>());
            }
          });
          errorMessage = allErrors.join(', ');
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        return LoginResponse(success: false, message: errorMessage);
      } else if (response.statusCode == 401) {
        return LoginResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid credentials',
        );
      } else {
        return LoginResponse(
          success: false,
          message: responseData['message'] ?? 'Login failed',
        );
      }
    } on SocketException {
      return LoginResponse(
        success: false,
        message:
            'Cannot connect to server. Is the server running at ${EnvironmentConfig.apiBaseUrl}?',
      );
    } on http.ClientException {
      return LoginResponse(
        success: false,
        message: 'Network error: Connection timeout or client error',
      );
    } on FormatException {
      return LoginResponse(
        success: false,
        message: 'Invalid server response format',
      );
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  /// Get user info using Bearer token
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final url = Uri.parse(
        '${EnvironmentConfig.apiBaseUrl}${EnvironmentConfig.userInfoEndpoint}',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token expired or invalid',
          'tokenExpired': true,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user info',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting user info: ${e.toString()}',
      };
    }
  }

  /// Logout from current device
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        return {'success': true, 'message': 'Already logged out'};
      }

      final url = Uri.parse('${EnvironmentConfig.apiBaseUrl}/logout');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 401) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logged out successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Logout failed',
        };
      }
    } catch (e) {
      // Even if logout fails on server, we should clear local tokens
      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  /// Logout from all devices
  Future<Map<String, dynamic>> logoutAll() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        return {'success': true, 'message': 'Already logged out'};
      }

      final url = Uri.parse('${EnvironmentConfig.apiBaseUrl}/logout-all');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 401) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logged out from all devices',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Logout all failed',
        };
      }
    } catch (e) {
      // Even if logout fails on server, we should clear local tokens
      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  /// Verify if current token is valid
  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final url = Uri.parse('${EnvironmentConfig.apiBaseUrl}/verify');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Token is valid',
          'data': responseData,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token expired or invalid',
          'tokenExpired': true,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Token verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying token: ${e.toString()}',
      };
    }
  }

  /// Test server connectivity
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse('${EnvironmentConfig.apiBaseUrl}/api/health');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200
            ? 'Server is reachable'
            : 'Server returned ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server: ${e.toString()}',
      };
    }
  }

  /// Create login request with device name
  LoginRequest createLoginRequest(
    String email,
    String password, {
    String? deviceName,
  }) {
    return LoginRequest(
      email: email,
      password: password,
      deviceName: deviceName ?? EnvironmentConfig.defaultDeviceName,
    );
  }
}
