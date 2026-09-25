import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The white card recipe (theme-tokens.md §6): `surface` fill, 1 dp `border`,
/// radius [radius], padding `md`. [selected] swaps in the 2 dp `primary`
/// border of the selected session-type card without moving the content.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.radius = AppRadius.md,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.selected = false,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderWidth = selected
        ? AppSizes.selectedCardBorderWidth
        : AppSizes.cardBorderWidth;
    // DecoratedBox paints the border inside the padding, so the content box
    // stays identical whether the border is 1 dp or the selected 2 dp.
    final borderRadius = BorderRadius.circular(radius);
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadius,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: borderWidth,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: card),
    );
  }
}

/// The teal card recipe: `primary` fill, radius `lg`, padding `md`, no border.
class TealCard extends StatelessWidget {
  const TealCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(borderRadius: AppRadius.lgAll, onTap: onTap, child: card),
    );
  }
}
