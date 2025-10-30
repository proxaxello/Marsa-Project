import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event triggered when app starts
/// Used to check if user is already authenticated
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Event triggered when user successfully logged in
/// Contains the JWT token
class LoggedIn extends AuthEvent {
  final String token;
  
  const LoggedIn(this.token);
  
  @override
  List<Object?> get props => [token];
}

/// Event triggered when user logs out
class LoggedOut extends AuthEvent {
  const LoggedOut();
}

/// Event triggered when user requests to login
/// Contains email and password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user requests to register
/// Contains email, password, and optional name
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  
  const RegisterRequested({
    required this.email,
    required this.password,
    this.name,
  });
  
  @override
  List<Object?> get props => [email, password, name];
}
