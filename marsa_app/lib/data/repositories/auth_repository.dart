import 'package:marsa_app/data/providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider;
  
  AuthRepository(this._authProvider);
  
  /// Login user with email and password
  /// Returns JWT token on success
  Future<String> login(String email, String password) async {
    return await _authProvider.login(email, password);
  }
  
  /// Register new user
  Future<void> register(String email, String password, String? name) async {
    await _authProvider.register(email, password, name);
  }
  
  /// Save JWT token
  Future<void> saveToken(String token) async {
    await _authProvider.saveToken(token);
  }
  
  /// Get JWT token
  Future<String?> getToken() async {
    return await _authProvider.getToken();
  }
  
  /// Delete JWT token (logout)
  Future<void> deleteToken() async {
    await _authProvider.deleteToken();
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authProvider.isAuthenticated();
  }
  
  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    return await _authProvider.getProfile();
  }
  
  /// Logout user (delete token)
  Future<void> logout() async {
    await deleteToken();
  }
}
