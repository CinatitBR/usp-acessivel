import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/api_client.dart';

class VisualRouteService {
  final Dio _dio = ApiClient.instance;

  Future<void> createVisualRouteFormData(FormData formData) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
    final String endpoint = '$baseUrl/visualRoutes';

    final response = await _dio.post(endpoint, data: formData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to create route');
    }
  }

  Future<List<dynamic>> getVisualRoutes({int page = 1}) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
    final String endpoint = '$baseUrl/visualRoutes';

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] as List<dynamic>?) ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch visual routes: $e');
    }
  }
}
