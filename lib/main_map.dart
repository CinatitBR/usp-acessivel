import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key, required this.onSelectBuilding});

  final void Function(String) onSelectBuilding;

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late final MapLibreMapController _controller;

  void handleStyleLoaded() async {
    // Remove basemap layers
    await _controller.removeLayer('poi_r1');
    await _controller.removeLayer('poi_r7');
    await _controller.removeLayer('poi_r20');

    String buildingsStr = await rootBundle.loadString(
      'data/usp_buildings.geojson',
    );
    final buildingsGeojson =
        await jsonDecode(buildingsStr) as Map<String, dynamic>;

    // --- SOURCES ---
    await _controller.addGeoJsonSource('usp_buildings_src', buildingsGeojson);
    final ByteData schoolIconBytes = await rootBundle.load(
      'assets/map-icons/school-icon.png',
    );

    await _controller.addImage(
      'school_icon',
      schoolIconBytes.buffer.asUint8List(),
    );

    // --- LAYERS ---
    await _controller.addSymbolLayer(
      'usp_buildings_src',
      'usp_buildings_layer',
      SymbolLayerProperties(
        // Layout
        textField: '{display_name}',
        textFont: ['Noto Sans Italic'],
        iconImage: 'school_icon',
        iconSize: 0.5,
        textSize: 12,
        textAnchor: 'top',
        textOffset: [0, 1],
        textMaxWidth: 12,
        symbolPlacement: 'point',
        // Paint
        textColor: '#666',
        textHaloColor: '#FFFFFF',
        textHaloWidth: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: 'https://tiles.openfreemap.org/styles/liberty',
      initialCameraPosition: CameraPosition(
        target: LatLng(-23.55921, -46.7317),
        zoom: 17,
      ),
      onMapCreated: (controller) {
        _controller = controller;
      },
      onStyleLoadedCallback: handleStyleLoaded,
      featureTapsTriggersMapClick: true,
      onMapClick: (point, coordinates) async {
        final features = await _controller.queryRenderedFeatures(point, [
          'usp_buildings_layer',
        ], null);

        // If no feature was matched at that screen pixel, stop here
        if (features.isEmpty) return;

        // 3. Extract properties safely from the first intercepted feature
        final feature = features.first;
        final properties = feature['properties'] as Map<String, dynamic>?;

        if (properties != null && properties.containsKey('display_name')) {
          final String buildingName = properties['display_name'].toString();

          // Pass the building string back up to the parent component
          widget.onSelectBuilding(buildingName);
        }
      },
    );
  }
}
