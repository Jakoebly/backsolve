import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_routes.dart';
import '../../theme/app_theme.dart';

/// Shown by the router for invalid or missing Session Setup query parameters
/// and as the `errorBuilder` target (contracts/routes.md) — never a crash.
class UnknownPresetScreen extends StatelessWidget {
  const UnknownPresetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BackButton(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.goNamed(AppRoutes.home),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Unknown session preset',
                    style: AppTextStyles.pageTitle,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'This link does not point at a session that can be set up.',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Session Setup back control (theme-tokens.md §6 "Back button").
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
            size: AppSizes.iconNav,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
