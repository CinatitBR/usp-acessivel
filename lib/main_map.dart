import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import 'package:maplibre/maplibre.dart';

import 'package:usp_acessivel/app_colors.dart';
import './utils.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key, required this.onSelect, this.targetCenter, this.targetKey});

  final void Function(String) onSelect;
  final Geographic? targetCenter;
  final int? targetKey;

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with TickerProviderStateMixin {
  late final MapController _controller;
  late final Future<List<Feature<LineString>>> _waysFuture;
  late final AnimationController _orbitController;
  late final Animation<double> _orbitAnimation;
  bool _isOrbiting = false;

  @override
  void initState() {
    super.initState();
    _waysFuture = loadWays();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _orbitAnimation = Tween<double>(begin: 0, end: 360).animate(_orbitController)
      ..addListener(() {
        if (_isOrbiting && widget.targetCenter != null) {
          _controller.moveCamera(
            center: widget.targetCenter,
            bearing: _orbitAnimation.value,
            pitch: 60, // 3D perspective
            zoom: 17,
          );
        }
      });
  }

  @override
  void didUpdateWidget(MainMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetCenter != null &&
        (widget.targetCenter != oldWidget.targetCenter || widget.targetKey != oldWidget.targetKey)) {
      _startOrbitAnimation();
    } else if (widget.targetCenter == null && oldWidget.targetCenter != null) {
      _stopOrbitAnimation();
    }
  }

  void _startOrbitAnimation() {
    _isOrbiting = true;
    _orbitController.value = 0.0;
    _orbitController.repeat();
  }

  void _stopOrbitAnimation() {
    if (_isOrbiting) {
      _isOrbiting = false;
      _orbitController.stop();
      _orbitController.value = 0.0;
      _controller.moveCamera(
        center: widget.targetCenter ?? initCenter,
        bearing: 0,
        pitch: 0,
        zoom: 17,
      );
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  void _handleMapClick(MapEventClick event) async {
    final features = _controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['ways', 'usp_buildings'],
    );
    print("Features clicked: $features");

    final featuresBuildings = _controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['usp_buildings'],
    );
    if (featuresBuildings.isNotEmpty) {
      final buildingClicked = featuresBuildings.first;
      print('FEATURE BUILDING CLICKED: $buildingClicked');
      // SELECT THE FEATURE
      final buildingName = buildingClicked.properties['name'];
      print('=== NAME: $buildingName ===');
      if (buildingName is String) {
        // print('É STRING');
        widget.onSelect(buildingName);
      }
    }

    if (features.isEmpty) {
      await _controller.style?.updateGeoJsonSource(
        id: 'selected-way',
        data: FeatureCollection(List<Feature<Geometry>>.empty()).toString(),
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

      await _controller.style?.updateGeoJsonSource(
        id: 'selected-way',
        data: wayBuffer.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (_isOrbiting) {
          _stopOrbitAnimation();
        }
      },
      child: MapLibreMap(
        options: MapOptions(
          initStyle: "https://tiles.openfreemap.org/styles/liberty",
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
      ),
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

// -- AUXILIARY FUNCTIONS --
void _handleStyleLoaded(StyleController style) async {
  // Remove layers
  style.removeLayer('poi_r1');
  style.removeLayer('poi_r7');
  style.removeLayer('poi_r20');

  // Load data
  final waysStr = await rootBundle.loadString('data/ways.json');
  final buildingsStr = await rootBundle.loadString(
    'data/usp_buildings.geojson',
  );
  // --- Sources ---
  await style.addSource(GeoJsonSource(id: 'ways', data: waysStr));
  await style.addSource(GeoJsonSource(id: 'buildings', data: buildingsStr));
  await style.addSource(
    GeoJsonSource(
      id: 'selected-way',
      data: FeatureCollection(List<Feature<Geometry>>.empty()).toString(),
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

  // Buildings layer - FIXED
  await style.addLayer(
    SymbolStyleLayer(
      sourceId: 'buildings',
      id: 'usp_buildings',
      layout: {
        'text-field': ['get', 'display_name'],
        'text-font': ['Noto Sans Italic'],
        'icon-image': 'school-icon', // ✅ FIXED: Use the icon we created
        'icon-size': 0.5,
        'text-size': 12,
        'text-anchor': 'top',
        'text-offset': [0, 1],
        'text-max-width': 8,
        'symbol-placement': 'point',
        // 🛠️ EXTRA INSURANCE: Prevent collision engine from hiding symbols
        'icon-allow-overlap': true,
        'text-allow-overlap': true,
        'icon-ignore-placement': true,
        'text-ignore-placement': true,
      },
      paint: {
        // ✅ ADDED: Paint properties were missing!
        'text-color': '#666',
        'text-halo-color': '#FFFFFF',
        'text-halo-width': 1.5,
      },
      minZoom: 14, // ✅ FIXED: Lowered from 15 to ensure visibility
    ),
  );
}

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
