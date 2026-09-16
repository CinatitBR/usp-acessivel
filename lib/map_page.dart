import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'building_repository.dart';

import 'app_colors.dart';

import 'app_bottom_sheet.dart';
import 'main_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dynamic_visual_route_page.dart';
import 'create_visual_route_page.dart';
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? _selectedBuilding;

  bool _isLoadingBuildingAcessibilities = false;
  List<dynamic> _buildingVisualRoutesList = [];
  List<dynamic> _buildingPoisList = [];
  bool _showAllVisualRoutes = false;
  bool _isLoadingRoutes = false;
  List<dynamic> _visualRoutesList = [];
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

  void _showReportDialog() {
    print('Teste, clicado');
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

  Future<void> _fetchBuildingAcessibilities(String buildingId) async {
    setState(() {
      _isLoadingBuildingAcessibilities = true;
      _buildingVisualRoutesList = [];
      _buildingPoisList = [];
    });

    try {
      final dio = Dio();
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
      final response = await dio.get(
        '$baseUrl/buildings/$buildingId/accessibility',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (mounted && data != null) {
          setState(() {
            _buildingVisualRoutesList = data['visualRoutes'] ?? [];
            _buildingPoisList = data['pois'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching building accessibilities: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBuildingAcessibilities = false;
        });
      }
    }
  }

  Future<void> _fetchAllVisualRoutes() async {
    setState(() {
      _isLoadingRoutes = true;
      _visualRoutesList = [];
    });

    try {
      final dio = Dio();
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
      final response = await dio.get(
        '$baseUrl/visualRoutes',
        queryParameters: {'page': 1},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _visualRoutesList = response.data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching visual routes: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
        });
      }
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
          onReportSelect: _showReportDialog,
          onSelect: (name) {
            final building = _buildingEntries.cast<Building?>().firstWhere(
              (b) => b?.name == name,
              orElse: () => null,
            );
            if (building != null) {
              setState(() {
                _showAllVisualRoutes = false;
                _selectedBuilding = building.name;
              });
              _fetchBuildingAcessibilities(building.id);
            } else {
              setState(() {
                _selectedBuilding = name;

                _buildingVisualRoutesList = [];
                _buildingPoisList = [];
                _isLoadingBuildingAcessibilities = false;
              });
            }
          },
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
                      _showAllVisualRoutes = false;
                      _selectedBuilding = selection.name;

                      _targetCenter = Geographic(
                        lat: selection.latitude,
                        lon: selection.longitude,
                      );
                    });
                    _fetchBuildingAcessibilities(selection.id);
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
                        setState(() {
                          _selectedBuilding = null;
                          _showAllVisualRoutes = true;
                        });
                        _fetchAllVisualRoutes();
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
          SelectedBuildingBottomSheet(
            selectedBuilding: _selectedBuilding!,
            isLoadingBuildingRoutes: _isLoadingBuildingAcessibilities,
            buildingVisualRoutesList: _buildingVisualRoutesList,
            buildingPoisList: _buildingPoisList,
            onDismissed: () => setState(() => _selectedBuilding = null),
          ),
        if (_showAllVisualRoutes)
          AppBottomSheet(
            onDismissed: () => setState(() => _showAllVisualRoutes = false),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  Text(
                    'Rotas Visuais',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary[600],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingRoutes)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (_visualRoutesList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Nenhuma rota visual encontrada.'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _visualRoutesList.length,
                      itemBuilder: (context, index) {
                        final route = _visualRoutesList[index];
                        final title = route['title'] ?? 'Sem título';
                        final steps = route['steps'] ?? [];

                        String lastImageUrl = '';
                        if (steps.isNotEmpty) {
                          // Find step with max stepOrder
                          final sortedSteps =
                              List<Map<String, dynamic>>.from(steps)..sort(
                                (a, b) => (a['stepOrder'] as int).compareTo(
                                  b['stepOrder'] as int,
                                ),
                              );
                          lastImageUrl = sortedSteps.last['imageUrl'] ?? '';
                        }

                        final storageBaseUrl =
                            dotenv.env['STORAGE_BASE_URL'] ?? '';
                        final fullImageUrl = lastImageUrl.isNotEmpty
                            ? '$storageBaseUrl/$lastImageUrl'
                            : '';

                        return ListTile(
                          leading: fullImageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    fullImageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DynamicVisualRoutePage(routeData: route),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SelectedBuildingBottomSheet extends StatelessWidget {
  const SelectedBuildingBottomSheet({
    super.key,
    required this.selectedBuilding,
    required this.isLoadingBuildingRoutes,
    required this.buildingVisualRoutesList,
    required this.buildingPoisList,
    required this.onDismissed,
  });

  final String selectedBuilding;
  final bool isLoadingBuildingRoutes;
  final List<dynamic> buildingVisualRoutesList;
  final List<dynamic> buildingPoisList;
  final VoidCallback onDismissed;

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'elevator':
        return Icons.elevator;
      case 'bathroom':
        return Icons.wc;
      case 'ramp':
        return Icons.accessible;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.place;
    }
  }

  String _formatDetailsJson(String? detailsJsonStr) {
    if (detailsJsonStr == null || detailsJsonStr.isEmpty) return '';
    try {
      final Map<String, dynamic> decoded = jsonDecode(detailsJsonStr);
      return decoded.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    } catch (e) {
      return detailsJsonStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      onDismissed: onDismissed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
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
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Acessibilidade',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (buildingPoisList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhum ponto de acessibilidade encontrado.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: buildingPoisList.length,
                  itemBuilder: (context, index) {
                    final poi = buildingPoisList[index];
                    final name = poi['name'] ?? 'Sem nome';
                    final category = poi['category'];
                    final detailsJson = poi['detailsJson'];
                    final formattedDetails = _formatDetailsJson(detailsJson);

                    return ListTile(
                      leading: Icon(_getIconForCategory(category)),
                      title: Text(name),
                      subtitle: formattedDetails.isNotEmpty
                          ? Text(formattedDetails)
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Rotas Visuais',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (buildingVisualRoutesList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhuma rota encontrada.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: buildingVisualRoutesList.length,
                  itemBuilder: (context, index) {
                  final route = buildingVisualRoutesList[index];
                  final title = route['title'] ?? 'Sem título';
                  final steps = route['steps'] ?? [];

                  String lastImageUrl = '';
                  if (steps.isNotEmpty) {
                    final sortedSteps = List<Map<String, dynamic>>.from(steps)
                      ..sort(
                        (a, b) => (a['stepOrder'] as int).compareTo(
                          b['stepOrder'] as int,
                        ),
                      );
                    lastImageUrl = sortedSteps.last['imageUrl'] ?? '';
                  }

                  final storageBaseUrl = dotenv.env['STORAGE_BASE_URL'] ?? '';
                  final fullImageUrl = lastImageUrl.isNotEmpty
                      ? '$storageBaseUrl/$lastImageUrl'
                      : '';

                  return ListTile(
                    leading: fullImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              fullImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DynamicVisualRoutePage(routeData: route),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
