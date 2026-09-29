import 'package:flutter/material.dart';
import 'package:usp_acessivel/features/map/controllers/map_controller.dart';
import 'package:usp_acessivel/features/map/widgets/bus_stop_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/widgets/community_actions_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/widgets/main_map.dart';
import 'package:usp_acessivel/features/map/widgets/map_community_action_button.dart';
import 'package:usp_acessivel/features/map/widgets/map_report_banner.dart';
import 'package:usp_acessivel/features/map/widgets/map_style_button.dart';
import 'package:usp_acessivel/features/map/widgets/map_top_overlay.dart';
import 'package:usp_acessivel/features/map/widgets/route_accessibility_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/widgets/route_accessibility_toggle_button.dart';
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
              routeAccessibilityPoints: _controller.routeAccessibilityPoints,
              mapReports: _controller.mapReports,
              onRouteAccessibilityPointSelect:
                  _controller.selectRouteAccessibilityPoint,
              onReportSelectWithId: _controller.selectMapReport,
              onSelect: _controller.selectBuilding,
              onBusStopSelect: _controller.selectBusStop,
              styleUrl: _controller.currentMapStyle.url,
            ),
            if (_controller.selectedMapReport == null)
              MapTopOverlay(controller: _controller),
            MapStyleButton(
              currentStyle: _controller.currentMapStyle,
              onStyleSelected: _controller.setMapStyle,
              bottom: 104,
            ),
            if (_controller.selectedMapReport != null) ...[
              // Backdrop to dismiss banner when tapping outside
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _controller.dismissSelectedMapReport,
                ),
              ),
              MapReportBanner(
                report: _controller.selectedMapReport!,
                onDismissed: _controller.dismissSelectedMapReport,
              ),
            ],
            if (_controller.isDirectionsMode == false)
              MapCommunityActionButton(onPressed: _controller.openActionsSheet),
            if (_controller.selectedBusStop != null)
              BusStopBottomSheet(
                busStop: _controller.selectedBusStop!,
                onDismissed: _controller.dismissSelectedBusStop,
              ),
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
            if (_controller.showActionsSheet)
              CommunityActionsBottomSheet(
                onDismissed: _controller.dismissActionsSheet,
              ),
            if (_controller.isDirectionsMode &&
                _controller.routeAccessibilityPoints.isNotEmpty &&
                _controller.showRouteAccessibilitySheet)
              RouteAccessibilityBottomSheet(
                points: _controller.routeAccessibilityPoints,
                selectedPointId: _controller.selectedRouteAccessibilityPointId,
                onPointSelected: _controller.selectRouteAccessibilityPoint,
                onDismissed: _controller.dismissRouteAccessibilitySheet,
              ),
            if (_controller.isDirectionsMode &&
                _controller.routeAccessibilityPoints.isNotEmpty &&
                !_controller.showRouteAccessibilitySheet)
              RouteAccessibilityToggleButton(
                pointCount: _controller.routeAccessibilityPoints.length,
                onPressed: _controller.openRouteAccessibilitySheet,
              ),
          ],
        );
      },
    );
  }
}
