import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final String token;
  final Map<String, dynamic>? userInfo;
  
  const AuthAuthenticated({
    required this.token,
    this.userInfo,
  });
  
  @override
  List<Object?> get props => [token, userInfo];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when authentication fails
class AuthFailure extends AuthState {
  final String error;
  
  const AuthFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

/// State when registration is successful
/// User needs to login after registration
class RegistrationSuccess extends AuthState {
  final String message;
  
  const RegistrationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
