import 'dart:async';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/auth_api_service.dart';
import 'package:lenderly_dialer/commons/services/api_login_service.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'mock_shared_prefs_storage_service.dart';

/// Mock implementation of LoginService for testing
/// Uses MockSharedPrefsStorageService instead of SharedPrefsStorageService
class MockLoginService extends LoginService {
  final AuthApiService _authApiService = AuthApiService();
  final StreamController<bool> _authStatusController =
      StreamController<bool>.broadcast();

  // In-memory state for bypass login when storage is unavailable
  UserSession? _bypassSession;

  @override
  Stream<bool> get authStatusStream => _authStatusController.stream;

  MockLoginService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authApiService.initialize();
    await MockSharedPrefsStorageService.initialize();
  }

  /// Login with email and password
  @override
  Future<LoginResult> login({
    required String identifier,
    String? password,
    bool isTokenLogin = false, // Kept for backward compatibility but not used
    bool rememberMe = false,
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
        return await _handleBypassLogin(identifier, rememberMe: rememberMe);
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

        // Save user session securely with MockSharedPrefsStorageService
        await MockSharedPrefsStorageService.saveUserSession(userSession);

        // Save credentials for Remember Me if enabled
        if (rememberMe) {
          await MockSharedPrefsStorageService.saveUserCredentials(
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
        print('MockLoginService: Login error: $e');
      }

      // Return a user-friendly error message
      return LoginResult(
        success: false,
        message: 'Login failed. Please check your connection and try again.',
      );
    }
  }

  /// Handle bypass login for ITDepartment
  Future<LoginResult> _handleBypassLogin(
    String identifier, {
    bool rememberMe = false,
  }) async {
    try {
      if (EnvironmentConfig.enableLogging) {
        print('MockLoginService: Using bypass login for $identifier');
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
        await MockSharedPrefsStorageService.saveUserSession(userSession);
        if (EnvironmentConfig.enableLogging) {
          print('MockLoginService: Bypass session saved to MockSharedPrefs');
        }
      } catch (storageError) {
        if (EnvironmentConfig.enableLogging) {
          print(
            'MockLoginService: MockSharedPrefs unavailable for bypass login, using in-memory state: $storageError',
          );
        }
        // Store in memory when shared preferences is unavailable
        _bypassSession = userSession;
      }

      // Save credentials for Remember Me if enabled
      if (rememberMe) {
        try {
          await MockSharedPrefsStorageService.saveUserCredentials(
            email: identifier,
            password: 'password', // Use the bypass password
            rememberMe: true,
          );
          if (EnvironmentConfig.enableLogging) {
            print(
              'MockLoginService: Remember Me credentials saved for bypass login',
            );
          }
        } catch (e) {
          if (EnvironmentConfig.enableLogging) {
            print(
              'MockLoginService: Failed to save Remember Me credentials: $e',
            );
          }
        }
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
        print('MockLoginService: Bypass login error: $e');
      }
      return LoginResult(
        success: false,
        message: 'Bypass login failed: ${e.toString()}',
      );
    }
  }

  /// Check if user is authenticated
  @override
  Future<bool> isAuthenticated() async {
    try {
      // First check for in-memory bypass session (when storage is unavailable)
      if (_bypassSession != null && _bypassSession!.loginType == 'bypass') {
        if (EnvironmentConfig.enableLogging) {
          print('MockLoginService: In-memory bypass session detected');
        }
        return true;
      }

      // Then check if we have a local session in MockSharedPrefs
      final userSession = await MockSharedPrefsStorageService.getUserSession();
      if (userSession == null) return false;

      // If it's a bypass login, skip server verification
      if (userSession.loginType == 'bypass') {
        if (EnvironmentConfig.enableLogging) {
          print(
            'MockLoginService: Bypass session detected, skipping server verification',
          );
        }
        return true;
      }

      // For token-based auth, check if token is still valid locally first
      if (!userSession.hasValidToken) {
        if (EnvironmentConfig.enableLogging) {
          print('MockLoginService: Token expired locally');
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
        print('MockLoginService: Authentication check error: $e');
      }
      return false;
    }
  }

  /// Get current user session (async)
  @override
  Future<UserSession?> getCurrentUserSession() async {
    try {
      // First check for in-memory bypass session
      if (_bypassSession != null) {
        return _bypassSession;
      }

      return await MockSharedPrefsStorageService.getUserSession();
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockLoginService: Get current user session error: $e');
      }
      // Return in-memory bypass session if storage fails but bypass is active
      return _bypassSession;
    }
  }

  /// Logout user
  @override
  Future<void> logout() async {
    try {
      // Call logout API
      final logoutResponse = await _authApiService.logout();

      if (EnvironmentConfig.enableLogging) {
        if (logoutResponse.success) {
          print('MockLoginService: Logout successful');
        } else {
          print(
            'MockLoginService: Logout API failed: ${logoutResponse.message}',
          );
        }
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockLoginService: Logout API error: $e');
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
    await MockSharedPrefsStorageService.clearUserSession();
    await _authApiService.clearSession();
    _bypassSession = null; // Clear in-memory bypass session
  }

  /// Get saved credentials for auto-login
  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    return await MockSharedPrefsStorageService.getUserCredentials();
  }

  /// Check if Remember Me is enabled
  @override
  Future<bool> isRememberMeEnabled() async {
    return await MockSharedPrefsStorageService.isRememberMeEnabled();
  }

  /// Auto-login with saved credentials
  @override
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
        print('MockLoginService: Auto-login error: $e');
      }
      return LoginResult(success: false, message: 'Auto-login failed');
    }
  }

  /// Refresh token (for Sanctum token-based auth)
  @override
  Future<bool> refreshToken() async {
    try {
      final userSession = await MockSharedPrefsStorageService.getUserSession();
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

        await MockSharedPrefsStorageService.saveUserSession(updatedSession);
        return true;
      }

      return false;
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockLoginService: Token refresh error: $e');
      }
      return false;
    }
  }

  /// Auto-refresh token if needed before API calls
  @override
  Future<void> ensureValidToken() async {
    try {
      final userSession = await MockSharedPrefsStorageService.getUserSession();
      if (userSession?.token == null || userSession!.loginType == 'bypass') {
        return; // No token or bypass session
      }

      // Check if token is expired or needs refresh soon
      if (!userSession.hasValidToken || userSession.needsRefresh) {
        if (EnvironmentConfig.enableLogging) {
          print(
            'MockLoginService: Token needs refresh, attempting auto-refresh',
          );
        }

        final refreshed = await refreshToken();
        if (!refreshed) {
          if (EnvironmentConfig.enableLogging) {
            print(
              'MockLoginService: Token refresh failed, user needs to re-login',
            );
          }
          // Clear invalid session and notify listeners
          await _clearLocalSession();
          _authStatusController.add(false);
        }
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('MockLoginService: Ensure valid token error: $e');
      }
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _authStatusController.close();
    _authApiService.dispose();
  }
}
