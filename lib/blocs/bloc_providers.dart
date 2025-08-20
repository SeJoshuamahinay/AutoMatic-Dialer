import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/dialer/dialer_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/break/break_bloc.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../commons/repositories/test_repository.dart';
import '../commons/services/login_service.dart';

/// Centralized Bloc Providers Configuration
///
/// This file contains all the bloc providers for the application.
/// Benefits:
/// - Centralized configuration
/// - Easy to manage dependencies
/// - Clean separation of concerns
/// - Easier testing and mocking
class BlocProviders {
  /// Creates and returns the MultiBlocProvider with all app blocs
  static MultiBlocProvider create({required Widget child}) {
    // Initialize dependencies
    final baseRepository = TestRepository();
    final loginService = LoginService();

    return MultiBlocProvider(
      providers: [
        // Dialer Bloc - Manages call dialing functionality
        BlocProvider<DialerBloc>(
          create: (context) => DialerBloc(repository: baseRepository),
        ),

        // Auth Bloc - Manages authentication state
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(loginService: loginService),
        ),

        // Break Bloc - Manages break session functionality
        BlocProvider<BreakBloc>(create: (context) => BreakBloc()),

        // Dashboard Bloc - Manages dashboard data and state
        BlocProvider<DashboardBloc>(create: (context) => DashboardBloc()),
      ],
      child: child,
    );
  }

  /// Alternative method for creating providers as a list
  /// Useful when you need to inject providers into existing MultiBlocProvider
  static List<BlocProvider> createProvidersList() {
    // Initialize dependencies
    final baseRepository = TestRepository();
    final loginService = LoginService();

    return [
      BlocProvider<DialerBloc>(
        create: (context) => DialerBloc(repository: baseRepository),
      ),
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(loginService: loginService),
      ),
      BlocProvider<BreakBloc>(create: (context) => BreakBloc()),
      BlocProvider<DashboardBloc>(create: (context) => DashboardBloc()),
    ];
  }

  /// For testing purposes - creates providers with mock dependencies
  static MultiBlocProvider createForTesting({
    required Widget child,
    TestRepository? mockRepository,
    LoginService? mockLoginService,
  }) {
    final baseRepository = mockRepository ?? TestRepository();
    final loginService = mockLoginService ?? LoginService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<DialerBloc>(
          create: (context) => DialerBloc(repository: baseRepository),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(loginService: loginService),
        ),
        BlocProvider<BreakBloc>(create: (context) => BreakBloc()),
        BlocProvider<DashboardBloc>(create: (context) => DashboardBloc()),
      ],
      child: child,
    );
  }
}
