import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/features/poi/pages/create_poi_page.dart';
import 'package:usp_acessivel/features/visual_route/pages/create_visual_route_page.dart';

class CommunityActionsBottomSheet extends StatelessWidget {
  CommunityActionsBottomSheet({super.key, this.onDismissed});

  final void Function()? onDismissed;

  final List<(String title, IconData icon, Color color, Widget page)>
  actions = [
    (
      'Criar Rota Visual',
      Icons.add,
      AppColors.primary[700]!,
      CreateVisualRoutePage(),
    ),
    (
      'Ponto de Acessibilidade',
      Icons.add,
      AppColors.primary[700]!,
      CreatePoiPage(),
    ),
    ('Faixa bloqueada', Icons.block, Color(0xFFDC2626), CreatePoiPage()),
    (
      'Buraco na via',
      Icons.dangerous_outlined,
      Color(0xFFEA580C),
      CreatePoiPage(),
    ),
    (
      'Rampa bloqueada',
      Icons.not_accessible,
      Color(0xFFA16207),
      CreatePoiPage(),
    ),
    (
      'Elevador quebrado',
      Icons.elevator_outlined,
      Color(0xFF475569),
      CreatePoiPage(),
    ),
    (
      'Entrada inacessível',
      Icons.no_meeting_room_outlined,
      Color(0xFFF97316),
      CreatePoiPage(),
    ),
    ('Árvore caída', Icons.park_outlined, Color(0xFF15803D), CreatePoiPage()),
    ('Obra no caminho', Icons.construction, Color(0xFFCA8A04), CreatePoiPage()),
    ('Calçada irregular', Icons.texture, Color(0xFF57534E), CreatePoiPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      onDismissed: onDismissed,
      // initialChildSize: 0.6,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Encontrou um obstáculo?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: AppColors.primary[700]),
              ),
              const SizedBox(height: 4),
              Text(
                'Ajude outros estudantes registrando o que está acontecendo neste local.',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: AppColors.neutral[600],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: actions.map((action) {
                  return _CommunityActionCard(
                    title: action.$1,
                    icon: Icon(action.$2, size: 32, color: action.$3),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => action.$4),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityActionCard extends StatelessWidget {
  const _CommunityActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Card.outlined(
        // clipBehavior is necessary because, without it, the InkWell's animation
        // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
        // This comes with a small performance cost, and you should not set [clipBehavior]
        // unless you need it.
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.neutral[200],
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppColors.neutral[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
