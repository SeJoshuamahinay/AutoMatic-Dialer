import 'dart:async';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/auth_api_service.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';

class LoginResult {
  final bool success;
  final String message;
  final String?
  token; // For backward compatibility - will be null for session-based auth
  final String? username;

  LoginResult({
    required this.success,
    required this.message,
    this.token,
    this.username,
  });
}

class LoginService {
  final AuthApiService _authApiService = AuthApiService();
  final StreamController<bool> _authStatusController =
      StreamController<bool>.broadcast();

  // In-memory state for bypass login when storage is unavailable
  UserSession? _bypassSession;

  Stream<bool> get authStatusStream => _authStatusController.stream;

  LoginService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authApiService.initialize();
    await SharedPrefsStorageService.initialize();
  }

  /// Login with email and password
  Future<LoginResult> login({
    required String identifier,
    String? password,
    bool isTokenLogin = false, // Kept for backward compatibility but not used
    bool rememberMe = false, // Add Remember Me functionality
  }) async {
    try {
      // Validate input
      if (identifier.trim().isEmpty) {
        return LoginResult(success: false, message: 'Please enter email');
      }

      if (password?.trim().isEmpty ?? true) {
        return LoginResult(success: false, message: 'Please enter password');
      }

      // Check for bypass credentials (ITDepartment)
      if (identifier.toLowerCase() == 'itdepartment' &&
          password == 'password') {
        return await _handleBypassLogin(identifier);
      }

      // Create login request for normal API flow with device name
      final loginRequest = LoginRequest(
        email: identifier,
        password: password!,
        deviceName: EnvironmentConfig.defaultDeviceName,
      );

      // Make API call
      final loginResponse = await _authApiService.login(loginRequest);

      if (loginResponse.success &&
          loginResponse.userData != null &&
          loginResponse.token != null) {
        // Create user session with token
        final userSession = UserSession.fromUserData(
          loginResponse.userData!,
          token: loginResponse.token,
        );

        // Save user session securely with SharedPreferences
        await SharedPrefsStorageService.saveUserSession(userSession);

        // Save credentials for Remember Me if enabled
        if (rememberMe) {
          await SharedPrefsStorageService.saveUserCredentials(
            email: identifier,
            password: password,
            rememberMe: true,
          );
        }

        // Notify listeners
        _authStatusController.add(true);

        return LoginResult(
          success: true,
          message: loginResponse.message,
          token: loginResponse.token, // For backward compatibility
          username: userSession.fullName,
        );
      } else {
        return LoginResult(success: false, message: loginResponse.message);
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Login error: $e');
      }

      // Return a user-friendly error message
      return LoginResult(
        success: false,
        message: 'Login failed. Please check your connection and try again.',
      );
    }
  }

  /// Handle bypass login for ITDepartment
  Future<LoginResult> _handleBypassLogin(String identifier) async {
    try {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Using bypass login for $identifier');
      }

      // Create a mock user session for bypass login
      final userSession = UserSession(
        userId: 999,
        email: identifier,
        fullName: 'IT Department',
        loginType: 'bypass',
        loginTime: DateTime.now(),
      );

      // Try to save user session securely, but don't fail if storage is unavailable
      try {
        await SharedPrefsStorageService.saveUserSession(userSession);
        if (EnvironmentConfig.enableLogging) {
          print('LoginService: Bypass session saved to SharedPreferences');
        }
      } catch (storageError) {
        if (EnvironmentConfig.enableLogging) {
          print(
            'LoginService: SharedPrefs unavailable for bypass login, using in-memory state: $storageError',
          );
        }
        // Store in memory when shared preferences is unavailable
        _bypassSession = userSession;
      }

      // Notify listeners
      _authStatusController.add(true);

      return LoginResult(
        success: true,
        message: 'Bypass login successful',
        username: userSession.fullName,
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Bypass login error: $e');
      }
      return LoginResult(
        success: false,
        message: 'Bypass login failed: ${e.toString()}',
      );
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      // First check for in-memory bypass session (when storage is unavailable)
      if (_bypassSession != null && _bypassSession!.loginType == 'bypass') {
        if (EnvironmentConfig.enableLogging) {
          print('LoginService: In-memory bypass session detected');
        }
        return true;
      }

      // Then check if we have a local session in SharedPreferences
      final userSession = await SharedPrefsStorageService.getUserSession();
      if (userSession == null) return false;

      // If it's a bypass login, skip server verification
      if (userSession.loginType == 'bypass') {
        if (EnvironmentConfig.enableLogging) {
          print(
            'LoginService: Bypass session detected, skipping server verification',
          );
        }
        return true;
      }

      // For token-based auth, check if token is still valid locally first
      if (!userSession.hasValidToken) {
        if (EnvironmentConfig.enableLogging) {
          print('LoginService: Token expired locally');
        }
        await _clearLocalSession();
        return false;
      }

      // Auto-refresh token if needed
      await ensureValidToken();

      // Verify token with server
      final verifyResponse = await _authApiService.verifySession();

      if (verifyResponse.success) {
        return true;
      } else {
        // Clear invalid session
        await _clearLocalSession();
        return false;
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Authentication check error: $e');
      }
      return false;
    }
  }

  /// Get current user information (deprecated - use getCurrentUserSession)
  Map<String, dynamic>? getCurrentUser() {
    // This is called synchronously, so we'll return null
    // Use getCurrentUserSession() for async operations
    return null;
  }

  /// Get current user session (async)
  Future<UserSession?> getCurrentUserSession() async {
    try {
      // First check for in-memory bypass session
      if (_bypassSession != null) {
        return _bypassSession;
      }

      return await SharedPrefsStorageService.getUserSession();
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Get current user session error: $e');
      }
      // Return in-memory bypass session if storage fails but bypass is active
      return _bypassSession;
    }
  }

  /// Get current user info from server
  Future<UserData?> getCurrentUserInfo() async {
    try {
      // Check if it's an in-memory bypass session first
      if (_bypassSession?.loginType == 'bypass') {
        if (EnvironmentConfig.enableLogging) {
          print(
            'LoginService: In-memory bypass session, returning mock user data',
          );
        }
        return UserData(
          id: _bypassSession!.userId,
          email: _bypassSession!.email,
          firstName: 'IT',
          lastName: 'Department',
          loginType: 'bypass',
        );
      }

      // Check if it's a stored bypass session
      final userSession = await SharedPrefsStorageService.getUserSession();
      if (userSession?.loginType == 'bypass') {
        if (EnvironmentConfig.enableLogging) {
          print('LoginService: Bypass session, returning mock user data');
        }
        // Return mock UserData for bypass session
        return UserData(
          id: userSession!.userId,
          email: userSession.email,
          firstName: 'IT',
          lastName: 'Department',
          loginType: 'bypass',
        );
      }

      // Get user info from server for normal sessions
      final userInfoResponse = await _authApiService.getUserInfo();
      if (userInfoResponse.success && userInfoResponse.userData != null) {
        // Update local session with fresh data
        final updatedUserSession = UserSession.fromUserData(
          userInfoResponse.userData!,
        );
        await SharedPrefsStorageService.saveUserSession(updatedUserSession);
        return userInfoResponse.userData;
      }
      return null;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Get current user info error: $e');
      }
      return null;
    }
  }

  /// Get current username
  Future<String?> getCurrentUsername() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      return userSession?.fullName;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Get current username error: $e');
      }
      return null;
    }
  }

  /// Get current user email
  Future<String?> getCurrentUserEmail() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      return userSession?.email;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Get current user email error: $e');
      }
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call logout API
      final logoutResponse = await _authApiService.logout();

      if (EnvironmentConfig.enableLogging) {
        if (logoutResponse.success) {
          print('LoginService: Logout successful');
        } else {
          print('LoginService: Logout API failed: ${logoutResponse.message}');
        }
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Logout API error: $e');
      }
      // Continue with local logout even if API call fails
    } finally {
      // Always clear local data
      await _clearLocalSession();
      _authStatusController.add(false);
    }
  }

  /// Logout from all devices
  Future<void> logoutAll() async {
    try {
      // Call logout all API
      final logoutResponse = await _authApiService.logoutAll();

      if (EnvironmentConfig.enableLogging) {
        if (logoutResponse.success) {
          print('LoginService: Logout from all devices successful');
        } else {
          print(
            'LoginService: Logout all API failed: ${logoutResponse.message}',
          );
        }
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Logout all API error: $e');
      }
      // Continue with local logout even if API call fails
    } finally {
      // Always clear local data
      await _clearLocalSession();
      _authStatusController.add(false);
    }
  }

  /// Clear local session data
  Future<void> _clearLocalSession() async {
    await SharedPrefsStorageService.clearUserSession();
    await _authApiService.clearSession();
    _bypassSession = null; // Clear in-memory bypass session
  }

  /// Check if session is valid (verify with server)
  Future<bool> validateSession() async {
    try {
      final verifyResponse = await _authApiService.verifySession();
      return verifyResponse.success && verifyResponse.authenticated;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Session validation error: $e');
      }
      return false;
    }
  }

  /// Get auth token (returns the Bearer token)
  Future<String?> getAuthToken() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      return userSession?.token;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Get auth token error: $e');
      }
      return null;
    }
  }

  /// Refresh token (for Sanctum token-based auth)
  Future<bool> refreshToken() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      if (userSession?.token == null) {
        return false;
      }

      // Skip refresh for bypass sessions
      if (userSession!.loginType == 'bypass') {
        return true;
      }

      final refreshResponse = await _authApiService.refreshToken(
        deviceName: EnvironmentConfig.defaultDeviceName,
      );

      if (refreshResponse.success && refreshResponse.token != null) {
        // Update user session with new token
        final updatedSession = UserSession(
          userId: userSession.userId,
          email: userSession.email,
          fullName: userSession.fullName,
          loginType: userSession.loginType,
          loginTime: userSession.loginTime,
          token: refreshResponse.token,
          tokenExpiresAt: refreshResponse.expiresAt,
        );

        await SharedPrefsStorageService.saveUserSession(updatedSession);
        return true;
      }

      return false;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Token refresh error: $e');
      }
      return false;
    }
  }

  /// Check if token needs refresh
  Future<bool> needsTokenRefresh() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      return userSession?.needsRefresh ?? false;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Check token refresh need error: $e');
      }
      return false;
    }
  }

  /// Auto-refresh token if needed before API calls
  Future<void> ensureValidToken() async {
    try {
      final userSession = await SharedPrefsStorageService.getUserSession();
      if (userSession?.token == null || userSession!.loginType == 'bypass') {
        return; // No token or bypass session
      }

      // Check if token is expired or needs refresh soon
      if (!userSession.hasValidToken || userSession.needsRefresh) {
        if (EnvironmentConfig.enableLogging) {
          print('LoginService: Token needs refresh, attempting auto-refresh');
        }

        final refreshed = await refreshToken();
        if (!refreshed) {
          if (EnvironmentConfig.enableLogging) {
            print('LoginService: Token refresh failed, user needs to re-login');
          }
          // Clear invalid session and notify listeners
          await _clearLocalSession();
          _authStatusController.add(false);
        }
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Ensure valid token error: $e');
      }
    }
  }

  /// Get saved credentials for auto-login
  Future<Map<String, String>?> getSavedCredentials() async {
    return await SharedPrefsStorageService.getUserCredentials();
  }

  /// Check if Remember Me is enabled
  Future<bool> isRememberMeEnabled() async {
    return await SharedPrefsStorageService.isRememberMeEnabled();
  }

  /// Auto-login with saved credentials
  Future<LoginResult> autoLogin() async {
    try {
      final savedCredentials = await getSavedCredentials();
      if (savedCredentials == null) {
        return LoginResult(success: false, message: 'No saved credentials');
      }

      return await login(
        identifier: savedCredentials['email']!,
        password: savedCredentials['password']!,
        rememberMe: true,
      );
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('LoginService: Auto-login error: $e');
      }
      return LoginResult(success: false, message: 'Auto-login failed');
    }
  }

  /// Dispose resources
  void dispose() {
    _authStatusController.close();
    _authApiService.dispose();
  }
}
