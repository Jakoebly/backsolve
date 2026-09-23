import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The settings chip of a Practice quick start card (practice.png, FR-013,
/// theme-tokens.md §6 "Settings chip"): a tune glyph, the session summary
/// ("60s · adaptive · exact") and a chevron, opening Session Setup for the
/// card's preset.
///
/// [onTeal] picks the recipe: `onPrimaryChip` with white content on the
/// Mixed Session card, `surfaceMuted` with `ink` content on the Weak Spots
/// card.
///
/// The chip hugs its content and is [AppSizes.chipHeight] tall — a minimum,
/// so a large font setting grows it instead of clipping the label.
class SettingsChip extends StatelessWidget {
  const SettingsChip({
    super.key,
    required this.label,
    required this.onTeal,
    required this.onTap,
  });

  final String label;
  final bool onTeal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = onTeal ? AppColors.onPrimary : AppColors.ink;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: onTeal ? AppColors.onPrimaryChip : AppColors.surfaceMuted,
        borderRadius: AppRadius.smAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.chipHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.chipHorizontal,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune,
                  size: AppSizes.iconChip,
                  color: foreground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.chip.copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right,
                  size: AppSizes.iconChip,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
