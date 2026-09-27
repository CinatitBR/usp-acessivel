import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/features/map/models/map_style.dart';

class MapStyleButton extends StatelessWidget {
  const MapStyleButton({
    super.key,
    required this.currentStyle,
    required this.onStyleSelected,
    this.bottom = 104.0,
    this.right = 24.0,
  });

  final AppMapStyle currentStyle;
  final ValueChanged<AppMapStyle> onStyleSelected;
  final double bottom;
  final double right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.neutral[200] ?? const Color(0xFFEAEAEA),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          width: 60,
          height: 60,
          child: PopupMenuButton<AppMapStyle>(
            initialValue: currentStyle,
            onSelected: onStyleSelected,
            tooltip: 'Estilo do mapa',
            offset: const Offset(0, -118),
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Icon(
              Icons.layers_rounded,
              color: AppColors.primary[700],
              size: 26,
            ),
            itemBuilder: (context) {
              return AppMapStyle.values.map((style) {
                final isSelected = style == currentStyle;
                return PopupMenuItem<AppMapStyle>(
                  value: style,
                  child: Row(
                    children: [
                      Icon(
                        style.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.primary[700]
                            : AppColors.neutral[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          style.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary[700]
                                : AppColors.neutral[800],
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppColors.primary[700],
                        ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
