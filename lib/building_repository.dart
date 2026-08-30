import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Parse usp_buildings.geojson to extract id and name of buildings, and cache the result to be used
// across the app lifecycle.

class BuildingRepository {
  // Singleton pattern
  BuildingRepository._internal();
  static final BuildingRepository instance = BuildingRepository._internal();

  List<DropdownMenuEntry<String>>? _cachedEntries;

  /// Returns the cached entries if already parsed; otherwise parses once and caches.
  Future<List<DropdownMenuEntry<String>>> getBuildingEntries() async {
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
  List<DropdownMenuEntry<String>> get cachedEntries => _cachedEntries ?? [];

  /// Helper parser function running in a background isolate
  static List<DropdownMenuEntry<String>> _parseGeoJsonBuildings(
    String rawJson,
  ) {
    final Map<String, dynamic> decoded = jsonDecode(rawJson);
    final List<dynamic> features = decoded['features'] ?? [];

    final entries = <DropdownMenuEntry<String>>[];
    for (final feature in features) {
      final properties = feature['properties'] as Map<String, dynamic>?;
      if (properties != null) {
        final String? id = properties['id'];
        final String? name = properties['name'];
        if (id != null && name != null) {
          entries.add(DropdownMenuEntry<String>(value: id, label: name));
        }
      }
    }
    return entries;
  }
}
