# Authentication API Integration - Sanctum Token-Based

This document explains the Laravel Sanctum token-based authentication system for connecting to your backend API endpoints.

## Architecture Overview

The authentication system uses **Laravel Sanctum token-based authentication** with Bearer tokens, following your backend API structure:

### Core Components

1. **Models** (`lib/commons/models/auth_models.dart`)
   - `LoginRequest` - Email/password/device_name login payload
   - `LoginResponse` - Response from login API with Bearer token
   - `UserData` - User information model
   - `UserSession` - Local session storage model with token management
   - `TokenInfo` - Token metadata and expiration handling
   - `RefreshTokenResponse` - Token refresh response model

2. **API Service** (`lib/commons/services/auth_api_service.dart`)
   - Uses Dio with Bearer token authentication
   - Automatic token injection in Authorization headers
   - Support for all Sanctum endpoints (login, logout, logout-all, verify, refresh)
   - Comprehensive error handling and logging

3. **Secure Storage** (`lib/commons/services/secure_storage_service.dart`)
   - Encrypts and stores Bearer tokens securely
   - Manages token persistence across app restarts
   - Uses platform-specific secure storage (Keychain/KeyStore)

4. **Login Service** (`lib/commons/services/api_login_service.dart`)
   - High-level authentication operations
   - Auto token refresh management
   - Token validation and expiration handling
   - Bypass login support for IT Department testing

5. **Environment Configuration** (`lib/commons/services/environment_config.dart`)
   - Environment-based configuration (dev/prod)
   - Centralized API endpoint management
   - Feature flags and debugging controls

## API Endpoints Configuration

The system uses environment variables for Sanctum API configuration:

### Development (.env.dev)
```bash
# Sanctum Token-based Authentication
API_BASE_URL=http://127.0.0.1:8000/api/auth/sanctum
AUTH_ENDPOINT=/login
USER_INFO_ENDPOINT=/me
LOGOUT_ENDPOINT=/logout
LOGOUT_ALL_ENDPOINT=/logout-all
VERIFY_ENDPOINT=/verify
REFRESH_ENDPOINT=/refresh
DEFAULT_DEVICE_NAME=LenderlyDialer
USE_SANCTUM_AUTH=true
```

### Production (.env.prod)
```bash
# Sanctum Token-based Authentication
API_BASE_URL=https://your-production-domain.com/api/auth/sanctum
AUTH_ENDPOINT=/login
USER_INFO_ENDPOINT=/me
LOGOUT_ENDPOINT=/logout
LOGOUT_ALL_ENDPOINT=/logout-all
VERIFY_ENDPOINT=/verify
REFRESH_ENDPOINT=/refresh
DEFAULT_DEVICE_NAME=LenderlyDialer
USE_SANCTUM_AUTH=true
```

## Authentication Flow

### 1. Login Process
```dart
final loginService = LoginService();

final result = await loginService.login(
  identifier: 'user@example.com',
  password: 'password123',
);

if (result.success) {
  // User is authenticated with Bearer token
  print('Welcome ${result.username}');
  print('Token: ${result.token}');
} else {
  // Handle login error
  print('Login failed: ${result.message}');
}
```

### 2. Token Management
The system automatically:
- Stores Bearer tokens securely
- Injects tokens in API request headers
- Refreshes tokens before expiration
- Handles token validation

### 3. API Request Authentication
All authenticated API requests automatically include:
```
Authorization: Bearer {your_token}
```

### 4. Token Refresh
```dart
// Manual token refresh
final refreshed = await loginService.refreshToken();

// Auto-refresh (handled automatically)
await loginService.ensureValidToken();
```

### 5. Logout
```dart
// Logout from current device
await loginService.logout();

// Logout from all devices
await loginService.logoutAll();
```

## Special Features

### Bypass Login
For testing purposes, the system supports bypass authentication:
```dart
// Bypass login for IT Department
final result = await loginService.login(
  identifier: 'ITDepartment',
  password: 'password',
);
// No API call is made, creates local session
```

### Auto Token Refresh
The system automatically refreshes tokens when:
- Token expires within 5 minutes
- API returns 401 Unauthorized
- User performs authenticated actions

### Token Validation
Local token validation includes:
- Expiration time checking
- Token format validation
- Secure storage verification

## Error Handling

The system handles various error scenarios:

### Network Errors
```dart
{
  "success": false,
  "message": "Network error: Connection timeout"
}
```

### Validation Errors (422)
```dart
{
  "success": false,
  "message": "The email field is required., The device name field is required."
}
```

### Authentication Errors (401)
```dart
{
  "success": false,
  "message": "Invalid credentials"
}
```

### Token Expiration
- Automatic token refresh attempted
- If refresh fails, user redirected to login
- Secure cleanup of expired tokens

## Security Features

### Secure Token Storage
- Uses Flutter Secure Storage
- Platform-specific encryption (Keychain/KeyStore)
- Automatic cleanup on logout

### Request Security
- Bearer token authentication
- HTTPS enforcement in production
- Request/response logging in debug mode

### Token Lifecycle Management
- Device-specific token generation
- Automatic token refresh
- Secure token revocation on logout

## Testing

### Unit Tests
Test authentication components:
```dart
test('should login successfully', () async {
  final loginService = LoginService();
  final result = await loginService.login(
    identifier: 'test@example.com',
    password: 'password',
  );
  expect(result.success, true);
});
```

### Integration Tests
Test with mock backend:
```dart
testWidgets('login flow integration test', (tester) async {
  // Test complete login flow
});
```

## Troubleshooting

### Common Issues

1. **Token Not Included in Requests**
   - Check if `AuthApiService.initialize()` is called
   - Verify token exists in secure storage

2. **401 Unauthorized Errors**
   - Check token expiration
   - Verify API base URL configuration
   - Ensure Bearer token format

3. **Environment Configuration Issues**
   - Verify `.env.dev` or `.env.prod` file exists
   - Check `flutter_dotenv` package is installed
   - Ensure `EnvironmentConfig.initialize()` is called

4. **Token Refresh Failures**
   - Check network connectivity
   - Verify refresh endpoint configuration
   - Review server-side token settings

### Debug Logging
Enable detailed logging in development:
```bash
# .env.dev
ENABLE_LOGGING=true
DEBUG_MODE=true
```

## Migration Notes

If migrating from session-based to token-based authentication:

1. Update environment configuration files
2. Clear existing session data
3. Update API endpoints to Sanctum URLs
4. Test token refresh functionality
5. Verify secure storage is working

The authentication system maintains backward compatibility with existing login flows while providing enhanced security through token-based authentication.
