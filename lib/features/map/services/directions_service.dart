import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/api_client.dart';

// API to retrieve route directions from the openrouteservice api
class DirectionsService {
  final Dio _dio = ApiClient.instance;
  final String _apiKey = dotenv.env['OPEN_ROUTE_SERVICE_API_KEY'] ?? '';
  final String _baseUrl =
      'https://api.heigit.org/openrouteservice/v2/directions';

  /// Retrieves directions for a route between two points.
  ///
  /// The [profile] specifies the mode of transportation: (e.g., wheelchair, foot-walking).
  /// Coordinates are expected as longitude and latitude pairs: [lonStart] and
  /// [latStart] for the departure point, and [lonEnd] and [latEnd] for the
  /// destination.
  ///
  /// Returns a [Future] containing a GeoJSON map representing the directions.
  /// Throws an [Exception] if the network request fails or returns a non-200 status.
  Future<dynamic> directions(
    String profile,
    double lonStart,
    double latStart,
    double lonEnd,
    double latEnd,
  ) async {
    final endpoint =
        '$_baseUrl/$profile?api_key=$_apiKey&start=$lonStart,$latStart&end=$lonEnd,$latEnd';
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      throw Exception('ERROR - Could not retrieve directions: $e');
    }
  }
}
