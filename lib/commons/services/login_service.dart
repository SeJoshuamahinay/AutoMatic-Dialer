import 'dart:async';
import 'dart:convert';
import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';
import 'package:lenderly_dialer/commons/services/auth_api_service.dart';
import 'package:lenderly_dialer/commons/services/secure_storage_service.dart';
import 'package:lenderly_dialer/commons/services/environment_config.dart';

class LoginResult {
  final bool success;
  final String message;
  final String? token;
  final String? username;

  LoginResult({
    required this.success,
    required this.message,
    this.token,
    this.username,
  });
}

class LoginService {
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _loginTimeKey = 'login_time';

  final StreamController<bool> _authStatusController =
      StreamController<bool>.broadcast();

  final AuthApiService _authApiService = AuthApiService();
  final SecureStorageService _secureStorage = SecureStorageService();

  // In-memory storage (replace with SharedPreferences in production)
  final Map<String, dynamic> _storage = {};

  Stream<bool> get authStatusStream => _authStatusController.stream;

  /// Login with username/password or token
  Future<LoginResult> login({
    required String identifier,
    String? password,
    bool isTokenLogin = false,
    bool rememberMe = false,
  }) async {
    try {
      // Check for bypass login (IT Department)
      if (identifier == 'ITDepartment' && password == 'password') {
        return await _handleBypassLogin(identifier, rememberMe);
      }

      if (isTokenLogin) {
        // Token-based authentication (still local for now)
        return await _handleTokenLogin(identifier, rememberMe);
      } else {
        // Real HTTP API login with email/password
        return await _handleApiLogin(identifier, password!, rememberMe);
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  /// Handle real API login with backend
  Future<LoginResult> _handleApiLogin(
    String email,
    String password,
    bool rememberMe,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return LoginResult(
        success: false,
        message: 'Please enter both email and password',
      );
    }

    // Create login request for backend API
    final loginRequest = LoginRequest(
      email: email,
      password: password,
      deviceName: EnvironmentConfig.defaultDeviceName,
    );

    // Make HTTP request to backend
    final response = await _authApiService.login(loginRequest);

    if (response.success &&
        response.token != null &&
        response.userData != null) {
      // Create user session from API response
      final userSession = UserSession(
        userId: response.userData!.id,
        email: response.userData!.email,
        fullName: response.userData!.fullName,
        loginType: 'sanctum',
        loginTime: DateTime.now(),
        token: response.token!,
        tokenExpiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // Store session securely
      await _secureStorage.saveUserSession(userSession);

      // Handle Remember Me functionality
      if (rememberMe) {
        await SharedPrefsStorageService.saveUserCredentials(
          email: email,
          password: password,
          rememberMe: true,
        );
      }

      // Update in-memory storage
      await _saveAuthData(response.token!, response.userData!.fullName);

      // Notify listeners
      _authStatusController.add(true);

      return LoginResult(
        success: true,
        message: 'Login successful',
        token: response.token,
        username: response.userData!.fullName,
      );
    } else {
      return LoginResult(success: false, message: response.message);
    }
  }

  /// Handle bypass login for testing (IT Department)
  Future<LoginResult> _handleBypassLogin(
    String identifier,
    bool rememberMe,
  ) async {
    // Generate a simple token for bypass
    final token = _generateToken(identifier, false);
    const username = 'IT Department';

    // Create user session
    await _createUserSession(
      identifier: identifier,
      username: username,
      token: token,
    );

    // Handle Remember Me functionality
    if (rememberMe) {
      await SharedPrefsStorageService.saveUserCredentials(
        email: identifier,
        password: 'password',
        rememberMe: true,
      );
    }

    // Store authentication data
    await _saveAuthData(token, username);

    // Notify listeners
    _authStatusController.add(true);

    return LoginResult(
      success: true,
      message: 'Login successful (Bypass)',
      token: token,
      username: username,
    );
  }

  /// Handle token-based login (local validation for now)
  Future<LoginResult> _handleTokenLogin(String token, bool rememberMe) async {
    if (token.isEmpty) {
      return LoginResult(success: false, message: 'Please enter a token');
    }

    // Simple token validation (replace with real API call if needed)
    bool isValid = token.length >= 4;
    const username = 'Token User';

    if (!isValid) {
      return LoginResult(
        success: false,
        message: 'Invalid token. Token must be at least 4 characters long.',
      );
    }

    // Create user session
    await _createUserSession(
      identifier: token,
      username: username,
      token: token,
    );

    // Store authentication data
    await _saveAuthData(token, username);

    // Notify listeners
    _authStatusController.add(true);

    return LoginResult(
      success: true,
      message: 'Login successful',
      token: token,
      username: username,
    );
  }

  /// Auto-login using stored credentials (Remember Me functionality)
  Future<LoginResult> autoLogin() async {
    try {
      // Check if remember me is enabled
      final isRememberMeEnabled =
          await SharedPrefsStorageService.isRememberMeEnabled();
      if (!isRememberMeEnabled) {
        return LoginResult(success: false, message: 'Auto-login not enabled');
      }

      // Get stored credentials
      final credentials = await SharedPrefsStorageService.getUserCredentials();
      if (credentials == null) {
        return LoginResult(success: false, message: 'No stored credentials');
      }

      // Attempt login with stored credentials
      return await login(
        identifier: credentials['email']!,
        password: credentials['password']!,
        rememberMe: true,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Auto-login failed: ${e.toString()}',
      );
    }
  }

  /// Create and save user session
  Future<void> _createUserSession({
    required String identifier,
    required String username,
    required String token,
  }) async {
    final userSession = UserSession(
      userId: identifier.hashCode, // Simple ID generation
      email: identifier.contains('@') ? identifier : '$identifier@lenderly.com',
      fullName: username,
      loginType: 'sanctum',
      loginTime: DateTime.now(),
      token: token,
      tokenExpiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await SharedPrefsStorageService.saveUserSession(userSession);
  }

  /// Get current user session
  Future<UserSession?> getCurrentUserSession() async {
    try {
      return await SharedPrefsStorageService.getUserSession();
    } catch (e) {
      return null;
    }
  }

  /// Generate a simple token
  String _generateToken(String identifier, bool isTokenLogin) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'identifier': identifier,
      'isTokenLogin': isTokenLogin,
      'timestamp': timestamp,
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  /// Save authentication data
  Future<void> _saveAuthData(String token, String username) async {
    _storage[_tokenKey] = token;
    _storage[_usernameKey] = username;
    _storage[_loginTimeKey] = DateTime.now().toIso8601String();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      // First check in-memory storage
      final token = _storage[_tokenKey];
      if (token != null && token.isNotEmpty) {
        return true;
      }

      // Check secure storage for user session
      final userSession = await _secureStorage.getUserSession();
      if (userSession?.token != null && userSession!.hasValidToken) {
        // Update in-memory storage
        _storage[_tokenKey] = userSession.token!;
        _storage[_usernameKey] = userSession.fullName;
        _storage[_loginTimeKey] = userSession.loginTime.toIso8601String();
        return true;
      }

      // Check legacy persistent storage for backward compatibility
      final legacySession = await SharedPrefsStorageService.getUserSession();
      if (legacySession?.token != null) {
        // Update in-memory storage
        _storage[_tokenKey] = legacySession!.token!;
        _storage[_usernameKey] = legacySession.fullName;
        _storage[_loginTimeKey] = legacySession.loginTime.toIso8601String();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get current user information
  Map<String, dynamic>? getCurrentUser() {
    final token = _storage[_tokenKey];
    final username = _storage[_usernameKey];
    final loginTimeStr = _storage[_loginTimeKey];

    if (token == null || username == null || loginTimeStr == null) {
      return null;
    }

    return {
      'token': token,
      'username': username,
      'loginTime': DateTime.parse(loginTimeStr),
    };
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Try to logout from backend API first
      try {
        await _authApiService.logout();
      } catch (e) {
        // If backend logout fails, continue with local cleanup
      }

      // Clear in-memory storage
      _storage.clear();

      // Clear persistent storage
      await SharedPrefsStorageService.clearAll();

      // Clear secure storage
      await _secureStorage.clearUserSession();

      // Notify listeners
      _authStatusController.add(false);
    } catch (e) {
      // Even if storage clearing fails, clear in-memory and notify
      _storage.clear();
      _authStatusController.add(false);
    }
  }

  /// Get current auth token
  String? getAuthToken() {
    return _storage[_tokenKey];
  }

  /// Get current username
  String? getCurrentUsername() {
    return _storage[_usernameKey];
  }

  /// Dispose resources
  void dispose() {
    _authStatusController.close();
  }
}
