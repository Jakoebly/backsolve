import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'primary_button.dart';

/// The "coming soon" placeholder for Progress (FR-003) and for starting a
/// session (FR-025): a modal bottom sheet that returns to the same screen
/// when dismissed (contracts/routes.md "Placeholders").
Future<void> showComingSoon(BuildContext context, String feature) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgTop),
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$feature is coming soon', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              'It is not part of this version of Backsolve yet.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Got it',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
