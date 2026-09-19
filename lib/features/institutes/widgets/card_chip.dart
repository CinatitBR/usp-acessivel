import 'package:flutter/material.dart';
import '../models/accessibility_status.dart';

class CardChip extends StatelessWidget {
  // Positional parameters ordered by importance
  final String text;
  final AccessibilityStatus status;

  const CardChip(this.text, this.status, {super.key});

  // Dependent variable getters based on the status parameter
  Color? get _textColor {
    switch (status) {
      case AccessibilityStatus.available:
        return Colors.green[700];
      case AccessibilityStatus.partial:
        return Colors.yellow[900];
      case AccessibilityStatus.unavailable:
        return Colors.red[700];
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case AccessibilityStatus.available:
        return const Color(0xFFC0F8D4);
      case AccessibilityStatus.partial:
        return const Color(0xFFFAF3B0);
      case AccessibilityStatus.unavailable:
        return const Color(0xFFFCE5DA);
    }
  }

  IconData get _icon {
    switch (status) {
      case AccessibilityStatus.available:
        return Icons.check;
      case AccessibilityStatus.partial:
        return Icons.check; // Keeps check icon for yellow status
      case AccessibilityStatus.unavailable:
        return Icons.close_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(_icon, color: _textColor, size: 20.0),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: _textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      backgroundColor: _backgroundColor,
      side: BorderSide.none,
    );
  }
}
