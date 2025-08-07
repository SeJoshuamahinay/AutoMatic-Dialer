import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/blocs/auth/auth_state.dart';
import 'package:lenderly_dialer/commons/services/login_service.dart';

/// AuthBloc handles authentication state management for the app
/// Integrates with Sanctum token-based authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginService _loginService;
  StreamSubscription<bool>? _authStatusSubscription;

  AuthBloc({required LoginService loginService})
    : _loginService = loginService,
      super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthAutoLoginRequested>(_onAutoLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);

    // Listen to authentication status changes from LoginService
    _authStatusSubscription = _loginService.authStatusStream.listen((
      isAuthenticated,
    ) async {
      if (isAuthenticated) {
        final userSession = await _loginService.getCurrentUserSession();
        if (userSession != null) {
          add(
            AuthStatusChanged(
              isAuthenticated: true,
              userToken: userSession.token,
              username: userSession.fullName,
            ),
          );
        }
      } else {
        add(const AuthStatusChanged(isAuthenticated: false));
      }
    });
  }

  /// Handle authentication check requests
  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isAuthenticated = await _loginService.isAuthenticated();
      if (isAuthenticated) {
        final userSession = await _loginService.getCurrentUserSession();
        if (userSession != null) {
          emit(
            AuthAuthenticated(
              userToken: userSession.token,
              username: userSession.fullName,
              email: userSession.email,
              loginTime: userSession.loginTime,
              loginType: userSession.loginType,
            ),
          );
          return;
        }
      }

      // If not authenticated, try auto-login with Remember Me
      final autoLoginResult = await _loginService.autoLogin();
      if (autoLoginResult.success) {
        final userSession = await _loginService.getCurrentUserSession();
        if (userSession != null) {
          emit(
            AuthAuthenticated(
              userToken: userSession.token,
              username: userSession.fullName,
              email: userSession.email,
              loginTime: userSession.loginTime,
              loginType: userSession.loginType,
            ),
          );
          return;
        }
      }

      // No authentication available
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Authentication check failed: ${e.toString()}'));
    }
  }

  /// Handle login requests with Remember Me support
  void _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Validate input before making API call
      if (event.identifier.isEmpty) {
        emit(const AuthError('Please enter your email or username'));
        return;
      }

      if (event.password.isEmpty) {
        emit(const AuthError('Please enter your password'));
        return;
      }

      // Attempt login
      final result = await _loginService.login(
        identifier: event.identifier,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      if (result.success) {
        // Get fresh user session after successful login
        final userSession = await _loginService.getCurrentUserSession();

        if (userSession != null) {
          emit(
            AuthAuthenticated(
              userToken: userSession.token,
              username: userSession.fullName,
              email: userSession.email,
              loginTime: userSession.loginTime,
              loginType: userSession.loginType,
            ),
          );
        } else {
          // This shouldn't happen if login was successful, but handle gracefully
          emit(
            const AuthError(
              'Login succeeded but failed to retrieve user session',
            ),
          );
        }
      } else {
        // Backend returned specific error message
        emit(AuthError(result.message));
      }
    } catch (e) {
      // Handle unexpected errors with user-friendly message
      emit(
        const AuthError(
          'Login failed. Please check your connection and try again.',
        ),
      );
    }
  }

  /// Handle auto-login requests (Remember Me functionality)
  void _onAutoLoginRequested(
    AuthAutoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _loginService.autoLogin();

      if (result.success) {
        final userSession = await _loginService.getCurrentUserSession();

        if (userSession != null) {
          emit(
            AuthAuthenticated(
              userToken: userSession.token,
              username: userSession.fullName,
              email: userSession.email,
              loginTime: userSession.loginTime,
              loginType: userSession.loginType,
            ),
          );
        } else {
          // Auto-login succeeded but no user session - this shouldn't happen
          emit(AuthUnauthenticated());
        }
      } else {
        // Auto-login failed (expired credentials, etc.) - silently redirect to login
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Auto-login errors should not show to user - just redirect to login
      emit(AuthUnauthenticated());
    }
  }

  /// Handle logout requests
  void _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _loginService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails on backend, clear local state
      // This ensures user can't get stuck in authenticated state
      emit(AuthUnauthenticated());
    }
  }

  /// Handle authentication status changes from LoginService
  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated && event.username != null) {
      // Try to get full user session for complete information
      final userSession = await _loginService.getCurrentUserSession();

      if (userSession != null) {
        emit(
          AuthAuthenticated(
            userToken: userSession.token,
            username: userSession.fullName,
            email: userSession.email,
            loginTime: userSession.loginTime,
            loginType: userSession.loginType,
          ),
        );
      } else {
        // Fallback if user session is not available
        emit(
          AuthAuthenticated(
            userToken: event.userToken,
            username: event.username!,
            email: event.username!.contains('@')
                ? event.username!
                : 'unknown@example.com',
            loginTime: DateTime.now(),
            loginType: 'sanctum',
          ),
        );
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    return super.close();
  }
}
