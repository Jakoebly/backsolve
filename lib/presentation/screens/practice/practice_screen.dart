import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Stub until US2 (T075) replaces it with the full Practice screen.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('Practice', style: AppTextStyles.screenTitle),
        ),
      ),
    );
  }
}
