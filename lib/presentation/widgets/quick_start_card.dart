import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'play_button.dart';
import 'section_label.dart';

/// A quick start card (FR-011, FR-012, theme-tokens.md §6): an optional
/// overline with its glyph ("⚡ QUICK START", "MIXED SESSION", "WEAK
/// SPOTS"), the title, either a summary line ([subtitle]) or a settings
/// [chip] under it, and the play control on the right.
///
/// Home passes `title: 'Mixed session'`, the `quickStartSummary(...)` line
/// and `playSize: AppSizes.playCircleLg`; the Practice variants pass an
/// overline, a chip and `AppSizes.playCircleSm`.
class QuickStartCard extends StatelessWidget {
  const QuickStartCard({
    super.key,
    this.overline,
    this.overlineIcon,
    required this.title,
    this.subtitle,
    this.chip,
    this.teal = true,
    required this.playSize,
    required this.onPlay,
  });

  final String? overline;
  final IconData? overlineIcon;
  final String title;
  final String? subtitle;
  final Widget? chip;

  /// `TealCard` when true, white `AppCard` (radius `lg`) otherwise.
  final bool teal;
  final double playSize;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final overline = this.overline;
    final subtitle = this.subtitle;
    final chip = this.chip;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null)
          SectionLabel(
            overline,
            icon: overlineIcon,
            color: teal ? AppColors.onPrimarySubtle : null,
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: teal
                        ? AppTextStyles.cardTitle.copyWith(
                            color: AppColors.onPrimary,
                          )
                        : AppTextStyles.cardTitle,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle, style: AppTextStyles.quickStartSummary),
                  ],
                  if (chip != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    chip,
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            PlayButton(size: playSize, onTeal: teal, onTap: onPlay),
          ],
        ),
      ],
    );
    return teal
        ? TealCard(child: content)
        : AppCard(radius: AppRadius.lg, child: content);
  }
}
