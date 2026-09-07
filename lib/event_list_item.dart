import 'package:flutter/material.dart';

class EventListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Color leadingBackgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  const EventListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.leadingBackgroundColor = const Color(0xFFE8D5F2),
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFeeb6a4).withAlpha(40),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: contentPadding,
          child: Row(
            children: [
              // Leading widget (optional)
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: leadingBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
