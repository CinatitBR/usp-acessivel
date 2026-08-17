import 'package:flutter/material.dart';

// Pages
import 'route_page.dart';
import 'map_page.dart';

void main() {
  runApp(const MainApp());
}

/*
  Styling in the StatefulWidget fixes the hot reload issue where changing
  the hardcoded style was not updating the map.
*/
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const RoutePage(),
        '/second': (context) => const MapPage(),
      },
    );
  }
}
