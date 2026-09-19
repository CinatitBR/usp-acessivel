import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RouteStep {
  final String id;
  final XFile image;
  final TextEditingController descriptionController;

  RouteStep({
    required this.id,
    required this.image,
    required this.descriptionController,
  });
}
