import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_bottom_sheet.dart';

class DynamicVisualRoutePage extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const DynamicVisualRoutePage({super.key, required this.routeData});

  @override
  Widget build(BuildContext context) {
    final String title = routeData['title'] ?? 'Rota Visual';
    final List<dynamic> steps = routeData['steps'] ?? [];

    // Make sure steps are sorted by stepOrder just in case
    final sortedSteps = List<Map<String, dynamic>>.from(
      steps,
    )..sort((a, b) => (a['stepOrder'] as int).compareTo(b['stepOrder'] as int));

    return Scaffold(
      backgroundColor: Colors
          .transparent, // Required for bottom sheet to look right if pushed
      body: AppBottomSheet(
        onDismissed: () => Navigator.of(context).pop(),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF133B99),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < sortedSteps.length; i++)
              _StepItem(
                index: i,
                step: sortedSteps[i],
                isLast: i == sortedSteps.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.step,
    required this.isLast,
  });

  final int index;
  final Map<String, dynamic> step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final description = step['description'] ?? '';
    final imageUrl = step['imageUrl'] ?? '';

    final storageBaseUrl = dotenv.env['STORAGE_BASE_URL'] ?? '';
    final fullImageUrl = imageUrl.isNotEmpty ? '$storageBaseUrl/$imageUrl' : '';

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  child: Text(
                    '${index + 1}.',
                    style: const TextStyle(
                      color: Color(0xFF133B99),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        if (isLast)
                          const Icon(Icons.place, color: Color(0xFF22C55E))
                        else if (index == 0)
                          const Icon(Icons.place, color: Color(0xFF133B99)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: Color(0xFF133B99),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (fullImageUrl.isNotEmpty)
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(fullImageUrl),
                            fit: BoxFit.cover,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
