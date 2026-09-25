import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// An uppercase section header or in-card overline ("LAST 8 WEEKS",
/// "QUICK START", "CATEGORIES", "SESSION TYPE", "ACCURACY", …) in
/// `sectionLabel` style with [spacing] (default `sm`) below it.
///
/// [color] recolours it (e.g. `onPrimarySubtle` on a teal card); [icon]
/// adds the small leading glyph the quick start overlines carry.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.icon,
    this.spacing = AppSpacing.sm,
  });

  final String text;
  final Color? color;
  final IconData? icon;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final style = color == null
        ? AppTextStyles.sectionLabel
        : AppTextStyles.sectionLabel.copyWith(color: color);
    final label = Text(text.toUpperCase(), style: style);
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: icon == null
          ? label
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSizes.iconSm, color: style.color),
                const SizedBox(width: AppSpacing.xs),
                label,
              ],
            ),
    );
  }
}
