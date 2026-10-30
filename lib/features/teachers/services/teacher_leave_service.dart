import 'package:dio/dio.dart';
import 'package:smartkids_admin/core/network/api_client.dart';

import '../models/teacher_leave_model.dart';

class TeacherLeaveService {
  final ApiClient _apiClient;

  TeacherLeaveService(this._apiClient);

  // GET /api/v1/teacher-leaves
  // SCHOOL_ADMIN: all leaves belonging to the logged-in school.

  Future<List<TeacherLeave>> getAllSchoolLeaves() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/teacher-leaves',
      );

      final data = response.data;

      List<dynamic> items;

      if (data is List) {
        items = data;
      } else if (data is Map && data['content'] is List) {
        items = data['content'] as List;
      } else {
        return [];
      }

      return items
          .whereType<Map>()
          .map(
            (json) => TeacherLeave.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to load teacher leaves: $e');
    }
  }

  String _handleError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    if (statusCode == 403) {
      return 'You do not have permission to view teacher leaves.';
    }

    if (statusCode == 404) {
      return 'Teacher leave API not found.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your connection.';
    }

    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return error.message ?? 'Something went wrong.';
  }
}