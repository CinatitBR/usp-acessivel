import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:meu_campus_flutter/utils.dart';

// const LngLatBounds campusBounds = LngLatBounds(
//   longitudeWest: -46.745496,
//   longitudeEast: -46.710219,
//   latitudeSouth: -23.572641,
//   latitudeNorth: -23.549471,
// );

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: MyMap()));
  }
}

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late final MapController _controller;
  late final Future<List<Feature<LineString>>> _waysFuture;

  @override
  void initState() {
    super.initState();
    _waysFuture = loadWays();
  }

  void _handleMapClick(MapEventClick event) async {
    final features = _controller.featuresAtPoint(
      event.screenPoint,
      layerIds: ['ways'],
    );
    // features contain the clicked features
    print("Features clicked: $features");

    if (features.isEmpty) {
      // Clear 'selected-way' source
      await _controller.style?.updateGeoJsonSource(
        id: 'selected-way',
        data: FeatureCollection(List<Feature<Geometry>>.empty()).toString(),
      );
      return;
    }

    final loadedWays = await _waysFuture;
    final selectedWay = features.first;

    // Find matching feature from loaded snapshot
    final wayFeature = loadedWays.firstWhereOrNull((feat) {
      return feat.properties["@id"] == selectedWay.properties["@id"];
    });

    // 2. Safely extract non-nullable LineString geometry
    final geometry = wayFeature?.geometry;

    if (geometry != null) {
      // 0.0001 degrees ~= 11 meters
      final bufferGeometry = bufferLineString(geometry, 0.00002);
      // Create buffer polygon
      final wayBuffer = Feature(geometry: bufferGeometry);

      await _controller.style?.updateGeoJsonSource(
        id: 'selected-way',
        data: wayBuffer.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      options: MapOptions(
        initStyle: "https://tiles.openfreemap.org/styles/liberty",
        initCenter: initCenter,
        initZoom: 17,
        maxBounds: campusBounds,
      ),
      onMapCreated: (controller) => _controller = controller,
      onEvent: (event) async {
        if (event is MapEventClick) {
          _handleMapClick(event);
        }
      },
      onStyleLoaded: _handleStyleLoaded,
      children: [
        WidgetLayer(
          markers: [
            Marker(
              size: const Size.square(50),
              point: initCenter,
              child: Container(
                width: 450,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(.circular(8)),
                  image: DecorationImage(
                    image: AssetImage("assets/rotas-odonto/exterior-1.webp"),
                    fit: .cover,
                    alignment: .centerStart,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

// Initial center of the map. It's located around INOVA USP
const Geographic initCenter = Geographic(lon: -46.72746, lat: -23.5574559);

// -- AUXILIARY FUNCTIONS --
void _handleStyleLoaded(StyleController style) async {
  final buildingsStr = await rootBundle.loadString('data/buildings.json');
  final waysStr = await rootBundle.loadString('data/ways.json');

  // --- Sources and assets ---
  await style.addSource(GeoJsonSource(id: 'buildings', data: buildingsStr));
  await style.addSource(GeoJsonSource(id: 'ways', data: waysStr));
  await style.addImageFromAssets(
    id: 'concreto-escuro',
    asset: 'assets/tiles/concreto-escuro.png',
  ); // Texture

  // Create selected way source, initially empty.
  // It has exactly one feature when the way is selected and shown.
  await style.addSource(
    GeoJsonSource(
      id: 'selected-way',
      data: FeatureCollection(List<Feature<Geometry>>.empty()).toString(),
    ),
  );

  await style.addImageFromIconData(
    iconData: Icons.apartment,
    id: 'building-icon',
    size: 40,
  );

  // --- Layers ---

  // Ways layer
  await style.addLayer(
    const LineStyleLayer(
      sourceId: 'ways',
      id: 'ways',
      layout: {
        'line-cap': 'round', // Rounds the start and end tips of the lines
        'line-join': 'round', // Rounds sharp corners where line segments meet
      },
      paint: {'line-color': '#837F7F', 'line-width': 18.0, 'line-opacity': 0.8},
      minZoom: 18,
    ),
  );

  // Selected way buffer layer (Fill layer for Polygons)
  await style.addLayer(
    const FillStyleLayer(
      sourceId: 'selected-way',
      id: 'selected-way-fill',
      paint: {'fill-color': '#FF4081', 'fill-pattern': 'concreto-escuro'},
    ),
  );

  // Buildings
  await style.addLayer(
    const SymbolStyleLayer(
      sourceId: 'buildings',
      id: 'buildings',
      layout: {
        'text-field': 'Inova-USP',
        'icon-image': 'building-icon',
        'text-size': 20,
        'text-anchor': 'top',
        'text-offset': [0, 1],
      },
      paint: {
        // --- Text styling ---
        'text-color': '#FFFFFF', // Fill color (White)
        'text-halo-color': '#808080', // Stroke/Outline color (Grey Hex code)
        'text-halo-width': 2.0, // Stroke thickness in pixels
        // --- Icon Styling (Requires SDF Icon) ---
        'icon-color':
            '#FFFFFF', // Change this to your desired Icon Fill Color (e.g., Red)
        'icon-halo-color':
            '#808080', // Change this to your desired Icon Stroke/Outline Color (e.g., Black)
        'icon-halo-width': 1.5, // Icon Stroke thickness in pixels
      },
    ),
  );
}

Future<List<Feature<Point>>> loadBuildings() async {
  final jsonString = await rootBundle.loadString('lib/data/buildings.json');
  // final json = jsonDecode(jsonString) as Map<String, dynamic>;
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
  // final json = jsonDecode(jsonString) as Map<String, dynamic>;
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
