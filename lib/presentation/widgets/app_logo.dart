import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The Backsolve mark on its teal tile (Home header). Drawn from theme tokens
/// so it matches the launcher icon exactly (FR-018–FR-020).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.appIcon,
      height: AppSizes.appIcon,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.appIconRadius),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.appIconMarkGap,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSizes.appIconMarkGap,
              children: [
                _MarkSquare(color: AppColors.onPrimary),
                _MarkSquare(color: AppColors.onPrimary),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSizes.appIconMarkGap,
              children: [
                _MarkSquare(color: AppColors.onPrimary),
                _MarkSquare(color: AppColors.mutedTeal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One square of the 2 × 2 mark.
class _MarkSquare extends StatelessWidget {
  const _MarkSquare({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.appIconMarkSquare,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.appIconMarkRadius),
        ),
      ),
    );
  }
}
