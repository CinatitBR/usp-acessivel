import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'building_accessibilities_list.dart';
import 'building_visual_routes_list.dart';

class SelectedBuildingBottomSheet extends StatelessWidget {
  const SelectedBuildingBottomSheet({
    super.key,
    required this.selectedBuilding,
    required this.isLoadingBuildingRoutes,
    required this.visualRoutes,
    required this.accessibilities,
    required this.onDismissed,
  });

  final String selectedBuilding;
  final bool isLoadingBuildingRoutes;
  final List<dynamic> visualRoutes;
  final List<dynamic> accessibilities;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      onDismissed: onDismissed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedBuilding,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: AppColors.primary[700]),
              ),
              const SizedBox(height: 16),
              if (isLoadingBuildingRoutes)
                CircularProgressIndicator()
              else ...[
                Text(
                  'Acessibilidade',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral[800],
                  ),
                ),
                const SizedBox(height: 4),
                BuildingAccessibilitiesList(accessibilities: accessibilities),
                const SizedBox(height: 16),
                Text(
                  'Rotas Visuais',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral[800],
                  ),
                ),
                const SizedBox(height: 4),
                BuildingVisualRoutesList(visualRoutes: visualRoutes),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
