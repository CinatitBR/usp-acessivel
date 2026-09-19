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
}
