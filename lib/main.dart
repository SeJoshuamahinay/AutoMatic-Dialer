import 'package:lenderly_dialer/views/main_navigation_view.dart';
import 'package:lenderly_dialer/commons/repositories/test_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/dialer/dialer_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/break/break_bloc.dart';
import 'commons/services/environment_config.dart';
import 'commons/services/shared_prefs_storage_service.dart';
import 'commons/services/login_service.dart';
import 'views/auth_wrapper.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup comprehensive error handling for gesture and framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Check if this is a mouse tracker assertion error that we want to suppress
    if (details.exception.toString().contains('mouse_tracker.dart') ||
        details.exception.toString().contains('MouseTracker') ||
        details.exception.toString().contains('PointerAddedEvent') ||
        details.exception.toString().contains('PointerRemovedEvent')) {
      // Log but don't crash for gesture errors
      if (kDebugMode) {
        print('Mouse tracker error suppressed: ${details.exception}');
      }
      return;
    }

    // Log other errors but don't crash the app in release mode
    if (EnvironmentConfig.enableLogging) {
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }

    // Only crash in debug mode for development, and not for gesture errors
    if (!kReleaseMode) {
      FlutterError.presentError(details);
    }
  };

  // Handle platform dispatcher errors (like assertion failures)
  PlatformDispatcher.instance.onError = (error, stack) {
    // Check if this is a mouse tracker assertion error
    if (error.toString().contains('mouse_tracker.dart') ||
        error.toString().contains('MouseTracker') ||
        error.toString().contains('PointerAddedEvent') ||
        error.toString().contains('PointerRemovedEvent')) {
      // Log but don't crash for gesture errors
      if (kDebugMode) {
        print('Platform gesture error suppressed: $error');
      }
      return true; // Mark as handled
    }

    if (kDebugMode) {
      print('Platform error: $error');
      print('Stack: $stack');
    }
    return true; // Don't crash the app
  };

  try {
    // Initialize environment configuration
    // Change to Environment.prod for production builds
    await EnvironmentConfig.initialize(environment: Environment.dev);

    // Initialize SharedPreferences for authentication storage
    await SharedPrefsStorageService.initialize();

    if (EnvironmentConfig.enableLogging) {}
  } catch (e) {
    if (EnvironmentConfig.enableLogging) {}
    // Continue with app initialization even if env fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    // Initialize TestRepository for testing purposes
    // This can be used to mock API calls or database interactions in tests
    // Initialize LoginService
    final baseRepository = TestRepository();
    final loginService = LoginService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<DialerBloc>(
          create: (context) => DialerBloc(repository: baseRepository),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(loginService: loginService),
        ),
        BlocProvider<BreakBloc>(create: (context) => BreakBloc()),
      ],
      child: MaterialApp(
        title: 'Dialer App',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Enhanced error boundary for gesture-related errors
          return _GestureErrorWrapper(
            child:
                child ??
                const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
          );
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginView(),
          '/dashboard': (context) => const MainNavigationView(),
        },
      ),
    );
  }
}

/// Enhanced wrapper widget to handle gesture-related errors gracefully
class _GestureErrorWrapper extends StatefulWidget {
  final Widget child;

  const _GestureErrorWrapper({required this.child});

  @override
  State<_GestureErrorWrapper> createState() => _GestureErrorWrapperState();
}

class _GestureErrorWrapperState extends State<_GestureErrorWrapper> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Reset error state when widget is rebuilt
    _hasError = false;
    _errorMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e) {
          // Handle gesture errors specifically
          if (e.toString().contains('mouse_tracker.dart') ||
              e.toString().contains('MouseTracker') ||
              e.toString().contains('PointerAddedEvent') ||
              e.toString().contains('PointerRemovedEvent')) {
            if (kDebugMode) {
              print('Gesture error caught and handled: $e');
            }
            // For gesture errors, try to return child without crashing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = false; // Don't show error for gesture issues
                });
              }
            });
            return widget.child;
          } else {
            // For other errors, show error screen
            if (kDebugMode) {
              print('Critical error caught: $e');
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = kDebugMode ? e.toString() : null;
                });
              }
            });
            return Container(
              color: Colors.white,
              child: const Center(
                child: Text('Loading...', style: TextStyle(fontSize: 16)),
              ),
            );
          }
        }
      },
    );
  }
}
