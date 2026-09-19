import 'package:image_picker/image_picker.dart';

class RouteStep {
  final String id;
  final XFile image;
  String description;

  RouteStep({required this.id, required this.image, required this.description});
}
