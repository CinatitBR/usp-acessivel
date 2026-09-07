import 'package:flutter/material.dart';

class EventListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> events;
  final Color headerColor;
  final VoidCallback? onEventTap;

  const EventListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.events,
    this.headerColor = const Color(0xFFF09415),
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with icon and title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'AlegreyaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Content area with events list
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: events
                .map(
                  (event) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: onEventTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '➤',
                            style: TextStyle(color: headerColor, fontSize: 8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontFamily: 'AlegreyaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // Pointer arrow
        CustomPaint(
          size: const Size(24, 12),
          painter: _DownwardPointerPainter(color: Colors.white),
        ),
      ],
    );
  }
}

class _DownwardPointerPainter extends CustomPainter {
  final Color color;

  _DownwardPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create triangle pointing downward
    final path = Path()
      ..moveTo(size.width / 2 - 10, 0)
      ..lineTo(size.width / 2 + 10, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownwardPointerPainter oldDelegate) => false;
}
