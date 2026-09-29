import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre/maplibre.dart';
import 'package:usp_acessivel/features/map/models/building_model.dart';
import 'package:usp_acessivel/features/map/models/map_report_model.dart';
import 'package:usp_acessivel/features/map/models/map_style.dart';
import 'package:usp_acessivel/features/map/models/route_accessibility_point.dart';
import 'package:usp_acessivel/features/map/repositories/building_repository.dart';
import 'package:usp_acessivel/features/map/services/building_service.dart';
import 'package:usp_acessivel/features/map/services/directions_service.dart';
import 'package:usp_acessivel/features/map/services/map_report_service.dart';
import 'package:usp_acessivel/features/visual_route/services/visual_route_service.dart';

class MapController extends ChangeNotifier {
  final BuildingRepository _buildingRepository;
  final BuildingService _buildingService;
  final DirectionsService _directionsService;
  final VisualRouteService _visualRouteService;
  final MapReportService _mapReportService;

  MapController({
    BuildingRepository? buildingRepository,
    BuildingService? buildingService,
    DirectionsService? directionsService,
    VisualRouteService? visualRouteService,
    MapReportService? mapReportService,
  }) : _buildingRepository = buildingRepository ?? BuildingRepository.instance,
       _buildingService = buildingService ?? BuildingService(),
       _directionsService = directionsService ?? DirectionsService(),
       _visualRouteService = visualRouteService ?? VisualRouteService(),
       _mapReportService = mapReportService ?? MapReportService();

  // Map style (Basemap)
  AppMapStyle currentMapStyle = AppMapStyle.liberty;

  // Map Reports data & selection
  List<MapReport> mapReports = [];
  MapReport? selectedMapReport;
  bool isLoadingMapReports = false;

  // Buildings data & selection
  List<Building> buildingEntries = [];
  String? selectedBuilding;
  Geographic? targetCenter;

  // Bus stop selection
  Map<String, dynamic>? selectedBusStop;

  // Building accessibility data
  bool isLoadingBuildingAccessibilities = false;
  List<dynamic> buildingVisualRoutes = [];
  List<dynamic> buildingPoisList = [];

  // Visual routes sheet
  bool showAllVisualRoutes = false;
  bool isLoadingRoutes = false;
  List<dynamic> allVisualRoutes = [];

  // Directions
  bool isDirectionsMode = false;
  Building? startBuilding;
  Building? endBuilding;
  Map<String, dynamic>? routeGeoJson;
  LngLatBounds? routeBoundingBox;

  // Route Accessibility
  List<RouteAccessibilityPoint> routeAccessibilityPoints = [];
  String? selectedRouteAccessibilityPointId;
  bool showRouteAccessibilitySheet = false;

  // Actions
  bool showActionsSheet = false;

  /// Sets the active basemap style
  void setMapStyle(AppMapStyle style) {
    if (currentMapStyle == style) return;
    currentMapStyle = style;
    notifyListeners();
  }

  /// Loads the initial list of buildings and map reports
  Future<void> loadData() async {
    buildingEntries = await _buildingRepository.getBuildingEntries();
    await fetchMapReports();
    notifyListeners();
  }

  /// Loads reports from backend for the campus bounding box
  Future<void> fetchMapReports() async {
    isLoadingMapReports = true;
    notifyListeners();

    try {
      mapReports = await _mapReportService.getMapReports(
        minLat: -23.572641,
        maxLat: -23.549471,
        minLon: -46.745496,
        maxLon: -46.710219,
      );
    } catch (e) {
      debugPrint('Error loading map reports: $e');
    } finally {
      isLoadingMapReports = false;
      notifyListeners();
    }
  }

  /// Select a report by ID to show its details in the top banner
  void selectMapReport(String? reportId) {
    if (reportId == null) {
      dismissSelectedMapReport();
      return;
    }
    // Close other sheets
    selectedBuilding = null;
    selectedBusStop = null;
    showAllVisualRoutes = false;
    showActionsSheet = false;

    selectedMapReport = mapReports.firstWhereOrNull((r) => r.id == reportId);
    if (selectedMapReport != null) {
      targetCenter = Geographic(
        lat: selectedMapReport!.lat,
        lon: selectedMapReport!.lon,
      );
    }
    notifyListeners();
  }

  void dismissSelectedMapReport() {
    selectedMapReport = null;
    notifyListeners();
  }

  /// Handles selecting a building by name (e.g. from map tap)
  void selectBuilding(String? name) {
    selectedBusStop = null;
    selectedMapReport = null;
    final building = buildingEntries.cast<Building?>().firstWhere(
      (b) => b?.name == name,
      orElse: () => null,
    );

    if (building != null) {
      // Close other sheets, if any of them are open
      showAllVisualRoutes = false;
      showActionsSheet = false;

      selectedBuilding = building.name;
      notifyListeners();
      fetchBuildingAccessibilities(building.id);
    } else {
      selectedBuilding = name;
      buildingVisualRoutes = [];
      buildingPoisList = [];
      isLoadingBuildingAccessibilities = false;
      notifyListeners();
    }
  }

  /// Handles selecting a building from search bar suggestions
  void selectBuildingFromSearch(Building selection) {
    selectedBusStop = null;
    selectedMapReport = null;
    showAllVisualRoutes = false;
    selectedBuilding = selection.name;
    targetCenter = Geographic(
      lat: selection.latitude,
      lon: selection.longitude,
    );
    notifyListeners();
    fetchBuildingAccessibilities(selection.id);
  }

  void dismissSelectedBuilding() {
    selectedBuilding = null;
    notifyListeners();
  }

  void selectBusStop(Map<String, dynamic> busStop) {
    selectedBuilding = null;
    selectedMapReport = null;
    showAllVisualRoutes = false;
    showActionsSheet = false;
    selectedBusStop = busStop;
    notifyListeners();
  }

  void dismissSelectedBusStop() {
    selectedBusStop = null;
    notifyListeners();
  }

  Future<void> fetchBuildingAccessibilities(String buildingId) async {
    isLoadingBuildingAccessibilities = true;
    buildingVisualRoutes = [];
    buildingPoisList = [];
    notifyListeners();

    try {
      final data = await _buildingService.getBuildingAccessibility(buildingId);
      if (data != null) {
        buildingVisualRoutes = data['visualRoutes'] ?? [];
        buildingPoisList = data['pois'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching building accessibilities: $e');
    } finally {
      isLoadingBuildingAccessibilities = false;
      notifyListeners();
    }
  }

  void openAllVisualRoutes() {
    selectedBuilding = null;
    selectedBusStop = null;
    selectedMapReport = null;
    showAllVisualRoutes = true;
    notifyListeners();
    fetchAllVisualRoutes();
  }

  void dismissAllVisualRoutes() {
    showAllVisualRoutes = false;
    notifyListeners();
  }

  Future<void> fetchAllVisualRoutes() async {
    isLoadingRoutes = true;
    allVisualRoutes = [];
    notifyListeners();

    try {
      allVisualRoutes = await _visualRouteService.getVisualRoutes(page: 1);
    } catch (e) {
      debugPrint('Error fetching visual routes: $e');
    } finally {
      isLoadingRoutes = false;
      notifyListeners();
    }
  }

  void enterDirectionsMode() {
    isDirectionsMode = true;
    selectedBuilding = null;
    selectedBusStop = null;
    selectedMapReport = null;
    notifyListeners();
  }

  void exitDirectionsMode() {
    isDirectionsMode = false;
    startBuilding = null;
    endBuilding = null;
    clearDirections();
    _updateRouteAccessibility();
  }

  void setStartBuilding(Building? building) {
    startBuilding = building;
    if (building == null) {
      clearDirections();
    } else {
      fetchDirections();
    }
    _updateRouteAccessibility();
    notifyListeners();
  }

  void setEndBuilding(Building? building) {
    endBuilding = building;
    if (building == null) {
      clearDirections();
    } else {
      fetchDirections();
    }
    _updateRouteAccessibility();
    notifyListeners();
  }

  void _updateRouteAccessibility() {
    if (isDirectionsMode &&
        startBuilding?.id == 'ime' &&
        endBuilding?.id == 'poli') {
      routeAccessibilityPoints = RouteAccessibilityPoint.mockImeToPoliPoints;
      showRouteAccessibilitySheet = true;
    } else {
      routeAccessibilityPoints = [];
      selectedRouteAccessibilityPointId = null;
      showRouteAccessibilitySheet = false;
    }
  }

  void selectRouteAccessibilityPoint(String? id) {
    selectedRouteAccessibilityPointId = id;
    if (id != null) {
      final point = routeAccessibilityPoints.where((p) => p.id == id).firstOrNull;
      if (point != null) {
        targetCenter = Geographic(
          lat: point.latitude,
          lon: point.longitude,
        );
      }
      showRouteAccessibilitySheet = true;
    }
    notifyListeners();
  }

  void openRouteAccessibilitySheet() {
    showRouteAccessibilitySheet = true;
    notifyListeners();
  }

  void dismissRouteAccessibilitySheet() {
    showRouteAccessibilitySheet = false;
    notifyListeners();
  }

  Future<void> fetchDirections() async {
    if (startBuilding == null || endBuilding == null) return;

    try {
      final result = await _directionsService.directions(
        'wheelchair',
        startBuilding!.longitude,
        startBuilding!.latitude,
        endBuilding!.longitude,
        endBuilding!.latitude,
      );

      routeGeoJson = result as Map<String, dynamic>?;
      if (result != null && result['bbox'] != null) {
        final bbox = result['bbox'];
        routeBoundingBox = LngLatBounds(
          longitudeWest: (bbox[0] as num).toDouble(),
          latitudeSouth: (bbox[1] as num).toDouble(),
          longitudeEast: (bbox[2] as num).toDouble(),
          latitudeNorth: (bbox[3] as num).toDouble(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching directions: $e');
    }
  }

  void clearDirections() {
    routeGeoJson = null;
    routeBoundingBox = null;
    _updateRouteAccessibility();
    notifyListeners();
  }

  void openActionsSheet() {
    // Close other sheets, if any of them are open
    selectedBuilding = null;
    selectedBusStop = null;
    selectedMapReport = null;
    showAllVisualRoutes = false;

    showActionsSheet = true;
    notifyListeners();
  }

  void dismissActionsSheet() {
    showActionsSheet = false;
    notifyListeners();
  }
}
