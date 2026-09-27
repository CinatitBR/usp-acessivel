import 'package:flutter/material.dart';

enum AppMapStyle {
  liberty(
    name: 'Detalhado',
    url: 'https://tiles.openfreemap.org/styles/liberty',
    icon: Icons.map_outlined,
  ),
  positron(
    name: 'Minimalista',
    url: 'https://tiles.openfreemap.org/styles/positron',
    icon: Icons.layers_clear_outlined,
  );

  const AppMapStyle({
    required this.name,
    required this.url,
    required this.icon,
  });

  final String name;
  final String url;
  final IconData icon;
}
