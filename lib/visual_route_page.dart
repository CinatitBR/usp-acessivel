import 'package:flutter/material.dart';
import 'package:usp_acessivel/app_bottom_sheet.dart';

class VisualRoutePage extends StatefulWidget {
  const VisualRoutePage({super.key});

  @override
  State<VisualRoutePage> createState() => _VisualRoutePageState();
}

class _VisualRoutePageState extends State<VisualRoutePage> {
  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      child: Column(
        children: [
          const Text(
            "Rota para os Elevadores",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF133B99),
              fontWeight: FontWeight(600),
            ),
          ),
          for (int i = 0; i < routeData.length; i++)
            _StepItem(index: i, step: routeData[i]),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.index, required this.step});

  final int index;
  final VisualRouteStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: .center,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                          Icon(Icons.place, color: Color(0xFF133B99)),
                        if (index == routeData.length - 1)
                          Icon(Icons.place, color: Color(0xFF22C55E)),
                        SizedBox(width: 4),
                        Text(
                          step.description,
                          style: TextStyle(
                            color: Color(0xFF133B99),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(.circular(8)),
                        image: DecorationImage(
                          image: AssetImage("assets/rotas-odonto/${step.img}"),
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
        ),
      ],
    );
  }
}

typedef VisualRouteStep = ({String img, String description});

List<VisualRouteStep> routeData = [
  (img: 'exterior-1.webp', description: 'Ponto de ônibus FOUSP'),
  (img: 'exterior-2.webp', description: 'Siga até a entrada principal'),
  (img: 'exterior-3.webp', description: 'Entrada principal'),
  (img: 'exterior-4.webp', description: 'Siga pela porta'),
  (img: 'interior-1.webp', description: 'Siga reto até as catracas'),
];
