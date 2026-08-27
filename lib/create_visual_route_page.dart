import 'package:flutter/material.dart';
import 'app_colors.dart';

class CreateVisualRoutePage extends StatelessWidget {
  const CreateVisualRoutePage({super.key});

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
              ),
              _buildFieldTitle(context, 'Edifício ou instituto'),
              DropdownMenu(
                label: const Text('Selecione o local'),
                initialSelection: 'Apple',
                onSelected: (String? value) {
                  print('Selected: $value');
                },
                textStyle: TextStyle(color: Color(0xFF1A1C1C)),
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
              ),
              Text(
                'Fotos da rota',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton(
                onPressed: () {},
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
              _buildStepBox(context),
              FilledButton(
                onPressed: () {},
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
                onPressed: () {},
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

  Widget _buildTextField(BuildContext context, {String? hint, int? maxLines}) {
    return TextField(
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

  Widget _buildStepBox(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: const [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '01',
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
                  ),
                ),
                Icon(Icons.arrow_circle_up_rounded),
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
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/rotas-odonto/exterior-3.webp',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // 2. Position the close button precisely in the top right corner
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // Handle close button action here
                        },
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
