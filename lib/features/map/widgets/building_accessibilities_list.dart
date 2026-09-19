import 'package:flutter/material.dart';
import 'dart:convert';
import 'list_item.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
class BuildingAccessibilitiesList extends StatelessWidget {
  const BuildingAccessibilitiesList({super.key, required this.accessibilities});

  final List<dynamic> accessibilities;

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

  @override
  Widget build(BuildContext context) {
    if (accessibilities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Nenhum ponto de acessibilidade encontrado.'),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accessibilities.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 4); // Use width for horizontal lists
      },
      itemBuilder: (context, index) {
        final poi = accessibilities[index];
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
    );
  }
}
