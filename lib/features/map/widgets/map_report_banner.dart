import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import '../models/map_report_model.dart';

class MapReportBanner extends StatelessWidget {
  const MapReportBanner({
    super.key,
    required this.report,
    required this.onDismissed,
  });

  final MapReport report;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final storageBaseUrl = dotenv.env['STORAGE_BASE_URL'] ?? '';
    final hasImage = report.imageUrl != null && report.imageUrl!.trim().isNotEmpty;
    final hasDescription = report.description != null && report.description!.trim().isNotEmpty;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        // Prevent taps inside the banner from triggering outside dismissal
        onTap: () {},
        child: Material(
          elevation: 6,
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.neutral[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Icon, Title, Category, Close Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: report.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: report.color.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            report.iconData,
                            color: report.color,
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
                              report.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral[900],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              report.categoryLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onDismissed,
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.neutral[600],
                        tooltip: 'Fechar',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  // Severity badge (if applicable)
                  if (report.severity != null) ...[
                    const SizedBox(height: 12),
                    _SeverityBadge(severity: report.severity!),
                  ],

                  // Description section
                  const SizedBox(height: 12),
                  if (hasDescription)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.neutral[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.notes_rounded,
                              size: 18,
                              color: AppColors.neutral[600],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              report.description!.trim(),
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.neutral[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Nenhuma descrição detalhada informada.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.neutral[500],
                        ),
                      ),
                    ),

                  // Image evidence (if uploaded)
                  if (hasImage && storageBaseUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '$storageBaseUrl/${report.imageUrl}',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 140,
                            color: AppColors.neutral[100],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],

                  // Optional details (building info)
                  if (report.buildingId != null && report.buildingId!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 16,
                          color: AppColors.neutral[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Prédio associado: ${report.buildingId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final isSevere = severity == 'severe';
    final bgColor = isSevere
        ? AppColors.error.withValues(alpha: 0.12)
        : AppColors.warning.withValues(alpha: 0.12);
    final borderColor = isSevere
        ? AppColors.error.withValues(alpha: 0.4)
        : AppColors.warning.withValues(alpha: 0.4);
    final textColor = isSevere ? const Color(0xFFB91C1C) : const Color(0xFFB45309);
    final iconData = isSevere ? Icons.error_outline_rounded : Icons.warning_amber_rounded;
    final label = isSevere ? 'Severidade: Severa' : 'Severidade: Moderada';

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
            iconData,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
