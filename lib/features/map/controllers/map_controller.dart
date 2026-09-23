import 'package:flutter/foundation.dart';
import 'package:maplibre/maplibre.dart';
import 'package:usp_acessivel/features/map/models/building_model.dart';
import 'package:usp_acessivel/features/map/models/route_accessibility_point.dart';
import 'package:usp_acessivel/features/map/repositories/building_repository.dart';
import 'package:usp_acessivel/features/map/services/building_service.dart';
import 'package:usp_acessivel/features/map/services/directions_service.dart';
import 'package:usp_acessivel/features/visual_route/services/visual_route_service.dart';

class MapController extends ChangeNotifier {
  final BuildingRepository _buildingRepository;
  final BuildingService _buildingService;
  final DirectionsService _directionsService;
  final VisualRouteService _visualRouteService;

  MapController({
    BuildingRepository? buildingRepository,
    BuildingService? buildingService,
    DirectionsService? directionsService,
    VisualRouteService? visualRouteService,
  }) : _buildingRepository = buildingRepository ?? BuildingRepository.instance,
       _buildingService = buildingService ?? BuildingService(),
       _directionsService = directionsService ?? DirectionsService(),
       _visualRouteService = visualRouteService ?? VisualRouteService();

  // Buildings data & selection
  List<Building> buildingEntries = [];
  String? selectedBuilding;
  Geographic? targetCenter;

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

  /// Loads the initial list of buildings from repository
  Future<void> loadData() async {
    buildingEntries = await _buildingRepository.getBuildingEntries();
    notifyListeners();
  }

  /// Handles selecting a building by name (e.g. from map tap)
  void selectBuilding(String? name) {
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
    showAllVisualRoutes = false;

    showActionsSheet = true;
    notifyListeners();
  }

  void dismissActionsSheet() {
    showActionsSheet = false;
    notifyListeners();
  }
}
