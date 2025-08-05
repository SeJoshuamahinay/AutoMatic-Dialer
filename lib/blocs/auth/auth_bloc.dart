import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/blocs/auth/auth_event.dart';
import 'package:lenderly_dialer/blocs/auth/auth_state.dart';
import 'package:lenderly_dialer/commons/services/api_login_service.dart';

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
    _authStatusSubscription = _loginService.authStatusStream.listen(
      (isAuthenticated) async {
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
      },
    );
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
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
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
      final result = await _loginService.login(
        identifier: event.identifier,
        password: event.password,
        rememberMe: event.rememberMe,
      );

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
          // Fallback if userSession is null but login was successful
          emit(
            AuthAuthenticated(
              userToken: result.token,
              username: result.username ?? 'User',
              email: event.identifier,
              loginTime: DateTime.now(),
              loginType: 'sanctum',
            ),
          );
        }
      } else {
        emit(AuthError(result.message));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
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
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
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
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  /// Handle authentication status changes from LoginService
  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.isAuthenticated && event.username != null) {
      emit(
        AuthAuthenticated(
          userToken: event.userToken,
          username: event.username!,
          email: event.userToken ?? 'unknown@example.com', // Fallback email
          loginTime: DateTime.now(),
          loginType: 'sanctum',
        ),
      );
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
