import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';

class RouteAccessibilityToggleButton extends StatelessWidget {
  const RouteAccessibilityToggleButton({
    super.key,
    required this.pointCount,
    required this.onPressed,
  });

  final int pointCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.accessible_forward_rounded, size: 20),
            label: Text('Acessibilidade da Rota ($pointCount)'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary[700],
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
