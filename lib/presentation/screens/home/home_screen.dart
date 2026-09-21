import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Stub until US1 (T070) replaces it with the full Home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('Backsolve', style: AppTextStyles.screenTitle),
        ),
      ),
    );
  }
}
