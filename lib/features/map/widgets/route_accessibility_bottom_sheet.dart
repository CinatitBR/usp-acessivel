import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/features/map/models/route_accessibility_point.dart';

class RouteAccessibilityBottomSheet extends StatelessWidget {
  const RouteAccessibilityBottomSheet({
    super.key,
    required this.points,
    this.selectedPointId,
    this.onPointSelected,
    required this.onDismissed,
  });

  final List<RouteAccessibilityPoint> points;
  final String? selectedPointId;
  final ValueChanged<String>? onPointSelected;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      initialChildSize: 0.15,
      maxChildSize: 0.85,
      onDismissed: onDismissed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.accessible_forward_rounded,
                    color: AppColors.primary[700],
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Acessibilidade da Rota',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'IME → Poli • ${points.length} trechos com observações',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Summary quick badges
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _SummaryChip(
                    icon: Icons.warning_amber_rounded,
                    label: 'Calçada irregular (raízes)',
                    color: AppColors.warning,
                  ),
                  _SummaryChip(
                    icon: Icons.do_not_disturb_on_total_silence_rounded,
                    label: 'Largura < 80 cm',
                    color: AppColors.error,
                  ),
                  _SummaryChip(
                    icon: Icons.volume_up_rounded,
                    label: 'Ruído em pico',
                    color: AppColors.information,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Route segments detail
              Text(
                'Pontos de Atenção no Trajeto',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral[800],
                ),
              ),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: points.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final point = points[index];
                  final isSelected = point.id == selectedPointId;

                  return _RoutePointCard(
                    point: point,
                    isSelected: isSelected,
                    onFocus: () => onPointSelected?.call(point.id),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePointCard extends StatelessWidget {
  const _RoutePointCard({
    required this.point,
    required this.isSelected,
    required this.onFocus,
  });

  final RouteAccessibilityPoint point;
  final bool isSelected;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final isSevere = point.severity == RouteAccessibilitySeverity.severe;
    final badgeColor = isSevere ? AppColors.error : AppColors.warning;
    final badgeText = isSevere ? 'Barreira Crítica' : 'Atenção';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.neutral[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segment Header
          Row(
            children: [
              Expanded(
                child: Text(
                  point.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Attributes
          _DetailRow(
            icon: Icons.layers_outlined,
            title: 'Tipo de superfície',
            description: point.surfaceType,
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.alt_route_rounded,
            title: 'Regularidade da superfície',
            description: point.regularity,
            highlight: !isSevere,
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.straighten_rounded,
            title: 'Dimensões da superfície',
            description: point.dimensions,
            highlight: isSevere,
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.volume_down_rounded,
            title: 'Barulho',
            description: point.noise,
          ),
          const SizedBox(height: 12),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onFocus,
              icon: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.place_outlined,
                size: 16,
              ),
              label: Text(isSelected ? 'Destacado no mapa' : 'Ver no mapa'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary[700],
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.description,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(
            icon,
            size: 16,
            color: highlight ? AppColors.warning : AppColors.neutral[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: AppColors.neutral[800],
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(
                    color: highlight ? Colors.black87 : AppColors.neutral[700],
                    fontWeight: highlight ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
