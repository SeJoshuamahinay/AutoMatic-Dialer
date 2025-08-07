class LoginRequest {
  final String email;
  final String password;
  final String? deviceName;

  LoginRequest({required this.email, required this.password, this.deviceName});

  Map<String, dynamic> toJson() {
    final json = {'email': email, 'password': password};
    if (deviceName != null) {
      json['device_name'] = deviceName!;
    }
    return json;
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final UserData? userData;
  final String? token;
  final String? timestamp;

  LoginResponse({
    required this.success,
    required this.message,
    this.userData,
    this.token,
    this.timestamp,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      userData: json['data']?['user'] != null
          ? UserData.fromJson(json['data']['user'])
          : null,
      token: json['data']?['token'],
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}

class UserData {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String loginType;
  final int? departmentId;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.loginType,
    this.departmentId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      loginType: json['login_type'] ?? 'standard',
      departmentId: json['department_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'login_type': loginType,
      'department_id': departmentId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}

class UserInfoResponse {
  final bool success;
  final String message;
  final UserData? userData;
  final String? timestamp;

  UserInfoResponse({
    required this.success,
    required this.message,
    this.userData,
    this.timestamp,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      userData: json['data']?['user'] != null
          ? UserData.fromJson(json['data']['user'])
          : null,
      timestamp: json['data']?['timestamp'],
    );
  }
}

class LogoutResponse {
  final bool success;
  final String message;
  final int? userId;
  final String? timestamp;

  LogoutResponse({
    required this.success,
    required this.message,
    this.userId,
    this.timestamp,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      userId: json['data']?['user_id'],
      timestamp: json['data']?['timestamp'],
    );
  }
}

class VerifyResponse {
  final bool success;
  final String message;
  final bool authenticated;
  final String? timestamp;

  VerifyResponse({
    required this.success,
    required this.message,
    required this.authenticated,
    this.timestamp,
  });

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      authenticated: json['data']?['authenticated'] ?? false,
      timestamp: json['data']?['timestamp'],
    );
  }
}

class UserSession {
  final int userId;
  final String email;
  final String fullName;
  final String loginType;
  final DateTime loginTime;
  final String? token;
  final DateTime? tokenExpiresAt;

  UserSession({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.loginType,
    required this.loginTime,
    this.token,
    this.tokenExpiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'login_type': loginType,
      'login_time': loginTime.toIso8601String(),
      'token': token,
      'token_expires_at': tokenExpiresAt?.toIso8601String(),
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['user_id'],
      email: json['email'],
      fullName: json['full_name'],
      loginType: json['login_type'],
      loginTime: DateTime.parse(json['login_time']),
      token: json['token'],
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.parse(json['token_expires_at'])
          : null,
    );
  }

  factory UserSession.fromUserData(UserData userData, {String? token}) {
    return UserSession(
      userId: userData.id,
      email: userData.email,
      fullName: userData.fullName,
      loginType: userData.loginType,
      loginTime: DateTime.now(),
      token: token,
      tokenExpiresAt: token != null
          ? DateTime.now().add(const Duration(hours: 24)) // Default 24h expiry
          : null,
    );
  }

  bool get hasValidToken {
    if (token == null) return false;
    if (tokenExpiresAt == null) return true; // No expiry set
    return DateTime.now().isBefore(tokenExpiresAt!);
  }

  bool get needsRefresh {
    if (token == null || tokenExpiresAt == null) return false;
    // Refresh if token expires within 5 minutes
    return DateTime.now().isAfter(
      tokenExpiresAt!.subtract(const Duration(minutes: 5)),
    );
  }
}

// Token Info Response (for token information endpoint)
class TokenInfoResponse {
  final bool success;
  final String message;
  final TokenInfo? tokenInfo;

  TokenInfoResponse({
    required this.success,
    required this.message,
    this.tokenInfo,
  });

  factory TokenInfoResponse.fromJson(Map<String, dynamic> json) {
    return TokenInfoResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      tokenInfo: json['data']?['token'] != null
          ? TokenInfo.fromJson(json['data']['token'])
          : null,
    );
  }
}

class TokenInfo {
  final String name;
  final List<String> abilities;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TokenInfo({
    required this.name,
    required this.abilities,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) {
    return TokenInfo(
      name: json['name'] ?? '',
      abilities: List<String>.from(json['abilities'] ?? []),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// Refresh Token Response
class RefreshTokenResponse {
  final bool success;
  final String message;
  final String? token;
  final DateTime? expiresAt;

  RefreshTokenResponse({
    required this.success,
    required this.message,
    this.token,
    this.expiresAt,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      token: json['data']?['token'],
      expiresAt: json['data']?['expires_at'] != null
          ? DateTime.parse(json['data']['expires_at'])
          : null,
    );
  }
}
