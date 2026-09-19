import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Color leadingBackgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.leadingBackgroundColor = AppColors.primary100,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFE2E8F0,
          ).withValues(alpha: 0.8), // #E2E8F0 at 80% opacity
          width: 1.0, // 1px stroke
        ),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip
            .antiAlias, // Clips the Material background cleanly inside the border
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                // Leading widget (optional)
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: leadingBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: leading),
                    ),
                  ),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral[800],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.neutral[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
