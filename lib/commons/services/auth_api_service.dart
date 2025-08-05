import 'package:dio/dio.dart';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

  late Dio _dio;

  Future<void> initialize() async {
    await SharedPrefsStorageService.initialize();
    _dio = Dio();

    // Setup default options
    _dio.options = BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: EnvironmentConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: EnvironmentConfig.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add request interceptor to include Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get current user session to add Authorization header
          final userSession = await SharedPrefsStorageService.getUserSession();
          if (userSession?.token != null) {
            options.headers['Authorization'] = 'Bearer ${userSession!.token}';
          }
          handler.next(options);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (EnvironmentConfig.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }

  /// Login with email and password
  Future<LoginResponse> login(LoginRequest request) async {
    if (EnvironmentConfig.enableLogging) {
      print('AUTH API: Login request to ${EnvironmentConfig.authEndpoint}');
    }

    try {
      final response = await _dio.post(
        EnvironmentConfig.authEndpoint,
        data: request.toJson(),
      );

      if (EnvironmentConfig.enableLogging) {
        print(
          'AUTH API: Login response: ${response.statusCode} - ${response.data}',
        );
      }

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Login error: ${e.message}');
      }

      if (e.response != null) {
        // Handle validation errors (422) and other HTTP errors
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          String errorMessage = responseData['message'] ?? 'Login failed';

          // Handle validation errors
          if (e.response!.statusCode == 422 && responseData['errors'] != null) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              }
            });
            errorMessage = errorMessages.join(', ');
          }

          return LoginResponse(success: false, message: errorMessage);
        }
      }

      return LoginResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Unexpected login error: $e');
      }
      return LoginResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Get current user information
  Future<UserInfoResponse> getUserInfo() async {
    if (EnvironmentConfig.enableLogging) {
      print(
        'AUTH API: Get user info request to ${EnvironmentConfig.userInfoEndpoint}',
      );
    }

    try {
      final response = await _dio.get(EnvironmentConfig.userInfoEndpoint);

      if (EnvironmentConfig.enableLogging) {
        print(
          'AUTH API: Get user info response: ${response.statusCode} - ${response.data}',
        );
      }

      return UserInfoResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Get user info error: ${e.message}');
      }

      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        return UserInfoResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get user info',
        );
      }

      return UserInfoResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Unexpected get user info error: $e');
      }
      return UserInfoResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Logout user
  Future<LogoutResponse> logout() async {
    if (EnvironmentConfig.enableLogging) {
      print('AUTH API: Logout request to ${EnvironmentConfig.logoutEndpoint}');
    }

    try {
      final response = await _dio.post(EnvironmentConfig.logoutEndpoint);

      if (EnvironmentConfig.enableLogging) {
        print(
          'AUTH API: Logout response: ${response.statusCode} - ${response.data}',
        );
      }

      // No need to clear cookies for token-based auth
      return LogoutResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Logout error: ${e.message}');
      }

      // No need to clear cookies for token-based auth
      // Token invalidation is handled by the server

      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        return LogoutResponse(
          success: false,
          message: responseData['message'] ?? 'Logout failed',
        );
      }

      return LogoutResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Unexpected logout error: $e');
      }

      // No need to clear cookies for token-based auth
      // Token cleanup is handled by the server

      return LogoutResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Logout from all devices
  Future<LogoutResponse> logoutAll() async {
    if (EnvironmentConfig.enableLogging) {
      print(
        'AUTH API: Logout all request to ${EnvironmentConfig.logoutAllEndpoint}',
      );
    }

    try {
      final response = await _dio.post(EnvironmentConfig.logoutAllEndpoint);

      if (EnvironmentConfig.enableLogging) {
        print(
          'AUTH API: Logout all response: ${response.statusCode} - ${response.data}',
        );
      }

      return LogoutResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Logout all error: ${e.message}');
      }

      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        return LogoutResponse(
          success: false,
          message: responseData['message'] ?? 'Logout all failed',
        );
      }

      return LogoutResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Unexpected logout all error: $e');
      }

      return LogoutResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Refresh the current token
  Future<RefreshTokenResponse> refreshToken({String? deviceName}) async {
    if (EnvironmentConfig.enableLogging) {
      print(
        'AUTH API: Refresh token request to ${EnvironmentConfig.refreshEndpoint}',
      );
    }

    try {
      final requestData = <String, dynamic>{};
      if (deviceName != null) {
        requestData['device_name'] = deviceName;
      }

      final response = await _dio.post(
        EnvironmentConfig.refreshEndpoint,
        data: requestData.isNotEmpty ? requestData : null,
      );

      if (EnvironmentConfig.enableLogging) {
        print(
          'AUTH API: Refresh token response: ${response.statusCode} - ${response.data}',
        );
      }

      return RefreshTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Refresh token error: ${e.message}');
      }

      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        return RefreshTokenResponse(
          success: false,
          message: responseData['message'] ?? 'Token refresh failed',
        );
      }

      return RefreshTokenResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Unexpected refresh token error: $e');
      }

      return RefreshTokenResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Verify current session
  Future<VerifyResponse> verifySession() async {
    if (EnvironmentConfig.enableLogging) {
      print(
        'AUTH API: Verify session request to ${EnvironmentConfig.verifyEndpoint}',
      );
    }

    try {
      final response = await _dio.get(EnvironmentConfig.verifyEndpoint);

      if (EnvironmentConfig.enableLogging) {
        print(
          'AUTH API: Verify session response: ${response.statusCode} - ${response.data}',
        );
      }

      return VerifyResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Verify session error: ${e.message}');
      }

      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        return VerifyResponse(
          success: false,
          message: responseData['message'] ?? 'Session verification failed',
          authenticated: false,
        );
      }

      return VerifyResponse(
        success: false,
        message: 'Network error: ${e.message}',
        authenticated: false,
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('AUTH API: Unexpected verify session error: $e');
      }
      return VerifyResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
        authenticated: false,
      );
    }
  }

  /// Clear session data (for complete logout/reset)
  Future<void> clearSession() async {
    // For token-based auth, the token is stored in secure storage
    // and managed by SecureStorageService, not cookies
    // This method exists for API compatibility
  }

  void dispose() {
    _dio.close();
  }
}
