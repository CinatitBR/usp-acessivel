import 'package:flutter/material.dart';

class InfoWindow extends StatelessWidget {
  final String title;
  final IconData icon;
  final double maxWidth;
  final double maxHeight;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const InfoWindow({
    super.key,
    required this.title,
    required this.icon,
    this.maxWidth = 200,
    this.maxHeight = 200,
    this.backgroundColor = const Color(0xFFD5491D),
    this.iconColor = Colors.white,
    this.textColor = const Color(0xFF222222),
    this.borderColor = const Color(0xFFD5491D),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Column(
          children: [
            // Main card content
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon box
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 8),
                  // Title text
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontFamily: 'AlegreyaSans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Pointer arrow
            CustomPaint(
              size: const Size(24, 12),
              painter: _PointerPainter(
                color: Colors.white,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _PointerPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Create triangle pointing downward
    final path = Path()
      ..moveTo(size.width / 2 - 8, 0)
      ..lineTo(size.width / 2 + 8, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) => false;
}
