import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'list_item.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/features/visual_route/pages/dynamic_visual_route_page.dart';
class BuildingVisualRoutesList extends StatelessWidget {
  const BuildingVisualRoutesList({super.key, required this.visualRoutes});

  final List<dynamic> visualRoutes;

  @override
  Widget build(BuildContext context) {
    if (visualRoutes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Nenhuma rota encontrada.'),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visualRoutes.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 4); // Use width for horizontal lists
      },
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
