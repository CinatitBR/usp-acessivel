import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/api_client.dart';
import '../models/map_report_model.dart';

class MapReportService {
  final Dio _dio;

  MapReportService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<List<MapReport>> getMapReports({
    required double minLat,
    required double maxLat,
    required double minLon,
    required double maxLon,
  }) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
    try {
      final response = await _dio.get(
        '$baseUrl/mapReports',
        queryParameters: {
          'minLat': minLat,
          'maxLat': maxLat,
          'minLon': minLon,
          'maxLon': maxLon,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data
            .map((item) => MapReport.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching map reports: $e');
      return [];
    }
  }
}
