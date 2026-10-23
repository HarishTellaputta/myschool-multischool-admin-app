import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  // =========================
  // REGISTER
  // =========================

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER RESPONSE: ${response.data}');
    } on DioException catch (e) {
      print('REGISTER ERROR: ${e.response?.data}');
      print('REGISTER STATUS: ${e.response?.statusCode}');

      throw Exception(e.response?.data?['message'] ?? 'Registration failed');
    }
  }

  // =========================
  // LOGIN
  // =========================

 
Future<String> login({
  required String username,
  required String password,
}) async {
  try {
    final response = await apiClient.dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception('Invalid login response');
    }

    final token = data['token'];
    final userId = data['userId'];
    final responseUsername = data['username'];
    final role = data['role'];
    final schoolId = data['schoolId'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Token not received');
    }

    if (userId == null) {
      throw Exception('User ID not received');
    }

    if (role == null || role.toString().isEmpty) {
      throw Exception('User role not received');
    }

    final parsedUserId = int.tryParse(userId.toString());
    if (parsedUserId == null) {
      throw Exception('Invalid user ID received');
    }

    int? parsedSchoolId;
    if (schoolId != null) {
      parsedSchoolId = int.tryParse(schoolId.toString());

      if (parsedSchoolId == null) {
        throw Exception('Invalid school ID received');
      }
    }

    final jwtToken = token.toString();
    final prefs = await SharedPreferences.getInstance();

    // Clear any previous user's session before saving this one.
    await prefs.remove('school_id');

    await prefs.setString('jwt_token', jwtToken);
    await prefs.setInt('user_id', parsedUserId);
    await prefs.setString(
      'username',
      responseUsername?.toString() ?? username,
    );
    await prefs.setString('user_role', role.toString());

    if (parsedSchoolId != null) {
      await prefs.setInt('school_id', parsedSchoolId);
    }

    // Do not print the JWT or the full login response.
    print('Login successful');
    print('USER ID: $parsedUserId');
    print('ROLE: $role');
    print('SCHOOL ID: ${parsedSchoolId ?? "Not assigned"}');

    return jwtToken;
  } on DioException catch (e) {
    final data = e.response?.data;

    print('LOGIN STATUS: ${e.response?.statusCode}');

    throw Exception(
      data is Map
          ? data['message']?.toString() ?? 'Login failed'
          : 'Login failed',
    );
  }
}
 // =========================
  // LOGOUT
  // =========================

 
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();

  try {
    await apiClient.dio.post('/auth/logout');
  } on DioException catch (e) {
    // Log out locally even if the server request fails.
    print('LOGOUT STATUS: ${e.response?.statusCode}');
  } finally {
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('user_role');
    await prefs.remove('school_id');
  }
}

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      print('FORGOT PASSWORD STATUS: ${response.statusCode}');

      final data = response.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception('Invalid forgot-password API response');
    } on DioException catch (e) {
      final data = e.response?.data;

      throw Exception(
        data is Map
            ? data['message'] ?? 'Forgot password failed'
            : data?.toString() ?? 'Forgot password failed',
      );
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================

  Future<String> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      print('RESET PASSWORD STATUS: ${response.statusCode}');
      print('RESET PASSWORD RESPONSE: ${response.data}');

      return response.data.toString();
    } on DioException catch (e) {
      print('RESET PASSWORD ERROR: ${e.response?.data}');
      print('RESET PASSWORD STATUS: ${e.response?.statusCode}');

      throw Exception(
        e.response?.data is Map
            ? e.response?.data['message'] ?? 'Password reset failed'
            : e.response?.data?.toString() ?? 'Password reset failed',
      );
    }
  }
}
