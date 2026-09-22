import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// One cell of the Practice category grid (practice.png, FR-016): the name
/// centred on one line over a "Level N" badge and an average-time badge.
///
/// The card is at least `categoryCardHeight` tall (the mockup's 80 px) and
/// grows with its text, so nothing ever overflows; the name sits in a
/// [FittedBox] so a long one ("Margins & Breakeven") shrinks slightly
/// instead of truncating or wrapping (spec edge case "long category
/// names"). The padding is tighter than the generic white card (measured
/// 14 × 10 px, theme-tokens.md §6); horizontally it is `xs` because Roboto
/// is wider than the mockup's face and the two badges need 133 dp on a
/// 360 dp phone — with `sm` they would wrap. The content is centred, so the
/// padding is only ever visible as the room the badges and name have.
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSizes.categoryCardHeight,
      ),
      child: AppCard(
        radius: AppRadius.md,
        padding: const EdgeInsets.all(AppSpacing.xs),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                category.name,
                style: AppTextStyles.categoryName,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              alignment: WrapAlignment.center,
              children: [
                // The mockup's level glyph is three ascending bars.
                _Badge(
                  icon: Icons.signal_cellular_alt,
                  text: 'Level ${category.level.number}',
                ),
                _Badge(
                  icon: Icons.timer,
                  text: formatSeconds(category.avgAnswerSeconds),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The Level / time badge recipe (theme-tokens.md §6): `background` fill,
/// radius `xs`, `badgeHeight` tall (taller only for large fonts), a small
/// glyph and the `badge` style.
class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.badgeHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.xsAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXs, color: AppColors.ink),
          const SizedBox(width: AppSpacing.xxs),
          Text(text, style: AppTextStyles.badge),
        ],
      ),
    );
  }
}
