import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapCommunityActionButton extends StatelessWidget {
  const MapCommunityActionButton({super.key, this.onPressed});

  final void Function()? onPressed;

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
        onPressed: onPressed,
      ),
    );
  }
}
