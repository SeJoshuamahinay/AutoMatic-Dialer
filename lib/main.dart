import 'package:lenderly_dialer/views/main_navigation_view.dart';
import 'package:lenderly_dialer/commons/repositories/test_repository.dart';
import 'package:flutter/material.dart';
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
