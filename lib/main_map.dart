import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late final MapLibreMapController _controller;

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
      onStyleLoadedCallback: () async {
        await _controller.removeLayer('poi_r1');
        await _controller.removeLayer('poi_r7');
        await _controller.removeLayer('poi_r20');
      },
    );
  }
}
