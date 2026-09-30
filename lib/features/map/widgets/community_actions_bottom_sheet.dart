import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usp_acessivel/core/services/geocoding_service.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/widgets/main_map.dart';
import 'package:usp_acessivel/features/poi/pages/create_poi_page.dart';
import 'package:usp_acessivel/features/visual_route/pages/create_visual_route_page.dart';

class CommunityActionsBottomSheet extends StatefulWidget {
  const CommunityActionsBottomSheet({
    super.key,
    this.onDismissed,
    this.onCreateReport,
  });

  final void Function()? onDismissed;
  final ValueChanged<WayReportRecord>? onCreateReport;

  @override
  State<CommunityActionsBottomSheet> createState() =>
      _CommunityActionsBottomSheetState();
}

class _CommunityActionsBottomSheetState
    extends State<CommunityActionsBottomSheet> {
  int _step = 0; // 0: select class, 1: select subclass, 2: photo & submit
  String? _selectedClass;
  String? _selectedSubclass;

  // Location state
  double _lat = -23.557456;
  double _lon = -46.727460;
  bool _isLoadingLocation = false;
  bool _locationError = false;
  String? _geocodedAddress;
  bool _isLoadingAddress = false;

  // Image state
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _resolveAddress() async {
    setState(() => _isLoadingAddress = true);
    final address = await GeocodingService.getAddressFromCoordinates(
      _lat,
      _lon,
      fallback: '${_lat.toStringAsFixed(6)}, ${_lon.toStringAsFixed(6)}',
    );
    if (mounted) {
      setState(() {
        _geocodedAddress = address;
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _locationError = true;
          });
          _resolveAddress();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _locationError = true;
            });
            _resolveAddress();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _locationError = true;
          });
          _resolveAddress();
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lon = position.longitude;
          _isLoadingLocation = false;
          _locationError = false;
        });
        _resolveAddress();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = true;
        });
        _resolveAddress();
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adicionar foto ao reporte',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tirar foto com a câmera'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _classTitle(String reportClass) {
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

  String _subclassTitle(String subclass) {
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
        return 'Buraco na via / calçada';
      case 'slippery':
        return 'Superfície escorregadia';
      case 'temporary_barrier':
        return 'Tapume ou barreira';
      case 'open_manhole':
        return 'Bueiro aberto / grade quebrada';
      case 'other':
      default:
        return 'Outro';
    }
  }

  IconData _subclassIcon(String subclass) {
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
      case 'slippery':
        return Icons.water_drop_rounded;
      case 'temporary_barrier':
        return Icons.fence_rounded;
      case 'open_manhole':
        return Icons.dangerous_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _classColor(String reportClass) {
    switch (reportClass) {
      case 'bad_surface':
        return AppColors.warning;
      case 'obstruction':
      case 'hole':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      onDismissed: widget.onDismissed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildCurrentStep(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildStepSelectClass(context);
      case 1:
        return _buildStepSelectSubclass(context);
      case 2:
      default:
        return _buildStepLocationAndPhoto(context);
    }
  }

  // --- STEP 0: SELECT CLASS ---
  Widget _buildStepSelectClass(BuildContext context) {
    return Column(
      key: const ValueKey('step_0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Encontrou um obstáculo?',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: AppColors.primary[700]),
        ),
        const SizedBox(height: 4),
        Text(
          'Escolha a categoria do problema no caminho:',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: AppColors.neutral[600],
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildClassCard(
                title: 'Superfície ruim',
                subtitle: 'Raízes, piso solto',
                icon: Icons.terrain_rounded,
                color: AppColors.warning,
                onTap: () {
                  setState(() {
                    _selectedClass = 'bad_surface';
                    _step = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildClassCard(
                title: 'Obstrução',
                subtitle: 'Árvores, obras',
                icon: Icons.block_rounded,
                color: AppColors.error,
                onTap: () {
                  setState(() {
                    _selectedClass = 'obstruction';
                    _step = 1;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildClassCard(
          title: 'Buraco',
          subtitle: 'Buracos na calçada ou na pista',
          icon: Icons.radio_button_checked_rounded,
          color: AppColors.error,
          horizontal: true,
          onTap: () {
            setState(() {
              _selectedClass = 'hole';
              _step = 1;
            });
          },
        ),
        const SizedBox(height: 20),
        Divider(color: AppColors.neutral[200]),
        const SizedBox(height: 10),
        Text(
          'Outras ações comunitárias:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_road_rounded, size: 18),
                label: const Text('Rota Visual'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateVisualRoutePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.accessibility_new_rounded, size: 18),
                label: const Text('Novo POI'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreatePoiPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildClassCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool horizontal = false,
  }) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.neutral[100],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: horizontal
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 24, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.neutral[500]),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 28, color: color),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // --- STEP 1: SELECT SUBCLASS ---
  Widget _buildStepSelectSubclass(BuildContext context) {
    final subitems = _getSubclassesForClass(_selectedClass ?? 'bad_surface');

    return Column(
      key: const ValueKey('step_1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _step = 0),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _classTitle(_selectedClass ?? ''),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral[900],
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Selecione o tipo específico de problema:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral[600],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...subitems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card.outlined(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.neutral[50],
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _classColor(_selectedClass!).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: _classColor(_selectedClass!),
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral[600],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  setState(() {
                    _selectedSubclass = item.id;
                    _step = 2;
                  });
                  _fetchCurrentLocation();
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  List<({String id, String title, String subtitle, IconData icon})>
      _getSubclassesForClass(String reportClass) {
    switch (reportClass) {
      case 'bad_surface':
        return [
          (
            id: 'tree_roots',
            title: 'Raízes de árvores',
            subtitle: 'Raízes deformando ou quebrando o piso',
            icon: Icons.park_rounded,
          ),
          (
            id: 'broken_sidewalk',
            title: 'Calçada quebrada',
            subtitle: 'Lajotas soltas, rachaduras ou desníveis',
            icon: Icons.warning_rounded,
          ),
          (
            id: 'slippery',
            title: 'Superfície escorregadia',
            subtitle: 'Piso liso, musgo ou poças d\'água',
            icon: Icons.water_drop_rounded,
          ),
          (
            id: 'other',
            title: 'Outro problema de piso',
            subtitle: 'Outra irregularidade na superfície',
            icon: Icons.texture_rounded,
          ),
        ];
      case 'obstruction':
        return [
          (
            id: 'tree_blocking',
            title: 'Árvore atrapalhando o caminho',
            subtitle: 'Galhos baixos ou tronco bloqueando passagem',
            icon: Icons.park_rounded,
          ),
          (
            id: 'construction',
            title: 'Obra na via',
            subtitle: 'Tapumes ou materiais bloqueando o percurso',
            icon: Icons.construction_rounded,
          ),
          (
            id: 'temporary_barrier',
            title: 'Tapume ou barreira',
            subtitle: 'Bloqueio temporário sem passagem alternativa',
            icon: Icons.fence_rounded,
          ),
          (
            id: 'other',
            title: 'Outra obstrução',
            subtitle: 'Outro obstáculo impedindo o tráfego',
            icon: Icons.block_rounded,
          ),
        ];
      case 'hole':
      default:
        return [
          (
            id: 'pothole',
            title: 'Buraco na via / calçada',
            subtitle: 'Fenda ou buraco profundo no caminho',
            icon: Icons.radio_button_checked_rounded,
          ),
          (
            id: 'open_manhole',
            title: 'Bueiro aberto / grelha quebrada',
            subtitle: 'Perigo grave de queda para pedestres e cadeirantes',
            icon: Icons.dangerous_rounded,
          ),
          (
            id: 'other',
            title: 'Outro buraco',
            subtitle: 'Outra abertura perigosa no pavimento',
            icon: Icons.lens_blur_rounded,
          ),
        ];
    }
  }

  // --- STEP 2: LOCATION, PHOTO & SUBMIT ---
  Widget _buildStepLocationAndPhoto(BuildContext context) {
    final subTitle = _subclassTitle(_selectedSubclass ?? '');
    final clsTitle = _classTitle(_selectedClass ?? '');
    final iconData = _subclassIcon(_selectedSubclass ?? '');
    final color = _classColor(_selectedClass ?? '');

    return Column(
      key: const ValueKey('step_2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _step = 1),
            ),
            const SizedBox(width: 4),
            Text(
              'Criar Reporte',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Selected summary card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Categoria: $clsTitle',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Location section
        Text(
          'Localização do reporte:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutral[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.my_location_rounded,
                size: 16,
                color: _locationError ? AppColors.warning : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: (_isLoadingLocation || _isLoadingAddress)
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isLoadingLocation
                                ? 'Obtendo GPS do telefone...'
                                : 'Identificando endereço...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral[600],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _geocodedAddress ??
                            '${_lat.toStringAsFixed(6)}, ${_lon.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral[800],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                tooltip: 'Atualizar localização',
                onPressed: _fetchCurrentLocation,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Photo section
        Text(
          'Foto da ocorrência (opcional):',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral[700],
          ),
        ),
        const SizedBox(height: 6),
        if (_pickedImage == null)
          OutlinedButton.icon(
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Adicionar foto'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _showImageSourceDialog,
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: AppColors.neutral[200],
                  child: Image.file(
                    File(_pickedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                    tooltip: 'Remover foto',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _pickedImage = null),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 18),

        // Submit Button
        FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Confirmar e criar reporte'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            final newReport = (
              id: 'way_rep_${DateTime.now().millisecondsSinceEpoch}',
              lat: _lat,
              lon: _lon,
              reportClass: _selectedClass!,
              subclass: _selectedSubclass!,
              imagePath: _pickedImage?.path,
              address: _geocodedAddress ??
                  '${_lat.toStringAsFixed(6)}, ${_lon.toStringAsFixed(6)}',
            );
            widget.onCreateReport?.call(newReport);
          },
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
