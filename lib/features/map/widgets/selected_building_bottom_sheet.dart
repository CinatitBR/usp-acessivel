import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'list_header.dart';
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Text(
                selectedBuilding,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primary[600],
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (isLoadingBuildingRoutes)
                CircularProgressIndicator()
              else ...[
                const ListHeader(title: 'Acessibilidade'),
                BuildingAccessibilitiesList(accessibilities: accessibilities),
                const SizedBox(height: 16),
                ListHeader(title: 'Rotas Visuais'),
                BuildingVisualRoutesList(visualRoutes: visualRoutes),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
