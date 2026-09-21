import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/api_client.dart';

class BuildingService {
  final Dio _dio;

  BuildingService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<Map<String, dynamic>?> getBuildingAccessibility(String buildingId) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
    try {
      final response = await _dio.get('$baseUrl/buildings/$buildingId/accessibility');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch building accessibilities: $e');
    }
  }
}
