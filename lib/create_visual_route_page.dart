import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'building_repository.dart';

class RouteStep {
  final String id; // Changed from 'int order' to a unique string ID
  // final int order;
  final XFile image;
  final TextEditingController descriptionController;

  RouteStep({
    required this.id,
    required this.image,
    required this.descriptionController,
  });
}

class CreateVisualRoutePage extends StatefulWidget {
  const CreateVisualRoutePage({super.key});

  @override
  State<CreateVisualRoutePage> createState() => _CreateVisualRoutePageState();
}

class _CreateVisualRoutePageState extends State<CreateVisualRoutePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedBuildingId;
  List<DropdownMenuEntry<String>> _buildingEntries = [];
  final List<RouteStep> _steps = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    for (var step in _steps) {
      step.descriptionController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    // 1. Instant check if already loaded
    if (BuildingRepository.instance.cachedEntries.isNotEmpty) {
      setState(() {
        _buildingEntries = BuildingRepository.instance.cachedEntries;
      });
      return;
    }

    // 2. Fallback to async retrieval if not yet loaded
    final entries = await BuildingRepository.instance.getBuildingEntries();
    if (mounted) {
      setState(() {
        _buildingEntries = entries;
      });
    }
  }

  void _reorderStep(int oldIndex, int newIndex) {
    setState(() {
      // The new API handles index math automatically! Just remove and insert.
      final RouteStep item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            Text(
              "Criar Rota Visual",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.primary[700]),
            ),
            Icon(Icons.help_outline, color: AppColors.primary[700]),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              Text(
                'Crie uma rota com fotos e instruções para orientar o usuário pelo espaço.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral[600],
                  fontSize: 16,
                ),
              ),
              Text(
                'Informações Gerais',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Color(0xFF1A1C1C)),
              ),
              Text(
                'Título da rota',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Color(0xFF444654)),
              ),
              _buildTextField(
                context,
                hint: 'Ex: Entrada acessível para cadeirantes',
                controller: _titleController,
              ),
              _buildFieldTitle(context, 'Edifício ou instituto'),
              DropdownMenu(
                expandedInsets: EdgeInsets.zero,
                controller: _locationController,
                label: const Text('Selecione o local'),
                initialSelection: _selectedBuildingId,
                onSelected: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedBuildingId = value;
                    });
                  }
                },
                textStyle: const TextStyle(color: Color(0xFF1A1C1C)),
                dropdownMenuEntries: _buildingEntries,
                menuHeight: 340,

                // Enables real-time typing and filtering of the entries
                enableFilter: true,
                enableSearch: true,
                requestFocusOnTap:
                    true, // Opens keyboard immediately when tapped
                // Custom search callback to ignore case and match partial text / acronyms
                filterCallback:
                    (List<DropdownMenuEntry<String>> entries, String filter) {
                      final trimmedFilter = filter.trim().toLowerCase();
                      if (trimmedFilter.isEmpty) {
                        return entries;
                      }

                      return entries.where((entry) {
                        final labelMatches = entry.label.toLowerCase().contains(
                          trimmedFilter,
                        );
                        final valueMatches = entry.value.toLowerCase().contains(
                          trimmedFilter,
                        );
                        return labelMatches || valueMatches;
                      }).toList();
                    },

                menuStyle: MenuStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  elevation: const WidgetStatePropertyAll(4),
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppColors.neutral[100],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neutral[200]!),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.neutral[700]!,
                      width: 2.0,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                ),
              ),
              _buildFieldTitle(context, 'Sobre esta rota'),
              _buildTextField(
                context,
                hint: 'Descreva brevemente o percurso...',
                controller: _descriptionController,
              ),
              Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
              FilledButton(
                onPressed: _isLoading ? null : _pickImagesAndAddStep,
                style: FilledButton.styleFrom(minimumSize: Size(200, 48)),
                child: Row(
                  mainAxisAlignment: .center,
                  spacing: 16,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else ...[
                      Icon(Icons.add_a_photo),
                      const Text('Adicionar fotos'),
                    ],
                  ],
                ),
              ),
              Column(
                children: List.generate(_steps.length, (index) {
                  final step = _steps[index];
                  return _buildStepBox(
                    context,
                    key: ValueKey(step.id),
                    step: step,
                    stepIndex: index,
                  );
                }),
              ),

              FilledButton(
                onPressed: _onCancel,
                style: FilledButton.styleFrom(
                  fixedSize: Size(180, 48),
                  backgroundColor: AppColors.neutral[200],
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.neutral[700]),
                ),
              ),
              FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(fixedSize: Size(180, 48)),
                child: const Text('Salvar rota'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: Color(0xFF444654)),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    String? hint,
    int? maxLines,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.neutral[100],
        hintText: hint,
        hintStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.neutral),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neutral[200]!),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        // Style when the user taps inside the text field
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.neutral[700]!,
            width: 2.0,
          ), // Added width for better visibility
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }

  Future<void> _pickImagesAndAddStep() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    // Validate extensions
    final validExtensions = ['.png', '.jpg', '.jpeg', '.heic', '.heif'];
    bool hasInvalid = false;
    for (var image in images) {
      final ext = p.extension(image.path).toLowerCase();
      if (!validExtensions.contains(ext)) {
        hasInvalid = true;
        break;
      }
    }

    if (hasInvalid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Um ou mais arquivos não são válidos.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final List<RouteStep> newSteps = [];

      for (var image in images) {
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final targetPath = p.join(tempDir.path, 'converted_$timestamp.webp');

        final XFile? convertedImage =
            await FlutterImageCompress.compressAndGetFile(
              image.path,
              targetPath,
              quality: 80,
              minWidth: 700,
              format: CompressFormat.webp,
            );

        newSteps.add(
          RouteStep(
            id: timestamp.toString(),
            image: convertedImage ?? image,
            descriptionController: TextEditingController(),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _steps.addAll(newSteps); // Single rebuild for all added images
        });
      }
    }
    // Fallback just in case conversion fails, but it shouldn't
    // catch () {}
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeStep(int index) {
    setState(() {
      _steps[index].descriptionController.dispose();
      _steps.removeAt(index);
    });
  }

  void _onCancel() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _locationController.text = '';
      _selectedBuildingId = null;
      for (var step in _steps) {
        step.descriptionController.dispose();
      }
      _steps.clear();
    });
  }

  void _onSave() {
    final Map<String, dynamic> routeData = {
      'title': _titleController.text,
      'buildingId': _selectedBuildingId,
      'description': _descriptionController.text,
      'stepsMeta': _steps.asMap().entries.map((entry) {
        final int index = entry.key;
        final RouteStep step = entry.value;

        return {
          'imagePath': step.image.path,
          'step_order': index, // or just `index` if you want 0-based
          'description': step.descriptionController.text,
        };
      }).toList(),
      // Should have multiple fields with name "image", that contain the image files
    };

    // In a real app this might post to a server, but for now we print to log
    if (kDebugMode) {
      print('==============================');
      print('ROUTE SAVED IN MEMORY:');
      print(routeData);
      print('==============================');
    }

    // Optionally clear form or show success message
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rota salva com sucesso!')));
  }

  Widget _buildStepBox(
    BuildContext context, {
    required Key key,
    required RouteStep step,
    required stepIndex,
  }) {
    return Align(
      alignment: .center,
      key: key,
      child: Container(
        padding: .all(8),
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.neutral[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 12,
          mainAxisSize: .min,
          children: [
            Column(
              spacing: 140,
              children: [
                Column(
                  spacing: 12,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (stepIndex + 1).toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    if (stepIndex > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_up_rounded),
                        color: AppColors.neutral[400],
                        iconSize: 32,
                        onPressed: () {
                          _reorderStep(stepIndex, stepIndex - 1);
                        },
                      ),
                    if (stepIndex < _steps.length - 1)
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_down_rounded),
                        color: AppColors.neutral[400],
                        iconSize: 32,
                        onPressed: () {
                          _reorderStep(stepIndex, stepIndex + 1);
                        },
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 240,
              child: Column(
                children: [
                  // 1. Wrap in a Stack to layer widgets on top of each other
                  Stack(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          image: DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(step.image.path) as ImageProvider
                                : FileImage(File(step.image.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // 2. Position the close button precisely in the top right corner
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeStep(stepIndex),
                          child: _buildCloseButton(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    hint: 'Escreva a instrução',
                    maxLines: 2,
                    controller: step.descriptionController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.4,
        ), // Semi-transparent background for contrast
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, size: 24, color: Colors.white),
    );
  }
}
