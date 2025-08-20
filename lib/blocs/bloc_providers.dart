import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/dialer/dialer_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/break/break_bloc.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../commons/repositories/test_repository.dart';
import '../commons/services/login_service.dart';
import '../commons/services/break_service.dart';
import '../database/app_database.dart';

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
    final database = AppDatabase();
    final breakService = BreakService(database);

    // For now, we'll use a default user ID of 1
    // In a real app, this would come from authentication
    const defaultUserId = 1;
    const defaultAgentName = 'Agent';

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
        BlocProvider<BreakBloc>(
          create: (context) => BreakBloc(
            breakService: breakService,
            userId: defaultUserId,
            agentName: defaultAgentName,
          ),
        ),

        // Dashboard Bloc - Manages dashboard data and state
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(breakService),
        ),
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
    final database = AppDatabase();
    final breakService = BreakService(database);

    // For now, we'll use a default user ID of 1
    const defaultUserId = 1;
    const defaultAgentName = 'Agent';

    return [
      BlocProvider<DialerBloc>(
        create: (context) => DialerBloc(repository: baseRepository),
      ),
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(loginService: loginService),
      ),
      BlocProvider<BreakBloc>(
        create: (context) => BreakBloc(
          breakService: breakService,
          userId: defaultUserId,
          agentName: defaultAgentName,
        ),
      ),
      BlocProvider<DashboardBloc>(
        create: (context) => DashboardBloc(breakService),
      ),
    ];
  }

  /// For testing purposes - creates providers with mock dependencies
  static MultiBlocProvider createForTesting({
    required Widget child,
    TestRepository? mockRepository,
    LoginService? mockLoginService,
    BreakService? mockBreakService,
  }) {
    final baseRepository = mockRepository ?? TestRepository();
    final loginService = mockLoginService ?? LoginService();
    final database = AppDatabase();
    final breakService = mockBreakService ?? BreakService(database);

    const defaultUserId = 1;
    const defaultAgentName = 'Test Agent';

    return MultiBlocProvider(
      providers: [
        BlocProvider<DialerBloc>(
          create: (context) => DialerBloc(repository: baseRepository),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(loginService: loginService),
        ),
        BlocProvider<BreakBloc>(
          create: (context) => BreakBloc(
            breakService: breakService,
            userId: defaultUserId,
            agentName: defaultAgentName,
          ),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(breakService),
        ),
      ],
      child: child,
    );
  }
}
