import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/features/visual_route/pages/dynamic_visual_route_page.dart';

class VisualRoutesBottomSheet extends StatelessWidget {
  const VisualRoutesBottomSheet({
    super.key,
    required this.isLoading,
    required this.routes,
    required this.onDismissed,
  });

  final bool isLoading;
  final List<dynamic> routes;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      onDismissed: onDismissed,
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
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            else if (routes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Nenhuma rota visual encontrada.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  final title = route['title'] ?? 'Sem título';
                  final steps = route['steps'] ?? [];

                  String lastImageUrl = '';
                  if (steps.isNotEmpty) {
                    final sortedSteps =
                        List<Map<String, dynamic>>.from(steps)..sort(
                          (a, b) => (a['stepOrder'] as int).compareTo(
                            b['stepOrder'] as int,
                          ),
                        );
                    lastImageUrl = sortedSteps.last['imageUrl'] ?? '';
                  }

                  final storageBaseUrl = dotenv.env['STORAGE_BASE_URL'] ?? '';
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
    );
  }
}
