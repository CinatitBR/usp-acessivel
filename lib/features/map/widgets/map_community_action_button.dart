import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/features/poi/pages/create_poi_page.dart';
import 'package:usp_acessivel/features/visual_route/pages/create_visual_route_page.dart';

class MapCommunityActionButton extends StatelessWidget {
  const MapCommunityActionButton({super.key});

  void _showActionModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Criar rota visual'),
                    subtitle: const Text('Envie uma rota visual'),
                    trailing: const Icon(Icons.chevron_right_sharp),
                    splashColor: AppColors.neutral[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateVisualRoutePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Criar Ponto de Acessibilidade'),
                    subtitle: const Text('Cadastre um novo ponto'),
                    trailing: const Icon(Icons.chevron_right_sharp),
                    splashColor: AppColors.neutral[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreatePoiPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: IconButton(
        icon: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/icons/community-report.svg',
            width: 60,
          ),
        ),
        onPressed: () => _showActionModal(context),
      ),
    );
  }
}
