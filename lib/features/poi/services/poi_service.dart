import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/api_client.dart';

class PoiService {
  final Dio _dio = ApiClient.instance;

  Future<void> createPoi(Map<String, dynamic> data) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
    final response = await _dio.post('$baseUrl/pois', data: data);

    if (response.statusCode == 201 && response.data['success'] == true) {
      return;
    } else {
      throw Exception('Failed to create POI');
    }
  }
}
