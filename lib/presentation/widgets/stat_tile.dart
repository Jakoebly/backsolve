import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'section_label.dart';

/// The ACCURACY / SPEED tile of home.png (FR-008, FR-009): overline, value,
/// and the week-over-week delta — omitted when the previous week has no
/// data (spec edge case "previous week has no sessions").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final delta = this.delta;
    return AppCard(
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          Text(value, style: AppTextStyles.statValue),
          if (delta != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(delta, style: AppTextStyles.delta),
          ],
        ],
      ),
    );
  }
}
