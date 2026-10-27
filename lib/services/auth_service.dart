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

 
// =========================
// LOGIN
// =========================

Future<String> login({
  required String schoolCode,
  required String username,
  required String password,
}) async {
  try {
    final normalizedSchoolCode = schoolCode.trim().toUpperCase();

    if (normalizedSchoolCode.isEmpty) {
      throw Exception('Please enter school code');
    }

    final response = await apiClient.dio.post(
      '/auth/login',
      data: {
        'schoolCode': normalizedSchoolCode,
        'username': username.trim(),
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

    // Clear the previous session's school ID.
    await prefs.remove('school_id');

    await prefs.setString('jwt_token', jwtToken);
    await prefs.setInt('user_id', parsedUserId);
    await prefs.setString(
      'username',
      responseUsername?.toString() ?? username.trim(),
    );
    await prefs.setString('user_role', role.toString());

    if (parsedSchoolId != null) {
      await prefs.setInt('school_id', parsedSchoolId);
    }

    print('Login successful');
    print('USER ID: $parsedUserId');
    print('ROLE: $role');
    print('SCHOOL ID: ${parsedSchoolId ?? "Not assigned"}');

    return jwtToken;
  } on DioException catch (e) {
    final errorData = e.response?.data;

    print('LOGIN STATUS: ${e.response?.statusCode}');

    throw Exception(
      errorData is Map
          ? errorData['message']?.toString() ?? 'Login failed'
          : 'Login failed',
    );
  }
} // =========================
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

 Future<String> forgotPassword({
  required String schoolCode,
  required String email,
}) async {
  try {
    final normalizedSchoolCode = schoolCode.trim().toUpperCase();
    final normalizedEmail = email.trim();

    if (normalizedSchoolCode.isEmpty) {
      throw Exception('Please enter school code');
    }

    if (normalizedEmail.isEmpty) {
      throw Exception('Please enter your email');
    }

    final response = await apiClient.dio.post(
      '/auth/forgot-password',
      data: {
        'schoolCode': normalizedSchoolCode,
        'email': normalizedEmail,
      },
    );

    final data = response.data;

    if (data is Map) {
      final token = data['resetToken'] ?? data['token'];

      if (token != null && token.toString().trim().isNotEmpty) {
        return token.toString().trim();
      }

      throw Exception(
        data['message']?.toString() ??
            'The server did not return a reset token.',
      );
    }

    throw Exception('Invalid forgot-password API response.');
  } on DioException catch (e) {
    final data = e.response?.data;

    throw Exception(
      data is Map
          ? data['message']?.toString() ??
              'Forgot password request failed.'
          : 'Forgot password request failed.',
    );
  }
}// =========================
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
