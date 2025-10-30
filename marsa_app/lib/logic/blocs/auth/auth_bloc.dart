import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/repositories/auth_repository.dart';
import 'package:marsa_app/logic/blocs/auth/auth_event.dart';
import 'package:marsa_app/logic/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    // Handle AppStarted event
    on<AppStarted>(_onAppStarted);
    
    // Handle LoggedIn event
    on<LoggedIn>(_onLoggedIn);
    
    // Handle LoggedOut event
    on<LoggedOut>(_onLoggedOut);
    
    // Handle LoginRequested event
    on<LoginRequested>(_onLoginRequested);
    
    // Handle RegisterRequested event
    on<RegisterRequested>(_onRegisterRequested);
  }
  
  /// Handle app start - check if user is already authenticated
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // TEMPORARY: Auto-authenticate for testing without backend
      // TODO: Remove this and uncomment the code below when backend is ready
      emit(const AuthAuthenticated(token: 'test_token_for_development'));
      return;
      
      /* ORIGINAL CODE - Uncomment when backend is ready:
      // Check if token exists
      final token = await _authRepository.getToken();
      
      if (token != null && token.isNotEmpty) {
        // Token exists, try to get user profile to validate it
        try {
          final userInfo = await _authRepository.getProfile();
          emit(AuthAuthenticated(token: token, userInfo: userInfo));
        } catch (e) {
          // Token is invalid or expired
          await _authRepository.deleteToken();
          emit(const AuthUnauthenticated());
        }
      } else {
        // No token found
        emit(const AuthUnauthenticated());
      }
      */
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
  
  /// Handle logged in event
  Future<void> _onLoggedIn(
    LoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Save token
      await _authRepository.saveToken(event.token);
      
      // Get user profile
      try {
        final userInfo = await _authRepository.getProfile();
        emit(AuthAuthenticated(token: event.token, userInfo: userInfo));
      } catch (e) {
        // If getting profile fails, still authenticate but without user info
        emit(AuthAuthenticated(token: event.token));
      }
    } catch (e) {
      emit(AuthFailure('Failed to save authentication: ${e.toString()}'));
    }
  }
  
  /// Handle logged out event
  Future<void> _onLoggedOut(
    LoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Delete token
      await _authRepository.deleteToken();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('Failed to logout: ${e.toString()}'));
    }
  }
  
  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emit loading state
    emit(const AuthLoading());
    
    try {
      // Validate input
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthFailure('Email and password are required'));
        return;
      }
      
      // Call login API
      final token = await _authRepository.login(event.email, event.password);
      
      // Save token
      await _authRepository.saveToken(token);
      
      // Get user profile
      try {
        final userInfo = await _authRepository.getProfile();
        emit(AuthAuthenticated(token: token, userInfo: userInfo));
      } catch (e) {
        // If getting profile fails, still authenticate but without user info
        emit(AuthAuthenticated(token: token));
      }
    } catch (e) {
      // Extract error message
      String errorMessage = 'Login failed';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }
      emit(AuthFailure(errorMessage));
    }
  }
  
  /// Handle register request
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emit loading state
    emit(const AuthLoading());
    
    try {
      // Validate input
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthFailure('Email and password are required'));
        return;
      }
      
      if (event.password.length < 6) {
        emit(const AuthFailure('Password must be at least 6 characters'));
        return;
      }
      
      // Call register API
      await _authRepository.register(event.email, event.password, event.name);
      
      // Registration successful - emit success state
      // User needs to login after registration
      emit(const RegistrationSuccess('Registration successful! Please login.'));
      
      // After a brief moment, transition to unauthenticated state
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Extract error message
      String errorMessage = 'Registration failed';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }
      emit(AuthFailure(errorMessage));
    }
  }
}
