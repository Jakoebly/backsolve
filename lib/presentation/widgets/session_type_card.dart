import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// One SESSION TYPE option of session_setup.png (FR-021): title over
/// subtitle with the radio at the trailing edge; the selected card carries
/// the 2 dp `primary` border (theme-tokens.md §6 "Selected session-type
/// card" / "Radio").
class SessionTypeCard extends StatelessWidget {
  const SessionTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: AppCard(
        radius: AppRadius.md,
        selected: selected,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.optionTitle),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle, style: AppTextStyles.subtitle),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// Ø `radio`: a 2 dp `radioRing` ring, or a solid `primary` disc when
/// selected (the mockup shows no centre dot).
class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.radio,
      height: AppSizes.radio,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : null,
        border: selected
            ? null
            : Border.all(color: AppColors.radioRing, width: AppSizes.radioRing),
      ),
    );
  }
}
