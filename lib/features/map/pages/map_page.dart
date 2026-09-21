import 'package:flutter/material.dart';
import 'package:usp_acessivel/features/map/controllers/map_controller.dart';
import 'package:usp_acessivel/features/map/widgets/main_map.dart';
import 'package:usp_acessivel/features/map/widgets/map_community_action_button.dart';
import 'package:usp_acessivel/features/map/widgets/map_top_overlay.dart';
import 'package:usp_acessivel/features/map/widgets/selected_building_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/widgets/visual_routes_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Escadaria da química',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: Text(
            '⚠️ A escadaria que leva até o bandejão da química é longa e íngrime, '
            'com degraus estreitos e corrimão defeituoso. ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            MainMap(
              targetCenter: _controller.targetCenter,
              routeGeoJson: _controller.routeGeoJson,
              routeBounds: _controller.routeBoundingBox,
              onReportSelect: _showReportDialog,
              onSelect: _controller.selectBuilding,
            ),
            MapTopOverlay(controller: _controller),
            const MapCommunityActionButton(),
            if (_controller.selectedBuilding != null)
              SelectedBuildingBottomSheet(
                selectedBuilding: _controller.selectedBuilding!,
                isLoadingBuildingRoutes:
                    _controller.isLoadingBuildingAccessibilities,
                visualRoutes: _controller.buildingVisualRoutes,
                accessibilities: _controller.buildingPoisList,
                onDismissed: _controller.dismissSelectedBuilding,
              ),
            if (_controller.showAllVisualRoutes)
              VisualRoutesBottomSheet(
                isLoading: _controller.isLoadingRoutes,
                routes: _controller.allVisualRoutes,
                onDismissed: _controller.dismissAllVisualRoutes,
              ),
          ],
        );
      },
    );
  }
}
