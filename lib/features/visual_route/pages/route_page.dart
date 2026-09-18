import 'package:flutter/material.dart';

final routeData = [
  {"img": "exterior-1.webp", "text": "Esta é a primeira instrução importante!"},
  {
    "img": "exterior-2.webp",
    "text": "Esta é a segunda instrução importante :) haha.",
  },
  {
    "img": "exterior-3.webp",
    "text": "Esta é a segunda instrução importante :) haha.",
  },
  {
    "img": "exterior-4.webp",
    "text": "Esta é a segunda instrução importante :) haha.",
  },
  {
    "img": "interior-1.webp",
    "text": "Esta é a segunda instrução importante :) haha.",
  },
];

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Tela bonitinha para a rotinha!")),
        body: ListView(
          scrollDirection: .horizontal,
          children: [
            for (final route in routeData)
              Center(
                child: Card(
                  image: AssetImage("assets/rotas-odonto/${route['img']}"),
                  text: route['text'] ?? "",
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A custom card widget that displays an image with a text label underneath.
///
/// Use this widget within horizontal lists or grid layouts to showcase content.
class Card extends StatelessWidget {
  /// The image source to display in the card's upper container.
  ///
  /// Supports [AssetImage], [NetworkImage], or any other [ImageProvider].
  final ImageProvider<Object> image;

  /// The text caption displayed directly below the image.
  ///
  /// Avoid making this text too long to prevent vertical overflow layouts.
  final String text;

  const Card({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Container(
            width: 450,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(.circular(8)),
              image: DecorationImage(
                image: image,
                fit: .cover,
                alignment: .centerStart,
              ),
            ),
          ),
          Text(text, style: TextStyle(fontSize: 17), textAlign: .left),
        ],
      ),
    );
  }
}
