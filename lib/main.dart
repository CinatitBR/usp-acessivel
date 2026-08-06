// import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
// import 'models.dart';

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
  final jsonString = await rootBundle.loadString('lib/data/ways.json');
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

const LngLatBounds campusBounds = LngLatBounds(
  longitudeWest: -46.745496,
  longitudeEast: -46.710219,
  latitudeSouth: -23.572641,
  latitudeNorth: -23.549471,
);

// Center around INOVA USP
const Geographic initCenter = Geographic(lon: -46.72746, lat: -23.5574559);

void main() {
  runApp(const MainApp());
}

/*
  Styling in the StatefulWidget fixes the hot reload issue where changing
  the hardcoded style was not updating the map.
*/
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final MapController _controller;
  // late final Future<List<Feature<Point>>> _buildingsFuture;
  late final Future<List<Feature<LineString>>> _waysFuture;
  Feature<LineString>? _selectedWay;

  @override
  void initState() {
    super.initState();
    // _buildingsFuture = loadBuildings();
    _waysFuture = loadWays();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //           body: MapLibreMap(
  //             options: MapOptions(
  //               initStyle: "https://tiles.openfreemap.org/styles/liberty",
  //               initCenter: initCenter,
  //               initZoom: 17,
  //               maxBounds: campusBounds,
  //           ),
  //           layers: [
  //           CircleLayer(
  //             points: _buildingsFuture.,
  //             color: Colors.blue,
  //           )
  //         ],
  //         )
  //       )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<List<Feature<LineString>>>(
        future: _waysFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return Scaffold(
            body: MapLibreMap(
              options: MapOptions(
                initStyle: "https://tiles.openfreemap.org/styles/liberty",
                initCenter: initCenter,
                initZoom: 17,
                maxBounds: campusBounds,
              ),
              onMapCreated: (controller) => _controller = controller,
              onEvent: (event) async {
                if (event is MapEventClick) {
                  final features = _controller.featuresAtPoint(
                    event.screenPoint,
                    layerIds: ['ways'],
                  );

                  if (features.isNotEmpty) {
                    print("Features clicked: $features");
                  }
                }
              },
              // layers: [
              //   PolylineLayer(
              //     polylines: snapshot.data ?? [],
              //     color: Colors.pinkAccent,
              //     width: 10,
              //     blur: 3,
              //     minZoom: 17,
              //   ),
              // ],
              onStyleLoaded: (style) async {
                final buildingsStr = await rootBundle.loadString(
                  'lib/data/buildings.json',
                );
                final waysStr = await rootBundle.loadString(
                  'lib/data/ways.json',
                );

                await style.addSource(
                  GeoJsonSource(id: 'buildings', data: buildingsStr),
                );
                await style.addSource(GeoJsonSource(id: 'ways', data: waysStr));

                // await style.addImage('building-icon', iconData);
                await style.addImageFromIconData(
                  iconData: Icons.apartment,
                  id: 'building-icon',
                  size: 40,
                );

                // --- Ways layer ---
                await style.addLayer(
                  const LineStyleLayer(
                    sourceId: 'ways',
                    id: 'ways',
                    layout: {
                      'line-cap':
                          'round', // Rounds the start and end tips of the lines
                      'line-join':
                          'round', // Rounds sharp corners where line segments meet
                    },
                    paint: {
                      'line-color': '#837F7F',
                      'line-width': 18.0,
                      'line-opacity': 0.8,
                    },
                    minZoom: 18,
                  ),
                );

                // --- Buildings layer ---
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
                      'text-halo-color':
                          '#808080', // Stroke/Outline color (Grey Hex code)
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
              },
              //   onStyleLoaded: (style) async {
              //     await style.addSource(
              //       GeoJsonSource(id: 'buildings', data: snapshot.data ?? ''),
              //     );

              //     // Add layer to display the source data
              //     await style.addLayer(
              //       const CircleStyleLayer(
              //         sourceId: 'buildings',
              //         id: 'buildings',
              //         paint: {'circle-color': '#4169E1', 'circle-radius': 30},
              //         // layout: {
              //         //   'circle-color': '#4169E1',
              //         //   'circle-radius': 10,
              //         // }
              //       ),
              //     );
              //   },
              // ),
            ),
          );
        },
      ),
    );
  }
}
