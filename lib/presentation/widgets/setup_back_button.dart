import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The Session Setup back control (session_setup.png, FR-004; theme-tokens.md
/// §6 "Back button"): a `backButton` square with radius `sm` holding a small
/// `chevron_left` in `primary`.
class SetupBackButton extends StatelessWidget {
  const SetupBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: AppColors.backButton,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: onTap,
          child: const SizedBox(
            width: AppSizes.backButton,
            height: AppSizes.backButton,
            child: Icon(
              Icons.chevron_left,
              // The mockup's chevron is a small glyph, ≈ 6 dp tall.
              size: AppSizes.iconSm,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
