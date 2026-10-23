
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/school_response.dart';

class SchoolService {
  final ApiClient apiClient;

  SchoolService(this.apiClient);

  // =========================
  // IMPORT SCHOOLS FROM EXCEL
  // =========================

  Future<Map<String, dynamic>> importSchoolsExcel({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await apiClient.dio.post(
        '/api/v1/schools/import',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Invalid school import response');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        throw Exception(
          (data['message'] ??
                  data['error'] ??
                  'School Excel import failed.')
              .toString(),
        );
      }

      throw Exception(
        'School Excel import failed '
        '(HTTP ${e.response?.statusCode ?? 'unknown'}).',
      );
    }
  }

  // =========================
  // GET SCHOOL DETAILS
  // =========================

  Future<SchoolResponse> getSchoolDetails(int schoolId) async {
    if (schoolId <= 0) {
      throw Exception('Invalid school ID');
    }

    try {
      final response = await apiClient.dio.get(
        '/api/v1/schools/$schoolId',
      );

      if (response.data is! Map) {
        throw Exception('Invalid school details response');
      }

      return SchoolResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        throw Exception(
          (data['message'] ??
                  data['error'] ??
                  'Failed to load school details')
              .toString(),
        );
      }

      throw Exception(
        'Failed to load school details '
        '(HTTP ${e.response?.statusCode ?? 'unknown'}).',
      );
    }
  }
}
