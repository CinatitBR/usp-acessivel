import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VisualRoutePage extends StatefulWidget {
  const VisualRoutePage({super.key});

  @override
  State<VisualRoutePage> createState() => _VisualRoutePageState();
}

class _VisualRoutePageState extends State<VisualRoutePage> {
  // // This variable is used to restore the draggable sheet drag position
  // // for the purpose of handling over-dragging beyond bounds when
  // // the dragging mouse pointer re-enters the window on web and desktop platforms.
  // double _dragPosition = 0.5;
  // late double _sheetPosition = _dragPosition;

  final minChildSize = 0.15;
  final maxChildSize = 0.95;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // final double viewHeight = constraints.maxHeight;

        return DraggableScrollableSheet(
          initialChildSize: minChildSize, // Percentage of screen taken on init
          minChildSize: minChildSize, // Smallest collapsed state
          maxChildSize: maxChildSize, // Expanded peak height
          // snap: true, // Makes sheet snap to discrete steps
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: .circular(32),
                  topRight: .circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3), // Shadow color
                    spreadRadius: 5, // Extends the shadow past the box
                    blurRadius: 7, // Softens/blurs the shadow
                    offset: const Offset(
                      0,
                      3,
                    ), // Positions shadow (x=0, y=3 moves it down)
                  ),
                ],
              ),
              child: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: routeData.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              const _SheetHandle(),
                              Text(
                                "Rota para os Elevadores",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF133B99),
                                  fontWeight: FontWeight(600),
                                ),
                              ),
                            ],
                          );
                        }
                        return Align(
                          alignment: .center,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: SizedBox(
                                  width: 20,
                                  child: Text(
                                    '${index + 1}.',
                                    style: TextStyle(
                                      color: Color(0xFF133B99),
                                      fontWeight: FontWeight(700),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 8),
                                        if (index == 0)
                                          Icon(
                                            Icons.place,
                                            color: Color(0xFF133B99),
                                          ),
                                        if (index == routeData.length - 1)
                                          Icon(
                                            Icons.place,
                                            color: Color(0xFF22C55E),
                                          ),
                                        SizedBox(width: 4),
                                        Text(
                                          routeData[index]['description'] ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF133B99),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      // width: 300,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          .circular(8),
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            "assets/rotas-odonto/${routeData[index]['img']}",
                                          ),
                                          fit: .cover,
                                          alignment: .centerStart,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Simple drag handle element
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: 70,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }
}

/// A draggable widget that accepts vertical drag gestures.
///
/// This is typically only used in desktop or web platforms.
class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.onVerticalDragUpdate});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: 300,
        color: colorScheme.onSurface,
        child: Align(
          alignment: .topCenter,
          child: Container(
            margin: const .symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: .circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}

const routeData = [
  {"img": "exterior-1.webp", "description": "Ponto de ônibus FOUSP"},
  {"img": "exterior-2.webp", "description": "Siga até a entrada principal"},
  {"img": "exterior-3.webp", "description": "Entrada principal"},
  {"img": "exterior-4.webp", "description": "Siga pela porta"},
  {"img": "interior-1.webp", "description": "Siga reto até as catracas"},
];
