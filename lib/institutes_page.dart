import 'package:flutter/material.dart';

import 'visual_route_page.dart';

class InstitutesPage extends StatelessWidget {
  const InstitutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: .min,
              spacing: 12,
              children: [InstituteCard(), InstituteCard1()],
            ),
          ),
          VisualRoutePage(),
        ],
      ),
    );
  }
}

typedef Institute = ({
  String id,
  String name,
  String slug,
  double lon,
  double lat,
});

const List<Institute> institutes = [
  (id: '839', name: 'FAUU', slug: 'fau-usp', lon: -46.728661, lat: -23.560733),
];

class InstituteCard extends StatelessWidget {
  const InstituteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            'Faculdade de Filosofia, Letras e Ciências Humanas',
            style: TextStyle(
              fontWeight: .bold,
              fontSize: 20,
              color: Color(0xFF1B4ACD),
            ),
          ),
          Text('Rua do Lago, 876', style: TextStyle(color: Color(0xFF737373))),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Acessibilidade',
                  style: TextStyle(fontSize: 18, color: Color(0xFF133B99)),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8.0, //  Horizontal gap
                  runSpacing: 2.0, // Vertical/line gap
                  alignment: .start,
                  children: [
                    CardChip(
                      'Entrada acessível',
                      AccessibilityStatus.available,
                    ),
                    CardChip('Elevadores', AccessibilityStatus.available),
                    CardChip('Banheiros PCD', AccessibilityStatus.available),
                    CardChip('Piso tátil parcial', AccessibilityStatus.partial),
                    CardChip('Rampas', AccessibilityStatus.unavailable),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InstituteCard1 extends StatelessWidget {
  const InstituteCard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faculdade de Filosofia, Letras e Ciências Humanas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1B4ACD),
            ),
          ),
          const Text(
            'Rua do Lago, 876',
            style: TextStyle(color: Color(0xFF737373)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const Text(
                  'Acessibilidade',
                  style: TextStyle(fontSize: 18, color: Color(0xFF133B99)),
                ),
                const SizedBox(height: 4),

                // Limit the height to force elements to flow into the next column 👇
                SizedBox(
                  height:
                      90, // Adjust this height depending on your item text size
                  child: Wrap(
                    direction: Axis.vertical, // Stacks items vertically first
                    spacing:
                        6.0, // Vertical gap between items in the same column
                    runSpacing: 24.0, // Horizontal gap between the columns
                    children: [
                      _buildGridItem('Entrada acessível', Colors.green),
                      _buildGridItem('Elevadores', Colors.green),
                      _buildGridItem('Banheiros PCD', Colors.green),
                      _buildGridItem('Piso tátil parcial', Colors.yellow[900]!),
                      _buildGridItem('Rampas', Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String text, Color bulletColor) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Vital so row doesn't take infinite width
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('●', style: TextStyle(fontSize: 12, color: bulletColor)),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1A1C1F)),
        ),
      ],
    );
  }
}

// Defines all possible states for accessibility chips
enum AccessibilityStatus { available, partial, unavailable }

class CardChip extends StatelessWidget {
  // Positional parameters ordered by importance
  final String text;
  final AccessibilityStatus status;

  const CardChip(this.text, this.status, {super.key});

  // Dependent variable getters based on the status parameter
  Color? get _textColor {
    switch (status) {
      case AccessibilityStatus.available:
        return Colors.green[700];
      case AccessibilityStatus.partial:
        return Colors.yellow[900];
      case AccessibilityStatus.unavailable:
        return Colors.red[700];
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case AccessibilityStatus.available:
        return const Color(0xFFC0F8D4);
      case AccessibilityStatus.partial:
        return const Color(0xFFFAF3B0);
      case AccessibilityStatus.unavailable:
        return const Color(0xFFFCE5DA);
    }
  }

  IconData get _icon {
    switch (status) {
      case AccessibilityStatus.available:
        return Icons.check;
      case AccessibilityStatus.partial:
        return Icons.check; // Keeps check icon for yellow status
      case AccessibilityStatus.unavailable:
        return Icons.close_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(_icon, color: _textColor, size: 20.0),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: _textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      backgroundColor: _backgroundColor,
      side: BorderSide.none,
    );
  }
}
