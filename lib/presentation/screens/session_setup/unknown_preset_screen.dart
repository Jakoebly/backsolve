import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/setup_back_button.dart';

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
                  SetupBackButton(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.goNamed(AppRoutes.home),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Unknown session preset',
                      style: AppTextStyles.pageTitle,
                    ),
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
