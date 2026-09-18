import 'package:flutter/material.dart';
import '../models/accessibility_status.dart';
import 'card_chip.dart';

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

