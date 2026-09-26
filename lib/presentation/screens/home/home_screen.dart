import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/category_providers.dart';
import '../../providers/database_providers.dart';
import '../../providers/session_preset_provider.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/coming_soon_sheet.dart';
import '../../widgets/quick_start_card.dart';
import '../../widgets/sessions_block.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/weekly_chart.dart';

/// Home (`docs/mockups_screens/home.png`, FR-006–FR-011): header, the
/// LAST 8 WEEKS chart, the ACCURACY and SPEED tiles, the SESSIONS block and
/// the QUICK START card — every number derived from the stored data
/// (FR-032). While the stats are loading (one frame after a cold start) or
/// unavailable, the same layout renders with blank values (SC-001).
///
/// The screen never scrolls on a phone: every block keeps its natural
/// height and the chart absorbs whatever is left, up to the mockup's plot
/// height ([AppSizes.chartPlotMaxHeight]); beyond that the surplus widens
/// the five gaps between the blocks evenly. The column is sized to the
/// larger of the viewport and the blocks' measured height (with the chart
/// at its minimum plot, [AppSizes.chartPlotMinHeight]), so a scroll only
/// exists when the blocks cannot fit at all — landscape, split screen, very
/// large text.
///
/// A drag still *feels* like a scroll: [AlwaysScrollableScrollPhysics]
/// accepts the gesture even with nothing to scroll, and the platform
/// overscroll indicator (the Material 3 stretch on Android) stretches the
/// content and springs it back on release, exactly as on Practice.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider).value;
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final weeks =
        stats?.weeks ??
        WeeklySummary.lastEightWeeks(const [], ref.read(clockProvider)());

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Always accept the drag: with nothing to scroll the clamping
            // parent keeps the content in place and the overscroll
            // indicator does the stretching.
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  // The bar floats over the body: leave room for it and its
                  // bottom margin (the gap above it is the column's last
                  // spacing).
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSizes.navBarHeight + AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // Base gap between blocks; any surplus height left once
                    // the chart is capped is spread over the gaps.
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: AppSpacing.sm,
                    children: _blocks(stats, categories, weeks),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The screen's blocks top to bottom, separated by the column's spacing;
  /// the chart takes the remaining height of the bounded [Column] up to its
  /// cap. The trailing empty box gives the gap above the bar its share of
  /// any surplus too.
  List<Widget> _blocks(
    HomeStats? stats,
    List<Category> categories,
    List<WeeklySummary> weeks,
  ) {
    return [
      // Header → first card is lg in the mockup, sm more than the base gap.
      const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg - AppSpacing.sm),
        child: _Header(),
      ),
      Flexible(child: WeeklyChart(weeks: weeks, fillHeight: true)),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatTile(
                label: 'Accuracy',
                value: _accuracyValue(stats),
                delta: _accuracyDelta(stats),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: 'Speed',
                value: _speedValue(stats),
                delta: _speedDelta(stats),
              ),
            ),
          ],
        ),
      ),
      SessionsBlock(
        thisWeek: stats?.sessionsThisWeek ?? 0,
        allTime: stats?.sessionsAllTime ?? 0,
        dayStreak: stats?.dayStreak ?? 0,
      ),
      _MixedSessionCard(summary: _mixedSessionSummary(stats, categories)),
      const SizedBox.shrink(),
    ];
  }

  static String _accuracyValue(HomeStats? stats) {
    final accuracy = stats?.accuracy;
    return accuracy == null ? '' : formatAccuracy(accuracy);
  }

  static String? _accuracyDelta(HomeStats? stats) {
    final delta = stats?.accuracyDelta;
    return delta == null ? null : formatAccuracyDelta(delta);
  }

  static String _speedValue(HomeStats? stats) {
    final seconds = stats?.speedSeconds;
    return seconds == null ? '' : formatSeconds(seconds);
  }

  static String? _speedDelta(HomeStats? stats) {
    final delta = stats?.speedDelta;
    return delta == null ? null : formatSpeedDelta(delta);
  }

  /// "60 seconds · adaptive · L{N}" for a mixed session over every category
  /// at the current overall level (FR-011).
  static String _mixedSessionSummary(
    HomeStats? stats,
    List<Category> categories,
  ) {
    if (stats == null) return '';
    final categoryIds = [
      for (final category in categories) category.id,
      if (categories.isEmpty)
        for (final definition in categoryRegistry) definition.id,
    ];
    return quickStartSummary(
      SessionConfig.defaultsFor(
        categoryIds: categoryIds,
        startLevel: stats.overallLevel,
        presetKind: PresetKind.all,
      ),
    );
  }
}

/// The Home quick start card (home.png, FR-011): it carries "QUICK START"
/// as its own overline (with the bolt glyph) rather than as a label above
/// it, and its summary line is the stored overall level, so a session
/// started here is reflected on return (SC-003).
///
/// The play control starts a mixed session over every category with the
/// preset's defaults and then shows the placeholder; dismissing it leaves
/// the user on Home (FR-014, FR-025). It stays inert until the preset has
/// loaded, one frame after a cold start (SC-001).
class _MixedSessionCard extends ConsumerWidget {
  const _MixedSessionCard({required this.summary});

  /// "60 seconds · adaptive · L4".
  final String summary;

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
        .watch(
          sessionPresetProvider((kind: PresetKind.all, categoryId: null)),
        )
        .value;

    return QuickStartCard(
      overline: 'Quick start',
      overlineIcon: Icons.bolt_rounded,
      title: 'Mixed session',
      subtitle: summary,
      playSize: AppSizes.playCircleLg,
      onPlay: preset == null || preset.defaultConfig == null
          ? null
          : () => _start(context, ref, preset),
    );
  }
}

/// App icon, "Backsolve", and the tagline (FR-006).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppLogo(),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Backsolve', style: AppTextStyles.screenTitle),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Mental math for case interviews',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
