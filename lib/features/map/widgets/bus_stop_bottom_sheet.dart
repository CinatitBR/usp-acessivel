import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';

class BusStopBottomSheet extends StatelessWidget {
  const BusStopBottomSheet({
    super.key,
    required this.busStop,
    required this.onDismissed,
  });

  final Map<String, dynamic> busStop;
  final VoidCallback onDismissed;

  List<String> _parseRoutes(String? routeRef) {
    if (routeRef == null || routeRef.trim().isEmpty) return [];
    return routeRef
        .split(';')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();
  }

  List<String> _parseCirculars(String? source) {
    if (source == null || source.trim().isEmpty) return [];
    List<String> circulars = [];
    if (source.contains('Circular 1')) circulars.add('Circular 1');
    if (source.contains('Circular 2')) circulars.add('Circular 2');
    if (source.contains('Circular 3')) circulars.add('Circular 3');
    if (circulars.isEmpty && source.toLowerCase().contains('circular')) {
      circulars.add(source);
    }
    return circulars;
  }

  @override
  Widget build(BuildContext context) {
    final name = (busStop['name'] as String?)?.trim();
    final localRef = (busStop['local_ref'] as String?)?.trim();
    final title = (name != null && name.isNotEmpty)
        ? name
        : (localRef != null && localRef.isNotEmpty)
            ? localRef
            : 'Ponto de Ônibus';

    final subtitle = (name != null &&
            name.isNotEmpty &&
            localRef != null &&
            localRef.isNotEmpty &&
            name != localRef)
        ? localRef
        : 'Ponto de Ônibus • Campus USP';

    final description = (busStop['description'] as String?)?.trim();
    final routes = _parseRoutes(busStop['route_ref'] as String?);
    final circulars = _parseCirculars(busStop['source'] as String?);

    final hasShelter = busStop['shelter'] == 'yes';
    final hasBench = busStop['bench'] == 'yes';
    final isLit = busStop['lit'] == 'yes';
    final hasBin = busStop['bin'] == 'yes';
    final wheelchair = (busStop['wheelchair'] as String?)?.toLowerCase();
    final isWheelchairAccessible = wheelchair == 'yes';

    return AppBottomSheet(
      onDismissed: onDismissed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_bus_rounded,
                        color: Color(0xFF0284C7),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral[900],
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description if available
              if (description != null && description.isNotEmpty) ...[
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
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.neutral[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Bus Lines Section
              if (circulars.isNotEmpty || routes.isNotEmpty) ...[
                Text(
                  'Linhas de Ônibus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...circulars.map(
                      (circ) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sync_rounded,
                              size: 14,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              circ,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...routes.map(
                      (route) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          route,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Accessibility and Amenities Section
              Text(
                'Estrutura e Acessibilidade',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral[800],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AmenityBadge(
                    icon: Icons.roofing_rounded,
                    label: hasShelter ? 'Com cobertura' : 'Sem cobertura',
                    isPositive: hasShelter,
                  ),
                  _AmenityBadge(
                    icon: Icons.chair_outlined,
                    label: hasBench ? 'Possui bancos' : 'Sem bancos',
                    isPositive: hasBench,
                  ),
                  if (isLit)
                    const _AmenityBadge(
                      icon: Icons.lightbulb_outline,
                      label: 'Iluminado',
                      isPositive: true,
                    ),
                  if (isWheelchairAccessible)
                    const _AmenityBadge(
                      icon: Icons.accessible_rounded,
                      label: 'Acessível cadeirante',
                      isPositive: true,
                      highlightSuccess: true,
                    ),
                  if (hasBin)
                    const _AmenityBadge(
                      icon: Icons.delete_outline,
                      label: 'Com lixeira',
                      isPositive: true,
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmenityBadge extends StatelessWidget {
  const _AmenityBadge({
    required this.icon,
    required this.label,
    required this.isPositive,
    this.highlightSuccess = false,
  });

  final IconData icon;
  final String label;
  final bool isPositive;
  final bool highlightSuccess;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (highlightSuccess) {
      bgColor = AppColors.success.withValues(alpha: 0.12);
      borderColor = AppColors.success.withValues(alpha: 0.4);
      textColor = const Color(0xFF15803D);
    } else if (isPositive) {
      bgColor = AppColors.neutral[100]!;
      borderColor = AppColors.neutral[300]!;
      textColor = AppColors.neutral[800]!;
    } else {
      bgColor = AppColors.neutral[50]!;
      borderColor = AppColors.neutral[200]!;
      textColor = AppColors.neutral[500]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
