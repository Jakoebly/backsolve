import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_routes.dart';
import '../../providers/category_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_card.dart';
import '../../widgets/custom_session_row.dart';
import '../../widgets/section_label.dart';

/// Practice (`docs/mockups_screens/practice.png`, FR-012, FR-015–FR-018):
/// the title and the CATEGORIES section — the Custom session row followed
/// by the two-column grid of every stored category in display order. Each
/// entry opens Session Setup through the route table (FR-018). The list
/// scrolls under the floating bottom bar.
///
/// The grid is built as rows of two so each row takes its cards' height
/// (at least the mockup's) instead of a fixed cell that large fonts would
/// overflow.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  void _openSetup(BuildContext context, Map<String, String> params) {
    context.pushNamed(AppRoutes.sessionSetup, queryParameters: params);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Loading or unavailable: the same layout with an empty grid (SC-001).
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            // Clear the floating bar, its bottom margin, and a card gap.
            AppSizes.navBarHeight + AppSpacing.md + AppSpacing.sm,
          ),
          children: [
            const Text('Practice', style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.sm),
            // QUICK START section inserted in T089
            const SectionLabel('Categories'),
            CustomSessionRow(
              onTap: () => _openSetup(context, {
                SessionSetupParams.mode: PresetKind.custom.name,
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var row = 0; row < categories.length; row += 2) ...[
              if (row > 0) const SizedBox(height: AppSpacing.sm),
              _GridRow(
                children: [
                  for (final category in categories.skip(row).take(2))
                    CategoryCard(
                      category: category,
                      onTap: () => _openSetup(context, {
                        SessionSetupParams.mode: PresetKind.category.name,
                        SessionSetupParams.category: category.id,
                      }),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One row of the two-column grid: equal widths, the row's height shared by
/// both cards; a lone last card keeps its column width.
class _GridRow extends StatelessWidget {
  const _GridRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: child),
          ],
          if (children.length == 1) ...[
            const SizedBox(width: AppSpacing.sm),
            const Expanded(child: SizedBox.shrink()),
          ],
        ],
      ),
    );
  }
}
