import 'package:flutter/material.dart';

import 'app_bottom_sheet.dart';
import 'main_map.dart';
import 'app_colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // bool _showBottomSheet = true;
  String? _selectedBuilding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainMap(
          onSelect: (name) => setState(() {
            _selectedBuilding = name;
          }),
        ),
        if (_selectedBuilding != null)
          AppBottomSheet(
            onDismissed: () => setState(() => _selectedBuilding = null),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: Text(
                _selectedBuilding ?? '',
                textAlign: .center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primary[600],
                  fontWeight: FontWeight(700),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
