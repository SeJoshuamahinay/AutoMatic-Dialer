import 'dart:async';
import 'dart:convert';

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

  // In-memory storage (replace with SharedPreferences in production)
  final Map<String, dynamic> _storage = {};

  Stream<bool> get authStatusStream => _authStatusController.stream;

  /// Login with username/password or token
  Future<LoginResult> login({
    required String identifier,
    String? password,
    bool isTokenLogin = false,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      bool isValid = false;
      String username = identifier;

      if (isTokenLogin) {
        // Token-based authentication
        if (identifier.trim().isEmpty) {
          return LoginResult(success: false, message: 'Please enter a token');
        }

        // Simple token validation (replace with real API call)
        isValid = identifier.length >= 4;
        username = 'Token User'; // Default username for token users

        if (!isValid) {
          return LoginResult(
            success: false,
            message: 'Invalid token. Token must be at least 4 characters long.',
          );
        }
      } else {
        // Username/password authentication
        if (identifier.trim().isEmpty || password?.trim().isEmpty == true) {
          return LoginResult(
            success: false,
            message: 'Please enter both username and password',
          );
        }

        // Check for demo accounts or valid credentials
        isValid = _validateCredentials(identifier, password!);

        if (!isValid) {
          return LoginResult(
            success: false,
            message: 'Invalid username or password',
          );
        }
      }

      if (isValid) {
        // Generate a simple token (in production, this would come from your API)
        final token = _generateToken(identifier, isTokenLogin);

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

      return LoginResult(success: false, message: 'Authentication failed');
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  /// Validate username/password credentials
  bool _validateCredentials(String username, String password) {
    // Demo accounts
    if (username == 'ITdepartment' && password == 'password') {
      return true;
    }

    // Symphony Account (from your original code)
    if (username == 'symphony' && password == 'symphony123') {
      return true;
    }

    // Any valid credentials (basic validation)
    if (username.length >= 3 && password.length >= 4) {
      return true;
    }

    return false;
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
    final token = _storage[_tokenKey];
    if (token == null) return false;

    // In production, you might want to validate the token with your API
    return token.isNotEmpty;
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
    _storage.clear();
    _authStatusController.add(false);
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
