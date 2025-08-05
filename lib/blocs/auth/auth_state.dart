import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String? userToken;
  final String username;
  final String email;
  final DateTime loginTime;
  final String loginType;

  const AuthAuthenticated({
    this.userToken,
    required this.username,
    required this.email,
    required this.loginTime,
    this.loginType = 'sanctum',
  });

  @override
  List<Object?> get props => [userToken, username, email, loginTime, loginType];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
