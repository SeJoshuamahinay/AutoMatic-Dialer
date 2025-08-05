import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { dev, prod }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.dev;

  static Environment get currentEnvironment => _currentEnvironment;

  static Future<void> initialize({
    Environment environment = Environment.dev,
  }) async {
    // Check if environment is passed via dart-define
    const String dartDefineEnv = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: '',
    );
    if (dartDefineEnv.isNotEmpty) {
      if (dartDefineEnv.toLowerCase() == 'prod') {
        _currentEnvironment = Environment.prod;
      } else {
        _currentEnvironment = Environment.dev;
      }
    } else {
      _currentEnvironment = environment;
    }

    String envFile = _currentEnvironment == Environment.prod
        ? '.env.prod'
        : '.env.dev';

    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      throw Exception('Failed to load environment file: $envFile');
    }
  }

  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';

  // Auth Endpoints
  static String get authEndpoint => dotenv.env['AUTH_ENDPOINT'] ?? '/login';
  static String get userInfoEndpoint =>
      dotenv.env['USER_INFO_ENDPOINT'] ?? '/me';
  static String get logoutEndpoint =>
      dotenv.env['LOGOUT_ENDPOINT'] ?? '/logout';
  static String get logoutAllEndpoint =>
      dotenv.env['LOGOUT_ALL_ENDPOINT'] ?? '/logout-all';
  static String get verifyEndpoint =>
      dotenv.env['VERIFY_ENDPOINT'] ?? '/verify';
  static String get refreshEndpoint =>
      dotenv.env['REFRESH_ENDPOINT'] ?? '/refresh';

  // Sanctum Configuration
  static String get defaultDeviceName =>
      dotenv.env['DEFAULT_DEVICE_NAME'] ?? 'LenderlyDialer';
  static bool get useSanctumAuth =>
      dotenv.env['USE_SANCTUM_AUTH']?.toLowerCase() == 'true';

  // Feature Flags
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableCrashReporting =>
      dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';

  // Utility methods
  static String getFullUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  static bool get isDevelopment => _currentEnvironment == Environment.dev;
  static bool get isProduction => _currentEnvironment == Environment.prod;
}
