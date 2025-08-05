import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String identifier; // Email or username
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [identifier, password, rememberMe];
}

class AuthAutoLoginRequested extends AuthEvent {
  const AuthAutoLoginRequested();
}

class AuthLogoutRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final bool isAuthenticated;
  final String? userToken;
  final String? username;

  const AuthStatusChanged({
    required this.isAuthenticated,
    this.userToken,
    this.username,
  });

  @override
  List<Object> get props => [isAuthenticated, userToken ?? '', username ?? ''];
}

class AuthCheckRequested extends AuthEvent {}
