import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Stub until US2/US3 (T076, T081) replace it with the full Session Setup
/// screen. [kind] and [categoryId] come from the route's query parameters.
class SessionSetupScreen extends StatelessWidget {
  const SessionSetupScreen({super.key, required this.kind, this.categoryId});

  final PresetKind kind;
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            categoryId == null ? kind.name : '${kind.name} · $categoryId',
            style: AppTextStyles.pageTitle,
          ),
        ),
      ),
    );
  }
}
