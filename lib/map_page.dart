import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maplibre/maplibre.dart';
import 'building_repository.dart';

import 'app_colors.dart';

import 'app_bottom_sheet.dart';
import 'main_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dynamic_visual_route_page.dart';
import 'create_visual_route_page.dart';
import 'create_poi_page.dart';
import 'dart:convert';

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
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return ListenableBuilder(
                          listenable: textEditingController,
                          builder: (context, child) {
                            final hasText =
                                textEditingController.text.isNotEmpty;
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onSubmitted: (value) => onFieldSubmitted(),
                              decoration: InputDecoration(
                                hintText: 'Buscar edifício',
                                hintStyle: TextStyle(
                                  color: AppColors.neutral[400],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.neutral[400],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  borderSide: BorderSide(
                                    color: AppColors.neutral[200]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  borderSide: BorderSide(
                                    color: AppColors.neutral[200]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                // Dynamically displays clear button only if text length > 0
                                suffixIcon: hasText
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: AppColors.neutral[500],
                                        ),
                                        onPressed: () {
                                          textEditingController.clear();
                                          setState(() {
                                            _selectedBuilding = null;
                                            _buildingVisualRoutes = [];
                                            _buildingPoisList = [];
                                          });
                                        },
                                      )
                                    : null,
                              ),
                            );
                          },
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

class SelectedBuildingBottomSheet extends StatelessWidget {
  const SelectedBuildingBottomSheet({
    super.key,
    required this.selectedBuilding,
    required this.isLoadingBuildingRoutes,
    required this.visualRoutes,
    required this.buildingPoisList,
    required this.onDismissed,
  });

  final String selectedBuilding;
  final bool isLoadingBuildingRoutes;
  final List<dynamic> visualRoutes;
  final List<dynamic> buildingPoisList;
  final VoidCallback onDismissed;

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'elevator':
        return Icons.elevator_outlined;
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

  List<String> _formatDetailsJson(String? detailsJsonStr) {
    if (detailsJsonStr == null || detailsJsonStr.isEmpty) return [];

    List<String> formattedDetails = [];
    final Map<String, dynamic> decoded = jsonDecode(detailsJsonStr);

    for (final entry in decoded.entries) {
      if (entry.key == 'has_grab_bars') {
        formattedDetails.add('Calçada elevada');
      } else {
        formattedDetails.add('${entry.key}: ${entry.value}');
      }
    }
    return formattedDetails;
  }

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Acessibilidade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral[800],
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

                      return ListItem(
                        title: name,
                        subtitle: formattedDetails.join(', '),
                        leading: Icon(
                          _getIconForCategory(category),
                          color: AppColors.primary[500],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Rotas Visuais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (visualRoutes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nenhuma rota encontrada.'),
                  )
                else
                  VisualRoutesList(visualRoutes: visualRoutes),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VisualRoutesList extends StatelessWidget {
  const VisualRoutesList({super.key, required this.visualRoutes});

  final List<dynamic> visualRoutes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visualRoutes.length,
      itemBuilder: (context, index) {
        final route = visualRoutes[index];
        final title = route['title'] ?? 'Sem título';
        final steps = route['steps'] ?? [];

        String lastImageUrl = '';
        if (steps.isNotEmpty) {
          final sortedSteps = List<Map<String, dynamic>>.from(steps)
            ..sort(
              (a, b) =>
                  (a['stepOrder'] as int).compareTo(b['stepOrder'] as int),
            );
          lastImageUrl = sortedSteps.last['imageUrl'] ?? '';
        }

        final storageBaseUrl = dotenv.env['STORAGE_BASE_URL'] ?? '';
        final fullImageUrl = lastImageUrl.isNotEmpty
            ? '$storageBaseUrl/$lastImageUrl'
            : '';

        return ListItem(
          title: title,
          subtitle: '${steps.length} passos',
          leading: fullImageUrl.isNotEmpty
              ? SizedBox(
                  width: double
                      .infinity, // Standard leading width, or use double.infinity if parent constrains it
                  height:
                      double.infinity, // Forces it to fill the vertical space
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(fullImageUrl, fit: BoxFit.cover),
                  ),
                )
              : const Icon(Icons.image_not_supported),
          leadingBackgroundColor: AppColors.neutral[200]!,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DynamicVisualRoutePage(routeData: route),
              ),
            );
          },
        );
      },
    );
  }
}

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Color leadingBackgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.leadingBackgroundColor = AppColors.primary100,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFE2E8F0,
          ).withValues(alpha: 0.8), // #E2E8F0 at 80% opacity
          width: 1.0, // 1px stroke
        ),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip
            .antiAlias, // Clips the Material background cleanly inside the border
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                // Leading widget (optional)
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: leadingBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: leading),
                    ),
                  ),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral[800],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.neutral[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
