import 'dart:io';
import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
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

const List<WayReportRecord> _mockWayReports = [
  (
    id: 'way_rep_1',
    lat: -23.558332,
    lon: -46.732016,
    reportClass: 'obstruction',
    subclass: 'tree_blocking',
    imagePath: 'assets/reports/way_rep_1.jpg',
    address: 'Travessa C, Butantã',
  ),
  (
    id: 'way_rep_2',
    lat: -23.560957,
    lon: -46.726564,
    reportClass: 'bad_surface',
    subclass: 'tree_roots',
    imagePath: 'assets/reports/way_rep_2.jpg',
    address: 'Rua do Lago, Butantã',
  ),
  (
    id: 'way_rep_3',
    lat: -23.551997,
    lon: -46.730766,
    reportClass: 'bad_surface',
    subclass: 'broken_sidewalk',
    imagePath: 'assets/reports/way_rep_3.jpg',
    address: 'Rua do Matão, Butantã',
  ),
  (
    id: 'way_rep_4',
    lat: -23.551943,
    lon: -46.730828,
    reportClass: 'obstruction',
    subclass: 'construction',
    imagePath: null,
    address: 'Rua do Matão (FAU), Butantã',
  ),
  (
    id: 'way_rep_5',
    lat: -23.559867,
    lon: -46.732219,
    reportClass: 'hole',
    subclass: 'pothole',
    imagePath: null,
    address: 'Travessa C / Rua do Matão',
  ),
];

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _controller;
  late List<WayReportRecord> _wayReports;
  WayReportRecord? _selectedWayReport;

  @override
  void initState() {
    super.initState();
    _wayReports = List.from(_mockWayReports);
    _controller = MapController();
    _controller.loadData();
  }

  void _handleCreateWayReport(WayReportRecord report) {
    setState(() {
      _wayReports.add(report);
      _selectedWayReport = report;
    });
    _controller.dismissActionsSheet();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte adicionado no mapa!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              wayReports: _wayReports,
              onWayReportSelect: (report) {
                _controller.dismissSelectedMapReport();
                setState(() => _selectedWayReport = report);
              },
              onRouteAccessibilityPointSelect:
                  _controller.selectRouteAccessibilityPoint,
              onReportSelectWithId: (id) {
                setState(() => _selectedWayReport = null);
                _controller.selectMapReport(id);
              },
              onSelect: (buildingName) {
                setState(() => _selectedWayReport = null);
                _controller.selectBuilding(buildingName);
              },
              onBusStopSelect: (stop) {
                setState(() => _selectedWayReport = null);
                _controller.selectBusStop(stop);
              },
              styleUrl: _controller.currentMapStyle.url,
            ),
            if (_controller.selectedMapReport == null &&
                _selectedWayReport == null)
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
            if (_selectedWayReport != null) ...[
              // Backdrop to dismiss banner when tapping outside
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedWayReport = null),
                ),
              ),
              _WayReportBanner(
                report: _selectedWayReport!,
                onDismissed: () => setState(() => _selectedWayReport = null),
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
                onCreateReport: _handleCreateWayReport,
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

// --- WAY REPORT BANNER & HELPERS ---

String _getWayReportTitle(String subclass) {
  switch (subclass) {
    case 'tree_blocking':
      return 'Árvore atrapalhando o caminho';
    case 'tree_roots':
      return 'Raízes de árvores';
    case 'broken_sidewalk':
      return 'Calçada quebrada';
    case 'construction':
      return 'Obra na via';
    case 'pothole':
      return 'Buraco na via';
    default:
      return 'Problema no caminho';
  }
}

String _getWayReportClassLabel(String reportClass) {
  switch (reportClass) {
    case 'bad_surface':
      return 'Superfície ruim';
    case 'obstruction':
      return 'Obstrução';
    case 'hole':
      return 'Buraco';
    default:
      return 'Reporte de caminho';
  }
}

IconData _getWayReportIcon(String subclass) {
  switch (subclass) {
    case 'tree_blocking':
      return Icons.park_rounded;
    case 'tree_roots':
      return Icons.terrain_rounded;
    case 'broken_sidewalk':
      return Icons.warning_rounded;
    case 'construction':
      return Icons.construction_rounded;
    case 'pothole':
      return Icons.radio_button_checked_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

Color _getWayReportColor(String reportClass, String subclass) {
  if (subclass == 'construction' || reportClass == 'hole') {
    return AppColors.error;
  }
  return AppColors.warning;
}

class _WayReportBanner extends StatelessWidget {
  const _WayReportBanner({
    required this.report,
    required this.onDismissed,
  });

  final WayReportRecord report;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final title = _getWayReportTitle(report.subclass);
    final categoryLabel = _getWayReportClassLabel(report.reportClass);
    final iconData = _getWayReportIcon(report.subclass);
    final color = _getWayReportColor(report.reportClass, report.subclass);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        // Prevent taps inside the banner from triggering outside dismissal
        onTap: () {},
        child: Material(
          elevation: 6,
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.neutral[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            color: color,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral[900],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Reporte de caminho • $categoryLabel',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onDismissed,
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.neutral[600],
                        tooltip: 'Fechar',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  if (report.imagePath != null &&
                      report.imagePath!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        color: AppColors.neutral[200],
                        child: report.imagePath!.startsWith('assets/')
                            ? Image.asset(
                                report.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors.neutral[500],
                                    size: 32,
                                  ),
                                ),
                              )
                            : Image.file(
                                File(report.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors.neutral[500],
                                    size: 32,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neutral[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.neutral[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            report.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral[800],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
