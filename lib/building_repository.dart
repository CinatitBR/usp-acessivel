import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Parse usp_buildings.geojson to extract id and name of buildings, and cache the result to be used
// across the app lifecycle.

class Building {
  final String id;
  final String name;
  final double longitude;
  final double latitude;

  Building({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
  });
}

class BuildingRepository {
  // Singleton pattern
  BuildingRepository._internal();
  static final BuildingRepository instance = BuildingRepository._internal();

  List<Building>? _cachedEntries;

  /// Returns the cached entries if already parsed; otherwise parses once and caches.
  Future<List<Building>> getBuildingEntries() async {
    if (_cachedEntries != null) {
      return _cachedEntries!;
    }

    final String buildingsStr = await rootBundle.loadString(
      'data/usp_buildings.geojson',
    );

    // Parse off the main thread using compute
    _cachedEntries = await compute(_parseGeoJsonBuildings, buildingsStr);
    return _cachedEntries!;
  }

  /// Synchronous getter to use if already preloaded
  List<Building> get cachedEntries => _cachedEntries ?? [];

  /// Helper parser function running in a background isolate
  static List<Building> _parseGeoJsonBuildings(String rawJson) {
    final Map<String, dynamic> decoded = jsonDecode(rawJson);
    final List<dynamic> features = decoded['features'] ?? [];

    final entries = <Building>[];
    for (final feature in features) {
      final properties = feature['properties'] as Map<String, dynamic>?;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (properties != null && geometry != null) {
        final String? id = properties['id'];
        final String? name = properties['name'];
        final String? type = geometry['type'];
        final List<dynamic>? coordinates = geometry['coordinates'];

        if (id != null &&
            name != null &&
            type == 'Point' &&
            coordinates != null &&
            coordinates.length >= 2) {
          entries.add(
            Building(
              id: id,
              name: name,
              longitude: (coordinates[0] as num).toDouble(),
              latitude: (coordinates[1] as num).toDouble(),
            ),
          );
        }
      }
    }
    return entries;
  }
}
