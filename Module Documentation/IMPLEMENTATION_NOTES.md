# Implementation Notes - Sanctum Authentication

## Overview

This document provides technical implementation details for the Laravel Sanctum token-based authentication system in the Lenderly Dialer Flutter application.

## Key Changes Made

### 1. Environment Configuration Updates

**Files Modified:**
- `.env.dev` - Development environment configuration
- `.env.prod` - Production environment configuration  
- `lib/commons/services/environment_config.dart` - Configuration service

**Changes:**
- Updated API base URL to use Sanctum endpoints (`/api/auth/sanctum`)
- Added `DEFAULT_DEVICE_NAME` configuration for token generation
- Added `USE_SANCTUM_AUTH` flag for authentication method selection
- Added new Sanctum-specific endpoints (logout-all, refresh, verify)

### 2. Authentication Models Enhancement

**File:** `lib/commons/models/auth_models.dart`

**New Models Added:**
- `TokenInfo` - Token metadata and abilities
- `RefreshTokenResponse` - Token refresh response handling
- Enhanced `LoginRequest` with `device_name` support
- Enhanced `LoginResponse` with token field
- Enhanced `UserSession` with token storage and validation

**Key Features:**
- Local token expiration checking (`hasValidToken`)
- Auto-refresh logic (`needsRefresh`)
- Device-specific token support
- Token metadata handling

### 3. API Service Transformation

**File:** `lib/commons/services/auth_api_service.dart`

**Major Changes:**
- Removed cookie-based session management
- Implemented Bearer token authentication
- Added automatic token injection in request headers
- Added new Sanctum endpoints:
  - `POST /logout-all` - Logout from all devices
  - `POST /refresh` - Refresh current token
  - `GET /verify` - Verify token validity

**Token Management:**
- Automatic Bearer token inclusion in Authorization headers
- Token retrieval from secure storage for each request
- Comprehensive error handling for token-related issues

### 4. Login Service Enhancement

**File:** `lib/commons/services/api_login_service.dart`

**New Features:**
- Device name inclusion in login requests
- Token storage and management
- Auto token refresh functionality
- Token validation before API calls
- Enhanced bypass login for IT Department

**Methods Added:**
- `ensureValidToken()` - Pre-request token validation
- `refreshToken()` - Manual token refresh
- `needsTokenRefresh()` - Token expiration checking
- `logoutAll()` - Multi-device logout support

### 5. Secure Storage Integration

**File:** `lib/commons/services/secure_storage_service.dart`

**Token Storage:**
- Bearer tokens stored securely using Flutter Secure Storage
- Platform-specific encryption (iOS Keychain, Android KeyStore)
- Token metadata persistence (expiration, device info)
- Automatic cleanup on logout

## Authentication Flow

### 1. Login Process

```dart
// User login with Sanctum
final loginRequest = LoginRequest(
  email: email,
  password: password,
  deviceName: EnvironmentConfig.defaultDeviceName, // "LenderlyDialer"
);

final response = await authApiService.login(loginRequest);

if (response.success && response.token != null) {
  // Store token securely
  final userSession = UserSession.fromUserData(
    response.userData!,
    token: response.token,
  );
  await secureStorageService.saveUserSession(userSession);
}
```

### 2. API Request Authentication

```dart
// Automatic token injection
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final userSession = await _storageService.getUserSession();
      if (userSession?.token != null) {
        options.headers['Authorization'] = 'Bearer ${userSession!.token}';
      }
      handler.next(options);
    },
  ),
);
```

### 3. Token Refresh Flow

```dart
// Automatic token refresh
Future<void> ensureValidToken() async {
  final userSession = await _storageService.getUserSession();
  
  if (userSession?.needsRefresh == true) {
    final refreshed = await refreshToken();
    if (!refreshed) {
      // Force re-login
      await logout();
    }
  }
}
```

## Configuration Details

### Development Environment (`.env.dev`)

```bash
API_BASE_URL=http://127.0.0.1:8000/api/auth/sanctum
DEFAULT_DEVICE_NAME=LenderlyDialer
USE_SANCTUM_AUTH=true
```

### Production Environment (`.env.prod`)

```bash
API_BASE_URL=https://your-production-domain.com/api/auth/sanctum
DEFAULT_DEVICE_NAME=LenderlyDialer
USE_SANCTUM_AUTH=true
```

## Backend API Compatibility

### Expected Request Format

**Login Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "device_name": "LenderlyDialer"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "full_name": "John Doe"
    },
    "token": "1|abcd1234efgh5678...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### Required Backend Endpoints

1. `POST /login` - User authentication with device name
2. `GET /me` - Get authenticated user information
3. `POST /logout` - Logout current device
4. `POST /logout-all` - Logout all devices
5. `GET /verify` - Verify token validity
6. `POST /refresh` - Refresh current token

## Security Considerations

### Token Storage
- Tokens stored using Flutter Secure Storage
- Platform-specific encryption (iOS Keychain, Android KeyStore)
- Automatic cleanup on app uninstall
- No token exposure in logs or debug output

### Token Lifecycle
- Device-specific token generation
- Automatic expiration handling
- Secure token refresh mechanism
- Multi-device logout capability

### Request Security
- Bearer token authentication
- HTTPS enforcement in production
- Request/response logging only in debug mode
- Automatic token injection prevents manual handling

## Testing

### Bypass Login
For testing purposes, the system supports bypass authentication:

```dart
final result = await loginService.login(
  identifier: 'ITDepartment',
  password: 'password',
);
// Creates local session without API call
```

### Unit Testing
Token-related functionality can be tested using mock services:

```dart
// Mock secure storage for testing
class MockSecureStorageService extends SecureStorageService {
  final Map<String, String> _storage = {};
  
  @override
  Future<void> saveUserSession(UserSession session) async {
    _storage['user_session'] = jsonEncode(session.toJson());
  }
}
```

## Troubleshooting

### Common Issues

1. **Token Not Included in Requests**
   - Verify `AuthApiService.initialize()` is called
   - Check secure storage permissions
   - Ensure token exists in storage

2. **401 Unauthorized Errors**
   - Check token expiration
   - Verify API endpoint URLs
   - Confirm Bearer token format

3. **Token Refresh Failures**
   - Check network connectivity
   - Verify refresh endpoint configuration
   - Review server-side token settings

4. **Secure Storage Issues**
   - Check platform permissions
   - Verify device lock screen is set
   - Clear app data if storage is corrupted

### Debug Logging

Enable detailed logging in development:

```bash
# .env.dev
ENABLE_LOGGING=true
DEBUG_MODE=true
```

Logs will show:
- Token injection in requests
- API response details
- Token refresh operations
- Authentication state changes

## Migration Notes

### From Session-Based to Token-Based

If migrating from the previous session-based implementation:

1. Update environment files with Sanctum endpoints
2. Clear any existing session data
3. Update API endpoints from `/api/third-party/` to `/api/auth/sanctum/`
4. Test token refresh functionality
5. Verify multi-device logout works correctly

### Backward Compatibility

The implementation maintains compatibility with existing login flows:
- Same `LoginService.login()` method signature
- Same `LoginResult` response structure  
- Same authentication state management
- Same UI integration points

## Performance Considerations

### Token Management
- Tokens cached in memory after first load
- Secure storage accessed only when needed
- Automatic cleanup prevents memory leaks
- Background token refresh doesn't block UI

### Network Optimization
- Token refresh only when needed (5 minutes before expiry)
- Failed requests don't trigger unnecessary refreshes
- Dio connection pooling for better performance
- Request/response compression support

## Future Enhancements

### Planned Features
1. **Biometric Authentication** - Use device biometrics for token access
2. **Token Rotation** - Automatic token rotation for enhanced security  
3. **Offline Mode** - Local token validation when offline
4. **Analytics Integration** - Authentication event tracking
5. **Multi-Environment Support** - Staging environment configuration

### Code Organization
- Consider extracting token management to separate service
- Add more comprehensive error types
- Implement retry logic for network failures
- Add performance monitoring for auth operations

This implementation provides a robust, secure, and maintainable authentication system that integrates seamlessly with Laravel Sanctum while maintaining the existing application architecture.
