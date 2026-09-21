import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The full-width teal button (theme-tokens.md §6 "Start button"): `primary`
/// fill, radius `md`, height `startButtonHeight`, `button` text style; the
/// derived `primaryDisabled` fill when [onPressed] is `null`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.startButtonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryDisabled,
          foregroundColor: AppColors.onPrimary,
          disabledForegroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          padding: EdgeInsets.zero,
        ),
        child: Text(label),
      ),
    );
  }
}
