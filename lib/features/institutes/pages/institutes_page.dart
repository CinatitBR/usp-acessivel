import 'package:flutter/material.dart';

import 'package:usp_acessivel/features/visual_route/pages/visual_route_page.dart';
import 'package:usp_acessivel/features/institutes/widgets/institute_card.dart';

class InstitutesPage extends StatelessWidget {
  const InstitutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: .min,
              spacing: 12,
              children: [InstituteCard(), InstituteCard1()],
            ),
          ),
          VisualRoutePage(),
        ],
      ),
    );
  }
}

typedef Institute = ({
  String id,
  String name,
  String slug,
  double lon,
  double lat,
});

const List<Institute> institutes = [
  (id: '839', name: 'FAUU', slug: 'fau-usp', lon: -46.728661, lat: -23.560733),
];
