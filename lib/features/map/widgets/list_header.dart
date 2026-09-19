import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
class ListHeader extends StatelessWidget {
  const ListHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral[800],
          ),
        ),
      ),
    );
  }
}
