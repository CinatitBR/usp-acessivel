import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/core/widgets/app_bottom_sheet.dart';
import 'package:usp_acessivel/features/poi/pages/create_poi_page.dart';
import 'package:usp_acessivel/features/visual_route/pages/create_visual_route_page.dart';

class CommunityActionsBottomSheet extends StatelessWidget {
  CommunityActionsBottomSheet({super.key, this.onDismissed});

  final void Function()? onDismissed;

  final List<(String title, IconData icon, Widget page)> actions = [
    ('Criar Rota Visual', Icons.add, CreateVisualRoutePage()),
    ('Ponto de Acessibilidade', Icons.add, CreatePoiPage()),
    ('Buraco na via', Icons.add, CreatePoiPage()),
    ('Rampa bloqueada', Icons.add, CreatePoiPage()),
    ('Elevador quebrado', Icons.add, CreatePoiPage()),
    ('Entrada inacessível', Icons.add, CreatePoiPage()),
    ('Árvore caída', Icons.add, CreatePoiPage()),
    ('Obra no caminho', Icons.add, CreatePoiPage()),
    ('Calçada irregular', Icons.add, CreatePoiPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      onDismissed: onDismissed,
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
                    icon: Icon(action.$2),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => action.$3),
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
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
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
