import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart';

class RouteStep {
  final XFile image;
  final TextEditingController descriptionController;

  RouteStep({required this.image, required this.descriptionController});
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
  String _selectedLocation = 'Apple';
  final List<RouteStep> _steps = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _locationController.text = _selectedLocation;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            Icon(Icons.arrow_back, color: AppColors.primary[700]),
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
                controller: _locationController,
                label: const Text('Selecione o local'),
                initialSelection: _selectedLocation,
                onSelected: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedLocation = value;
                      _locationController.text = value;
                    });
                  }
                },
                textStyle: const TextStyle(color: Color(0xFF1A1C1C)),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'Apple', label: 'Apple'),
                  DropdownMenuEntry(value: 'Banana', label: 'Banana'),
                  DropdownMenuEntry(value: 'Cherry', label: 'Cherry'),
                ],
              ),
              _buildFieldTitle(context, 'Sobre esta rota'),
              _buildTextField(
                context,
                hint: 'Descreva brevemente o percurso...',
                controller: _descriptionController,
              ),
              Text(
                'Fotos da rota',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton(
                onPressed: _pickImageAndAddStep,
                style: FilledButton.styleFrom(fixedSize: Size(200, 40)),
                child: Row(
                  mainAxisAlignment: .center,
                  spacing: 16,
                  children: [
                    Icon(Icons.camera_alt_outlined),
                    const Text('Adicionar fotos'),
                  ],
                ),
              ),
              ..._steps.asMap().entries.map((entry) {
                return _buildStepBox(context, entry.key, entry.value);
              }),
              FilledButton(
                onPressed: _onCancel,
                style: FilledButton.styleFrom(
                  fixedSize: Size(150, 40),
                  backgroundColor: AppColors.neutral[200],
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.neutral[700]),
                ),
              ),
              FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(fixedSize: Size(150, 40)),
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

  Widget _buildTextField(BuildContext context, {String? hint, int? maxLines, TextEditingController? controller}) {
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

  Future<void> _pickImageAndAddStep() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _steps.add(RouteStep(
          image: image,
          descriptionController: TextEditingController(),
        ));
      });
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
      _selectedLocation = 'Apple';
      _locationController.text = 'Apple';
      for (var step in _steps) {
        step.descriptionController.dispose();
      }
      _steps.clear();
    });
  }

  void _onSave() {
    final Map<String, dynamic> routeData = {
      'title': _titleController.text,
      'location': _selectedLocation,
      'description': _descriptionController.text,
      'steps': _steps.map((step) => {
        'imagePath': step.image.path,
        'description': step.descriptionController.text,
      }).toList(),
    };

    // In a real app this might post to a server, but for now we print to log
    if (kDebugMode) {
      print('==============================');
      print('ROUTE SAVED IN MEMORY:');
      print(routeData);
      print('==============================');
    }

    // Optionally clear form or show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rota salva com sucesso!')),
    );
  }

  Widget _buildStepBox(BuildContext context, int index, RouteStep step) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
                  ),
                ),
                if (index < _steps.length - 1)
                  const Icon(Icons.arrow_circle_up_rounded),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 300,
            child: Column(
              children: [
                // 1. Wrap in a Stack to layer widgets on top of each other
                Stack(
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                        onTap: () => _removeStep(index),
                        child: _buildCloseButton(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  context,
                  hint: 'Descreva brevemente o percurso',
                  maxLines: 3,
                  controller: step.descriptionController,
                ),
              ],
            ),
          ),
        ],
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
