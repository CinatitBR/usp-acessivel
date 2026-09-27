import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import 'package:maplibre/maplibre.dart';

import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/utils/utils.dart';
import 'package:usp_acessivel/features/map/models/route_accessibility_point.dart';

class MainMap extends StatefulWidget {
  const MainMap({
    super.key,
    required this.onSelect,
    this.targetCenter,
    this.onReportSelect,
    this.routeGeoJson,
    this.routeBounds,
    this.routeAccessibilityPoints = const [],
    this.onRouteAccessibilityPointSelect,
    this.onBusStopSelect,
    this.styleUrl = 'https://tiles.openfreemap.org/styles/liberty',
  });

  final void Function(String) onSelect;
  final VoidCallback? onReportSelect;
  final Geographic? targetCenter;
  final Map<String, dynamic>? routeGeoJson;
  final LngLatBounds? routeBounds;
  final List<RouteAccessibilityPoint> routeAccessibilityPoints;
  final ValueChanged<String>? onRouteAccessibilityPointSelect;
  final ValueChanged<Map<String, dynamic>>? onBusStopSelect;
  final String styleUrl;

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  MapController? _controller;
  late final Future<List<Feature<LineString>>> _waysFuture;
  String? _selectedWayGeoJson;

  static String? _cachedWaysStr;
  static String? _cachedBuildingsStr;
  static String? _cachedBusStopsStr;

  @override
  void initState() {
    super.initState();
    _waysFuture = loadWays();
  }

  @override
  void didUpdateWidget(MainMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetCenter != null &&
        widget.targetCenter != oldWidget.targetCenter) {
      _controller?.moveCamera(center: widget.targetCenter, zoom: 17);
    }

    if (widget.routeBounds != null &&
        widget.routeBounds != oldWidget.routeBounds) {
      _controller?.fitBounds(
        bounds: widget.routeBounds!,
        padding: const EdgeInsets.all(50),
      );
    }

    if (widget.routeGeoJson != oldWidget.routeGeoJson) {
      _updateRouteLine();
    }

    if (widget.routeAccessibilityPoints != oldWidget.routeAccessibilityPoints) {
      _updateRouteAccessibilitySource();
    }

    if (widget.styleUrl != oldWidget.styleUrl) {
      _controller?.setStyle(widget.styleUrl);
    }
  }

  Future<void> _updateRouteAccessibilitySource() async {
    try {
      final features = widget.routeAccessibilityPoints.map((point) {
        return {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [point.longitude, point.latitude],
          },
          'properties': {
            'id': point.id,
            'icon': point.iconId,
            'title': point.title,
          },
        };
      }).toList();

      await _controller?.style?.updateGeoJsonSource(
        id: 'route_accessibility_points',
        data: jsonEncode({'type': 'FeatureCollection', 'features': features}),
      );
    } catch (e) {
      debugPrint('Error updating route accessibility points: $e');
    }
  }

  Future<void> _updateRouteLine() async {
    try {
      if (widget.routeGeoJson != null) {
        await _controller?.style?.updateGeoJsonSource(
          id: 'directions_route',
          data: jsonEncode(widget.routeGeoJson),
        );
      } else {
        await _controller?.style?.updateGeoJsonSource(
          id: 'directions_route',
          data: '{"type": "FeatureCollection", "features": []}',
        );
      }
    } catch (e) {
      debugPrint('Error updating route line: $e');
    }
  }

  void _handleMapClick(MapEventClick event) async {
    final controller = _controller;
    if (controller == null) return;

    // Check for route accessibility points first
    final featuresAccessibility = controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['route_accessibility_layer'],
    );
    if (featuresAccessibility.isNotEmpty) {
      final pointFeature = featuresAccessibility.first;
      final pointId = pointFeature.properties['id'] as String?;
      if (pointId != null && widget.onRouteAccessibilityPointSelect != null) {
        widget.onRouteAccessibilityPointSelect!(pointId);
      }
      return;
    }

    // Check for map reports first
    final featuresReports = controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['map_reports_layer'],
    );
    if (featuresReports.isNotEmpty) {
      if (widget.onReportSelect != null) {
        widget.onReportSelect!();
      }
      return; // Stop processing other clicks if a report was clicked
    }

    // Check for bus stops
    final featuresBusStops = controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['bus_stops_layer'],
    );
    if (featuresBusStops.isNotEmpty) {
      final stopFeature = featuresBusStops.first;
      if (widget.onBusStopSelect != null) {
        widget.onBusStopSelect!(
          Map<String, dynamic>.from(stopFeature.properties),
        );
      }
      return;
    }

    final features = controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['ways', 'usp_buildings'],
    );

    final featuresBuildings = controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['usp_buildings'],
    );
    if (featuresBuildings.isNotEmpty) {
      final buildingClicked = featuresBuildings.first;
      final buildingName = buildingClicked.properties['name'];
      if (buildingName is String) {
        widget.onSelect(buildingName);
      }
    }

    if (features.isEmpty) {
      _selectedWayGeoJson = null;
      await controller.style?.updateGeoJsonSource(
        id: 'selected-way',
        data: '{"type": "FeatureCollection", "features": []}',
      );
      return;
    }

    final loadedWays = await _waysFuture;
    final selectedWay = features.first;

    final wayFeature = loadedWays.firstWhereOrNull((feat) {
      return feat.properties["@id"] == selectedWay.properties["@id"];
    });

    final geometry = wayFeature?.geometry;

    if (geometry != null) {
      final bufferGeometry = bufferLineString(geometry, 0.00002);
      final wayBuffer = Feature(geometry: bufferGeometry);

      _selectedWayGeoJson = wayBuffer.toString();
      await controller.style?.updateGeoJsonSource(
        id: 'selected-way',
        data: _selectedWayGeoJson!,
      );
    }
  }

  void _handleStyleLoaded(StyleController style) async {
    // Remove layers if present (safely handle styles that don't have them)
    for (final layerId in ['poi_r1', 'poi_r7', 'poi_r20']) {
      try {
        await style.removeLayer(layerId);
      } catch (_) {
        // Layer may not exist in minimal styles like Positron
      }
    }

    // Load data with in-memory caching
    _cachedWaysStr ??= await rootBundle.loadString('data/ways.json');
    _cachedBuildingsStr ??= await rootBundle.loadString(
      'data/usp_buildings.geojson',
    );
    _cachedBusStopsStr ??= await rootBundle.loadString('data/bus-stops.geojson');

    // --- Sources ---
    await style.addSource(GeoJsonSource(id: 'ways', data: _cachedWaysStr!));
    await style.addSource(GeoJsonSource(id: 'buildings', data: _cachedBuildingsStr!));
    await style.addSource(GeoJsonSource(id: 'bus_stops', data: _cachedBusStopsStr!));
    await style.addSource(
      GeoJsonSource(
        id: 'selected-way',
        data: _selectedWayGeoJson ?? '{"type": "FeatureCollection", "features": []}',
      ),
    );

    // Map reports source
    final mapReportsFeatureCollection = FeatureCollection([
      Feature<Point>(
        geometry: Point(Position.create(x: -46.72695, y: -23.56289)),
        properties: {'type': 'report'},
      ),
    ]);
    await style.addSource(
      GeoJsonSource(
        id: 'map_reports',
        data: mapReportsFeatureCollection.toString(),
      ),
    );

    // Route accessibility source
    final routeAccFeatures = widget.routeAccessibilityPoints.map((point) {
      return {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [point.longitude, point.latitude],
        },
        'properties': {
          'id': point.id,
          'icon': point.iconId,
          'title': point.title,
        },
      };
    }).toList();
    await style.addSource(
      GeoJsonSource(
        id: 'route_accessibility_points',
        data: jsonEncode({'type': 'FeatureCollection', 'features': routeAccFeatures}),
      ),
    );

    // Directions route line
    await style.addSource(
      GeoJsonSource(
        id: 'directions_route',
        data: widget.routeGeoJson != null
            ? jsonEncode(widget.routeGeoJson)
            : '{"type": "FeatureCollection", "features": []}',
      ),
    );

    // --- Images/Icons ---
    await style.addImageFromAssets(
      id: 'concreto-escuro',
      asset: 'assets/tiles/concreto-escuro.png',
    );

    await style.addImageFromIconData(
      id: 'building-icon',
      iconData: Icons.school,
      color: AppColors.primary,
      size: 24,
    );
    await style.addImageFromAssets(
      id: 'school-icon',
      asset: 'assets/map-icons/school-icon.png',
    );
    await style.addImageFromIconData(
      id: 'report-icon',
      iconData: Icons.stairs,
      color: Colors.red,
      size: 32,
    );
    await style.addImageFromIconData(
      id: 'accessibility-warning-icon',
      iconData: Icons.warning_amber_rounded,
      color: AppColors.warning,
      size: 32,
    );
    await style.addImageFromIconData(
      id: 'accessibility-danger-icon',
      iconData: Icons.error_outline_rounded,
      color: AppColors.error,
      size: 32,
    );
    await style.addImageFromCanvas(
      id: 'bus-stop-badge',
      width: 64,
      height: 64,
      painter: (canvas) {
        final bgPaint = Paint()
          ..color = const Color(0xFF0284C7)
          ..style = PaintingStyle.fill;
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

        // Draw circular background and white border
        canvas.drawCircle(const Offset(32, 32), 28, bgPaint);
        canvas.drawCircle(const Offset(32, 32), 28, borderPaint);

        // Draw bus icon centered in white
        final tp = TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: String.fromCharCode(Icons.directions_bus_rounded.codePoint),
            style: TextStyle(
              fontSize: 32,
              fontFamily: Icons.directions_bus_rounded.fontFamily,
              package: Icons.directions_bus_rounded.fontPackage,
              color: Colors.white,
            ),
          )
          ..layout();

        tp.paint(canvas, Offset((64 - tp.width) / 2, (64 - tp.height) / 2));
      },
    );

    // --- Layers ---
    // Ways layer
    await style.addLayer(
      const LineStyleLayer(
        sourceId: 'ways',
        id: 'ways',
        layout: {'line-cap': 'round', 'line-join': 'round'},
        paint: {'line-color': '#837F7F', 'line-width': 18.0, 'line-opacity': 0.8},
        minZoom: 18,
      ),
    );

    // Selected way buffer layer
    await style.addLayer(
      const FillStyleLayer(
        sourceId: 'selected-way',
        id: 'selected-way-fill',
        paint: {'fill-color': '#FF4081', 'fill-pattern': 'concreto-escuro'},
      ),
    );

    // Directions route layer
    await style.addLayer(
      const LineStyleLayer(
        sourceId: 'directions_route',
        id: 'directions_route_layer',
        layout: {'line-cap': 'round', 'line-join': 'round'},
        paint: {'line-color': '#0000FF', 'line-width': 8.0, 'line-opacity': 0.8},
        minZoom: 10,
      ),
    );

    // Map reports layer
    await style.addLayer(
      SymbolStyleLayer(
        sourceId: 'map_reports',
        id: 'map_reports_layer',
        layout: {
          'icon-image': 'report-icon',
          'icon-size': 1.0,
          'icon-allow-overlap': true,
          'icon-ignore-placement': true,
        },
        minZoom: 14,
      ),
    );

    // Route accessibility layer
    await style.addLayer(
      SymbolStyleLayer(
        sourceId: 'route_accessibility_points',
        id: 'route_accessibility_layer',
        layout: {
          'icon-image': ['get', 'icon'],
          'icon-size': 1.0,
          'icon-allow-overlap': true,
          'icon-ignore-placement': true,
        },
        minZoom: 13,
      ),
    );

    // Buildings layer
    await style.addLayer(
      SymbolStyleLayer(
        sourceId: 'buildings',
        id: 'usp_buildings',
        layout: {
          'text-field': ['get', 'display_name'],
          'text-font': ['Noto Sans Italic'],
          'icon-image': 'school-icon',
          'icon-size': 0.5,
          'text-size': 12,
          'text-anchor': 'top',
          'text-offset': [0, 1.1],
          'text-max-width': 8,
          'symbol-placement': 'point',
        },
        paint: {
          'text-color': '#1E5AE8',
          'text-halo-color': '#FFFFFF',
          'text-halo-width': 1.5,
        },
        minZoom: 15,
      ),
    );

    // Bus stops layer
    await style.addLayer(
      SymbolStyleLayer(
        sourceId: 'bus_stops',
        id: 'bus_stops_layer',
        layout: {
          'icon-image': 'bus-stop-badge',
          'icon-size': 0.45,
          'symbol-placement': 'point',
          'icon-allow-overlap': false,
          'icon-ignore-placement': false,
          'text-field': [
            'coalesce',
            ['get', 'name'],
            ['get', 'local_ref'],
            '',
          ],
          'text-font': ['Noto Sans Regular'],
          'text-size': 11,
          'text-anchor': 'top',
          'text-offset': [0, 1.1],
          'text-max-width': 8,
          'text-optional': true,
          'text-allow-overlap': false,
        },
        paint: {
          'text-color': '#0F172A',
          'text-halo-color': '#FFFFFF',
          'text-halo-width': 1.5,
        },
        minZoom: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      options: MapOptions(
        initStyle: widget.styleUrl,
        initCenter: initCenter,
        initZoom: 17,
        maxBounds: campusBounds,
      ),
      onMapCreated: (controller) => _controller = controller,
      onEvent: (event) {
        if (event is MapEventClick) {
          _handleMapClick(event);
        }
      },
      onStyleLoaded: _handleStyleLoaded,
      // children: widget.children,
    );
  }
}

// -- CONSTANTS --
const LngLatBounds campusBounds = LngLatBounds(
  longitudeWest: -46.745496,
  longitudeEast: -46.710219,
  latitudeSouth: -23.572641,
  latitudeNorth: -23.549471,
);

const Geographic initCenter = Geographic(lon: -46.72746, lat: -23.5574559);

Future<List<Feature<Point>>> loadBuildings() async {
  final jsonString = await rootBundle.loadString('data/usp_buildings.geojson');
  final collection = FeatureCollection.parse(
    jsonString,
    format: GeoJSON.feature,
  );

  final points = collection.features
      .where((feat) => feat.geometry is Point)
      .map(
        (feat) => Feature<Point>(
          geometry: feat.geometry as Point,
          properties: feat.properties,
        ),
      )
      .toList();

  return points;
}

Future<List<Feature<LineString>>> loadWays() async {
  final jsonString = await rootBundle.loadString('data/ways.json');
  final collection = FeatureCollection.parse(
    jsonString,
    format: GeoJSON.feature,
  );

  final ways = collection.features
      .where((feat) => feat.geometry is LineString)
      .map(
        (feat) => Feature<LineString>(
          geometry: feat.geometry as LineString,
          properties: feat.properties,
        ),
      )
      .toList();

  return ways;
}
