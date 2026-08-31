import 'package:flutter/material.dart';

import 'app_colors.dart';

import 'app_bottom_sheet.dart';
import 'main_map.dart';
import 'create_visual_route_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? _selectedBuilding;

  void _handleActionButtonClick(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: ListTile(
                title: Text('Criar rota visual'),
                subtitle: Text('Envie uma rota visual'),
                // leading: Icon(Icons.route_rounded),
                trailing: Icon(Icons.chevron_right_sharp),
                splashColor: AppColors.neutral[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Clips the splash to these corners
                ),
                onTap: () async {
                  // First, dismiss/close the bottom sheet safely
                  Navigator.of(context).pop();

                  // Push the new full screen page onto the main view
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateVisualRoutePage(),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainMap(
          onSelectBuilding: (String buildingName) {
            setState(() => _selectedBuilding = buildingName);
          },
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: () {
              _handleActionButtonClick(context);
            },
            child: Icon(Icons.add, size: 32),
          ),
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
