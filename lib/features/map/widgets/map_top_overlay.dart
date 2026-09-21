import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/features/map/controllers/map_controller.dart';
import 'package:usp_acessivel/features/map/models/building_model.dart';
import 'package:usp_acessivel/features/map/widgets/map_search_bar.dart';

class MapTopOverlay extends StatelessWidget {
  const MapTopOverlay({
    super.key,
    required this.controller,
  });

  final MapController controller;

  Iterable<Building> _filterBuildings(TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Building>.empty();
    }
    return controller.buildingEntries.where((Building option) {
      return option.name.toLowerCase().contains(
        textEditingValue.text.toLowerCase(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (controller.isDirectionsMode) ...[
              MapSearchBar(
                optionsBuilder: _filterBuildings,
                onSelected: (Building selection) {
                  FocusScope.of(context).unfocus();
                  controller.setStartBuilding(selection);
                },
                onClear: () => controller.setStartBuilding(null),
              ),
              const SizedBox(height: 8),
              MapSearchBar(
                optionsBuilder: _filterBuildings,
                onSelected: (Building selection) {
                  FocusScope.of(context).unfocus();
                  controller.setEndBuilding(selection);
                },
                onClear: () => controller.setEndBuilding(null),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: controller.exitDirectionsMode,
                    icon: const Icon(Icons.close),
                    label: const Text('Sair do Modo Rotas'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              MapSearchBar(
                optionsBuilder: _filterBuildings,
                onSelected: (Building selection) {
                  FocusScope.of(context).unfocus();
                  controller.selectBuildingFromSearch(selection);
                },
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: controller.openAllVisualRoutes,
                    icon: const Icon(Icons.visibility_outlined),
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
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: controller.enterDirectionsMode,
                    icon: const Icon(Icons.directions),
                    label: const Text('Rotas'),
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
          ],
        ),
      ),
    );
  }
}
