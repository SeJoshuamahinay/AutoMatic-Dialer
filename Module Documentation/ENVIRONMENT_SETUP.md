# Environment Configuration

This project supports multiple environments (development and production) with different API configurations.

## Environment Files

- `.env.dev` - Development environment configuration
- `.env.prod` - Production environment configuration

## Configuration Options

Each environment file contains:

- `API_BASE_URL` - Base URL for API calls
- `API_TIMEOUT` - Timeout for API requests in milliseconds
- `DEBUG_MODE` - Enable/disable debug mode
- `LOG_LEVEL` - Logging level (debug, info, error)
- `AUTH_ENDPOINT` - Authentication endpoint
- `TOKEN_ENDPOINT` - Token refresh endpoint
- `REFRESH_ENDPOINT` - Token refresh endpoint
- `ENABLE_LOGGING` - Enable/disable API logging
- `ENABLE_ANALYTICS` - Enable/disable analytics
- `ENABLE_CRASH_REPORTING` - Enable/disable crash reporting

## Usage in Code

```dart
import 'package:lenderly_dialer/commons/services/environment_config.dart';
import 'package:lenderly_dialer/commons/services/api_service.dart';

// Initialize environment (usually in main.dart)
await EnvironmentConfig.initialize(environment: Environment.dev);

// Use configuration values
String baseUrl = EnvironmentConfig.apiBaseUrl;
bool isDebug = EnvironmentConfig.debugMode;

// Use API service with environment configuration
final apiService = ApiService();
apiService.initialize();
final response = await apiService.get('/users');
```

## Building for Different Environments

### Manual Method
```bash
# Development build
flutter run --dart-define=ENVIRONMENT=dev

# Production build
flutter build apk --dart-define=ENVIRONMENT=prod
```

### Using Build Script
```bash
# Development build for Android
./build.sh dev android

# Production build for iOS
./build.sh prod ios

# Development build for Web
./build.sh dev web
```

## Environment Detection

You can check the current environment in your code:

```dart
if (EnvironmentConfig.isDevelopment) {
  // Development-specific code
}

if (EnvironmentConfig.isProduction) {
  // Production-specific code
}
```

## Security Notes

- Never commit sensitive API keys or secrets to version control
- Use environment variables or secure storage for sensitive data in production
- The `.env` files are included in assets for demo purposes, but in real projects, consider using build-time configuration or secure storage
