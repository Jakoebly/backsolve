import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The round play control of the quick start cards (theme-tokens.md §6
/// "Play circle"): `onPrimaryCircle` with a white glyph on a teal card,
/// `surfaceMuted` with an `ink` glyph on a white card.
class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.size,
    required this.onTeal,
    required this.onTap,
  });

  /// [AppSizes.playCircleLg] on Home, [AppSizes.playCircleSm] on Practice.
  final double size;
  final bool onTeal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = size >= AppSizes.playCircleLg
        ? AppSizes.playIconLg
        : AppSizes.playIconSm;
    return Semantics(
      button: true,
      label: 'Start session',
      child: Material(
        color: onTeal ? AppColors.onPrimaryCircle : AppColors.surfaceMuted,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.play_arrow_rounded,
              size: iconSize,
              color: onTeal ? AppColors.onPrimary : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
