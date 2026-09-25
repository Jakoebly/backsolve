import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'section_label.dart';

/// The SESSIONS block of home.png (FR-010): three equal columns separated
/// by 1 dp `border` dividers.
class SessionsBlock extends StatelessWidget {
  const SessionsBlock({
    super.key,
    required this.thisWeek,
    required this.allTime,
    required this.dayStreak,
  });

  final int thisWeek;
  final int allTime;
  final int dayStreak;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Sessions'),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Counter(value: thisWeek, label: 'this week'),
                const _Divider(),
                _Counter(value: allTime, label: 'all time'),
                const _Divider(),
                _Counter(value: dayStreak, label: 'days streak'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$value', style: AppTextStyles.statValue),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(
      width: AppSizes.cardBorderWidth,
      thickness: AppSizes.cardBorderWidth,
      color: AppColors.border,
    );
  }
}
