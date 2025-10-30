import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  // Base URL for the backend API
  static const String baseUrl = 'http://10.0.2.2:3001'; // Android emulator
  // Use 'http://localhost:3001' for iOS simulator
  // Use actual IP address for physical devices
  
  // SharedPreferences key for storing token
  static const String _tokenKey = 'auth_token';
  
  AuthProvider(this._dio, this._prefs) {
    // Configure Dio base options
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  /// Login user with email and password
  /// Returns JWT token on success
  /// Throws DioException on failure
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] as String?;
        if (token == null || token.isEmpty) {
          throw Exception('Token not found in response');
        }
        return token;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        final errorMessage = e.response?.data['error'] ?? 'Login failed';
        throw Exception(errorMessage);
      } else {
        // Network error or timeout
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Register new user
  /// Throws DioException on failure
  Future<void> register(String email, String password, String? name) async {
    try {
      final response = await _dio.post(
        '/api/register',
        data: {
          'email': email,
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );
      
      if (response.statusCode != 201) {
        throw Exception('Registration failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        final errorMessage = e.response?.data['error'] ?? 'Registration failed';
        throw Exception(errorMessage);
      } else {
        // Network error or timeout
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// Save JWT token to SharedPreferences
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }
  
  /// Get JWT token from SharedPreferences
  /// Returns null if token doesn't exist
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }
  
  /// Delete JWT token from SharedPreferences (for logout)
  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }
  
  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Get user profile (requires authentication)
  /// This can be used to validate token and get user info
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final response = await _dio.get(
        '/api/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Token is invalid or expired, delete it
        await deleteToken();
        throw Exception('Authentication token is invalid or expired');
      }
      throw Exception('Failed to get profile: ${e.message}');
    }
  }
}
