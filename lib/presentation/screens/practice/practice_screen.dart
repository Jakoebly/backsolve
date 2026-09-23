import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_routes.dart';
import '../../providers/category_providers.dart';
import '../../providers/session_preset_provider.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_card.dart';
import '../../widgets/coming_soon_sheet.dart';
import '../../widgets/custom_session_row.dart';
import '../../widgets/quick_start_card.dart';
import '../../widgets/section_label.dart';
import '../../widgets/settings_chip.dart';

/// Practice (`docs/mockups_screens/practice.png`, FR-012, FR-015–FR-018):
/// the title, the QUICK START section — the Mixed session and Weak spots
/// cards — and the CATEGORIES section — the Custom session row followed by
/// the two-column grid of every stored category in display order. Each
/// entry opens Session Setup through the route table (FR-018).
///
/// Unlike Home this screen **scrolls**, and its tiles always keep the sizes
/// measured from the mockup. Fitting everything at once was built and then
/// dropped (user decision, 2026-09-23): at those sizes Practice needs
/// ~848 dp, about 126 dp more than a Galaxy S23 leaves, so compressing the
/// tiles to fit made them visibly smaller on every phone and *still*
/// scrolled on most. Practice is also the one screen whose content grows —
/// a ninth category adds a whole row (Constitution III) — so a fixed fit
/// could not survive one anyway. The list scrolls under the floating bottom
/// bar, which carries an opaque strip so nothing shows through behind it.
///
/// The grid is built as rows of two so each row takes its cards' height
/// (at least the mockup's) instead of a fixed cell that large fonts would
/// overflow.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

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
            // Clear the floating bar and its bottom margin, plus the same
            // gap the grid rows have between them, so the last row never
            // sits flush against the bar.
            AppSizes.navBarHeight + AppSpacing.md + AppSpacing.sm,
          ),
          children: [
            const Text('Practice', style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.sm),
            const SectionLabel('Quick start'),
            // practice.png: the shuffle glyph on teal, the bullseye on white.
            const _QuickStart(
              kind: PresetKind.all,
              overline: 'Mixed session',
              overlineIcon: Icons.shuffle,
              title: 'All categories',
              teal: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _QuickStart(
              kind: PresetKind.weakest,
              overline: 'Weak spots',
              overlineIcon: Icons.adjust,
              title: 'Weakest categories',
              teal: false,
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionLabel('Categories'),
            CustomSessionRow(
              onTap: () => openSessionSetup(context, {
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
                      onTap: () => openSessionSetup(context, {
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

/// Opens Session Setup for [params] (FR-018, contracts/routes.md).
void openSessionSetup(BuildContext context, Map<String, String> params) {
  context.pushNamed(AppRoutes.sessionSetup, queryParameters: params);
}

/// One quick start card (FR-012–FR-014): the play control starts a session
/// with the preset's defaults straight away, the settings chip opens
/// Session Setup for the same preset instead.
///
/// While the preset is loading the card keeps its shape — an empty chip and
/// an inert play control — rather than replacing the section with a spinner
/// (SC-001).
class _QuickStart extends ConsumerWidget {
  const _QuickStart({
    required this.kind,
    required this.overline,
    required this.overlineIcon,
    required this.title,
    required this.teal,
  });

  final PresetKind kind;
  final String overline;
  final IconData overlineIcon;
  final String title;
  final bool teal;

  /// Persists the session, then shows the placeholder; dismissing it leaves
  /// the user on Practice (FR-014, FR-025).
  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    SessionPreset preset,
  ) async {
    await ref.read(quickStartProvider).start(preset);
    if (context.mounted) await showComingSoon(context, 'Question answering');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref
        .watch(sessionPresetProvider((kind: kind, categoryId: null)))
        .value;
    final config = preset?.defaultConfig;

    return QuickStartCard(
      overline: overline,
      overlineIcon: overlineIcon,
      title: title,
      teal: teal,
      chip: SettingsChip(
        label: config == null ? '' : settingsChip(config),
        onTeal: teal,
        onTap: () =>
            openSessionSetup(context, {SessionSetupParams.mode: kind.name}),
      ),
      playSize: AppSizes.playCircleSm,
      onPlay: preset == null || config == null
          ? null
          : () => _start(context, ref, preset),
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
