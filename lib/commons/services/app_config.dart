/// App-wide compile-time constants.
///
/// Baked at build time via --dart-define=APP_VERSION=X.Y.Z
/// Falls back to '2.0.0' for local `flutter run` without the define.
class AppConfig {
  AppConfig._();

  /// The app version sent as `X-App-Version` header to the API.
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '2.0.0',
  );
}
