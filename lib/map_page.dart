import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'building_repository.dart';

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
  Geographic? _targetCenter;
  List<Building> _buildingEntries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final entries = await BuildingRepository.instance.getBuildingEntries();
    if (mounted) {
      setState(() {
        _buildingEntries = entries;
      });
    }
  }

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
          targetCenter: _targetCenter,
          onSelect: (name) => setState(() {
            _selectedBuilding = name;
          }),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Autocomplete<Building>(
                  displayStringForOption: (Building option) => option.name,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Building>.empty();
                    }
                    return _buildingEntries.where((Building option) {
                      return option.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (Building selection) {
                    // Hide keyboard upon selection
                    FocusScope.of(context).unfocus();

                    setState(() {
                      _selectedBuilding = selection.name;
                      _targetCenter = Geographic(
                        lat: selection.latitude,
                        lon: selection.longitude,
                      );
                    });
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return TextField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Buscar edifício',
                            hintStyle: TextStyle(color: AppColors.neutral[400]),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.neutral[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.neutral[200]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.neutral[200]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        );
                      },
                ),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        print('Button Pressed');
                      },
                      icon: Icon(Icons.visibility_outlined),
                      label: const Text('Rotas visuais'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
