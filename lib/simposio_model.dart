import 'dart:convert';
import 'package:flutter/services.dart';

class Simposio {
  final String id;
  final String title;
  final String classroom;

  const Simposio({
    required this.id,
    required this.title,
    required this.classroom,
  });

  // Factory constructor to create Simposio from JSON
  factory Simposio.fromJson(Map<String, dynamic> json) {
    return Simposio(
      id: json['id'] as String,
      title: json['title'] as String,
      classroom: json['classroom'] as String,
    );
  }

  // Convert Simposio to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'classroom': classroom};
  }
}

// Function to load simposios from JSON file
Future<List<Simposio>> loadSimposios() async {
  try {
    final jsonString = await rootBundle.loadString('data/simposios.json');
    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    return jsonData
        .map((item) => Simposio.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error loading simposios: $e');
    return [];
  }
}
