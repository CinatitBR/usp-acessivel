import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maplibre/maplibre.dart';
import 'package:usp_acessivel/features/map/models/building_model.dart';
import 'package:usp_acessivel/features/map/repositories/building_repository.dart';
import 'package:usp_acessivel/features/map/services/directions_service.dart';

import 'package:usp_acessivel/core/theme/app_colors.dart';

import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/widgets/main_map.dart';
import 'package:usp_acessivel/features/map/widgets/map_search_bar.dart';
import 'package:usp_acessivel/features/map/widgets/selected_building_bottom_sheet.dart';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:usp_acessivel/features/visual_route/pages/dynamic_visual_route_page.dart';
import 'package:usp_acessivel/features/visual_route/pages/create_visual_route_page.dart';
import 'package:usp_acessivel/features/poi/pages/create_poi_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? _selectedBuilding;

  bool _isLoadingBuildingAcessibilities = false;
  List<dynamic> _buildingVisualRoutes = [];
  List<dynamic> _buildingPoisList = [];
  bool _showAllVisualRoutes = false;
  bool _isLoadingRoutes = false;
  List<dynamic> _allVisualRoutes = [];
  Geographic? _targetCenter;
  List<Building> _buildingEntries = [];

  FeatureCollection? directions;

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
      _buildingVisualRoutes = [];
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
            _buildingVisualRoutes = data['visualRoutes'] ?? [];
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
      _allVisualRoutes = [];
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
            _allVisualRoutes = response.data['data'] ?? [];
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

  void _fetchDirections() async {
    try {
      final directionsService = DirectionsService();
      final result = await directionsService.directions(
        'wheelchair',
        -46.7317,
        -23.55921,
        -46.72733,
        -23.55764,
      );

      setState(() => directions = result);
    } catch (e) {
      print(e);
    }
  }

  void _handleActionButtonClick(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Criar rota visual'),
                    subtitle: Text('Envie uma rota visual'),
                    // leading: Icon(Icons.route_rounded),
                    trailing: Icon(Icons.chevron_right_sharp),
                    splashColor: AppColors.neutral[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateVisualRoutePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Criar Ponto de Acessibilidade'),
                    subtitle: Text('Cadastre um novo ponto'),
                    trailing: Icon(Icons.chevron_right_sharp),
                    splashColor: AppColors.neutral[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreatePoiPage(),
                        ),
                      );
                    },
                  ),
                ],
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

                _buildingVisualRoutes = [];
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
                MapSearchBar(
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
          child: IconButton(
            icon: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // 👈 Shadow color with transparency
                    blurRadius: 4.0, // 👈 Softens the shadow
                    offset: Offset(0, 4), // 👈 Moves shadow downwards (X, Y)
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/community-report.svg',
                width: 60,
              ),
            ),
            onPressed: () {
              _handleActionButtonClick(context);
            },
          ),
        ),
        if (_selectedBuilding != null)
          SelectedBuildingBottomSheet(
            selectedBuilding: _selectedBuilding!,
            isLoadingBuildingRoutes: _isLoadingBuildingAcessibilities,
            visualRoutes: _buildingVisualRoutes,
            accessibilities: _buildingPoisList,
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
                  else if (_allVisualRoutes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Nenhuma rota visual encontrada.'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _allVisualRoutes.length,
                      itemBuilder: (context, index) {
                        final route = _allVisualRoutes[index];
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
