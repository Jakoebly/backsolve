import 'package:backsolve/app.dart';
import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/seed/seeder.dart';
import 'package:backsolve/presentation/providers/database_providers.dart';
import 'package:backsolve/presentation/screens/shell/app_shell.dart';
import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:backsolve/presentation/widgets/quick_start_card.dart';
import 'package:backsolve/presentation/widgets/sessions_block.dart';
import 'package:backsolve/presentation/widgets/stat_tile.dart';
import 'package:backsolve/presentation/widgets/weekly_chart.dart';
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Home on a seeded in-memory database at a fixed clock. The expected
/// numbers are recomputed by hand from `lib/data/seed/seed_data.dart` with
/// FR-033–FR-035 (SC-007):
///
/// Install Wednesday 2026-09-16 15:30 → W8 = Mon 14 … Sun 20.
/// - W8 holds the streak rows daysAgo 2, 1, 0 (84 %, 85 %, 86 %; 5.5, 5.4,
///   5.3 s) → 85 % / 5.4 s.
/// - W7 (Sep 7–13) holds the five weekOffset-1 baseline rows (77, 77, 78,
///   79, 79 %; 6.4 … 6.0 s) plus the streak rows daysAgo 3–6 (83, 82, 81,
///   80 %; 5.6 … 5.9 s) → 716/9 = 79.6 → 80 % and 54.0/9 = 6.0 s.
/// - Deltas: +5 percentage points, −0.6 s. Sessions this week 3, all time
///   42, streak 7 (Sep 10–16). Mean level 3.5 → L4.
void main() {
  late AppDatabase db;
  final now = DateTime(2026, 9, 16, 15, 30);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await Seeder(db, now: () => now).seedIfEmpty();
  });

  tearDown(() => db.close());

  /// Pumps the app on Home, runs [body], then disposes the tree and pumps
  /// once more so drift's stream-cleanup timer fires inside the test zone
  /// (otherwise the binding reports a pending timer after disposal).
  Future<void> onHome(
    WidgetTester tester,
    Future<void> Function() body, {
    Size size = const Size(360, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const BacksolveApp(),
      ),
    );
    await tester.pumpAndSettle();
    try {
      await body();
    } finally {
      await tester.pumpWidget(const SizedBox());
      // A duration is needed: a plain pump() only flushes microtasks and
      // would leave the zero-duration cleanup timers queued.
      await tester.pump(const Duration(milliseconds: 1));
    }
  }

  testWidgets('the whole quick start card starts a session, not just the '
      'play control (user request, 2026-09-24)', (tester) async {
    await onHome(tester, () async {
      // The title, well clear of the play circle.
      await tester.tap(find.text('Mixed session'));
      await tester.pumpAndSettle();
      // The placeholder only opens once the session has been persisted.
      expect(find.text('Question answering is coming soon'), findsOneWidget);
    });
  });

  testWidgets('renders every element of home.png (FR-006, FR-007, FR-010, '
      'FR-011)', (tester) async {
    await onHome(tester, () async {
      expect(find.text('Backsolve'), findsOneWidget);
      expect(find.text('Mental math for case interviews'), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

      expect(find.text('LAST 8 WEEKS'), findsOneWidget);
      expect(find.byType(WeeklyChart), findsOneWidget);
      for (var w = 1; w <= 8; w++) {
        expect(find.text('W$w'), findsOneWidget, reason: 'week label W$w');
      }
      expect(find.text('Accuracy'), findsOneWidget, reason: 'legend');
      expect(find.text('Speed'), findsOneWidget, reason: 'legend');

      expect(find.text('ACCURACY'), findsOneWidget);
      expect(find.text('SPEED'), findsOneWidget);
      expect(find.byType(StatTile), findsNWidgets(2));

      expect(find.text('SESSIONS'), findsOneWidget);
      expect(find.text('this week'), findsOneWidget);
      expect(find.text('all time'), findsOneWidget);
      expect(find.text('days streak'), findsOneWidget);

      expect(find.text('QUICK START'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.text('Mixed session'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Bottom bar with Home active.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
    });
  });

  testWidgets('shows the hand-computed seed statistics (SC-007)', (
    tester,
  ) async {
    await onHome(tester, () async {
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('+5 this week'), findsOneWidget);
      expect(find.text('5.4s'), findsOneWidget);
      expect(find.text('−0.6s this week'), findsOneWidget);

      expect(find.text('3'), findsOneWidget, reason: 'sessions this week');
      expect(find.text('42'), findsOneWidget, reason: 'sessions all time');
      expect(find.text('7'), findsOneWidget, reason: 'days streak');

      expect(find.text('60 seconds · adaptive · L4'), findsOneWidget);
    });
  });

  testWidgets('has no empty state or placeholder text (SC-001)', (
    tester,
  ) async {
    await onHome(tester, () async {
      for (final placeholder in ['Loading', 'No data', '—', '…', 'null']) {
        expect(find.textContaining(placeholder), findsNothing);
      }
      // Every Text on screen has content once the data has loaded.
      final texts = tester.widgetList<Text>(find.byType(Text));
      expect(texts.where((t) => (t.data ?? '').isEmpty), isEmpty);
    });
  });

  group('drag feels like a scroll even though nothing scrolls', () {
    testWidgets('the platform overscroll indicator is in place (the Material '
        '3 stretch on Android)', (tester) async {
      await onHome(tester, () async {
        expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
      });
    });

    testWidgets('a drag is accepted and reported as overscroll, and the '
        'content is back in place afterwards', (tester) async {
      final overscrolls = <double>[];
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => now),
          ],
          child: NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              overscrolls.add(notification.overscroll);
              return false;
            },
            child: const BacksolveApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = tester.getRect(find.text('Backsolve'));

      // Drag down (content pulled past the top) and back up.
      await tester.drag(find.byType(Scrollable), const Offset(0, 120));
      await tester.pumpAndSettle();
      expect(overscrolls.any((value) => value < 0), isTrue, reason: 'leading');
      expect(tester.getRect(find.text('Backsolve')), before);

      overscrolls.clear();
      await tester.drag(find.byType(Scrollable), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(overscrolls.any((value) => value > 0), isTrue, reason: 'trailing');
      expect(tester.getRect(find.text('Backsolve')), before);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
    });
  });

  group('fixed, non-scrolling layout', () {
    /// How far the screen can scroll; 0 means everything fits.
    double scrollExtent(WidgetTester tester) => tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position
        .maxScrollExtent;

    /// The top edge of the floating bar (the last card must clear it).
    double barTop(WidgetTester tester) =>
        tester.getRect(find.byType(AppShell)).bottom -
        AppSpacing.md -
        AppSizes.navBarHeight;

    double chartHeight(WidgetTester tester) =>
        tester.getSize(find.byType(WeeklyChart)).height;

    /// The five gaps that share any surplus height, top to bottom.
    List<double> gaps(WidgetTester tester) {
      final header = tester.getRect(find.text('Backsolve'));
      final chart = tester.getRect(find.byType(WeeklyChart));
      final tiles = tester.getRect(find.byType(StatTile).first);
      final sessions = tester.getRect(find.byType(SessionsBlock));
      final quick = tester.getRect(find.byType(QuickStartCard));
      return [
        chart.top - header.top, // header top → chart (header height + gap)
        tiles.top - chart.bottom,
        sessions.top - tiles.bottom,
        quick.top - sessions.bottom,
        barTop(tester) - quick.bottom,
      ];
    }

    void expectFits(WidgetTester tester) {
      expect(scrollExtent(tester), 0);
      final quickStart = tester.getRect(find.byType(QuickStartCard));
      expect(quickStart.bottom, lessThanOrEqualTo(barTop(tester)));
      expect(tester.takeException(), isNull, reason: 'no overflow');
    }

    testWidgets('never scrolls on a phone: every block is fully visible', (
      tester,
    ) async {
      await onHome(tester, () async {
        expectFits(tester);
        for (final gap in gaps(tester).skip(1)) {
          expect(gap, greaterThanOrEqualTo(AppSpacing.sm));
        }
      });
    });

    testWidgets('extra height goes to the chart until its cap, then to the '
        'five gaps evenly', (tester) async {
      late double chartAt800;
      late List<double> gapsAt800;
      await onHome(tester, () async {
        chartAt800 = chartHeight(tester);
        gapsAt800 = gaps(tester);
        expectFits(tester);
      });
      await onHome(tester, () async {
        expectFits(tester);
        final chartGrowth = chartHeight(tester) - chartAt800;
        final gapGrowth = [
          for (final (i, gap) in gaps(tester).indexed) gap - gapsAt800[i],
        ];
        expect(chartGrowth, greaterThanOrEqualTo(0));
        for (final growth in gapGrowth) {
          expect(growth, greaterThanOrEqualTo(0));
          expect(growth, closeTo(gapGrowth.first, 0.5), reason: 'even split');
        }
        expect(chartGrowth + 5 * gapGrowth.first, closeTo(150, 0.5));
      }, size: const Size(360, 950));
    });

    testWidgets('beyond the cap only the gaps grow', (tester) async {
      late double chartAt1200;
      late List<double> gapsAt1200;
      await onHome(tester, () async {
        chartAt1200 = chartHeight(tester);
        gapsAt1200 = gaps(tester);
        expectFits(tester);
      }, size: const Size(360, 1200));
      await onHome(tester, () async {
        expectFits(tester);
        expect(chartHeight(tester), chartAt1200, reason: 'chart is capped');
        for (final (i, gap) in gaps(tester).indexed) {
          expect(gap - gapsAt1200[i], closeTo(200 / 5, 0.5));
        }
        // The plot itself is exactly the mockup's height at the cap.
        final plotBox = tester.getSize(find.byType(BarChart));
        expect(
          plotBox.height,
          AppSizes.chartPlotMaxHeight + AppSizes.chartLabelReserve,
        );
      }, size: const Size(360, 1400));
    });

    testWidgets('a shorter phone shrinks the chart before anything else', (
      tester,
    ) async {
      late double chartAt800;
      late List<double> gapsAt800;
      late double chartMin;
      await onHome(tester, () async {
        chartAt800 = chartHeight(tester);
        gapsAt800 = gaps(tester);
      });
      // Far too short to fit: the chart sits at its minimum height.
      await onHome(tester, () async {
        chartMin = chartHeight(tester);
      }, size: const Size(360, 400));
      expect(chartAt800, greaterThan(chartMin));

      // Take away half of the chart's slack: everything still fits, and
      // the removed height came out of the chart (and, only once the gaps
      // had surplus to give, out of the gaps).
      final shrink = ((chartAt800 - chartMin) / 2).floorToDouble();
      await onHome(tester, () async {
        expectFits(tester);
        final chartLoss = chartAt800 - chartHeight(tester);
        final gapLoss = [
          for (final (i, gap) in gaps(tester).indexed) gapsAt800[i] - gap,
        ];
        expect(chartLoss, greaterThan(0));
        expect(chartLoss + 5 * gapLoss.first, closeTo(shrink, 0.5));
        for (final gap in gaps(tester).skip(1)) {
          expect(gap, greaterThanOrEqualTo(AppSpacing.sm));
        }
      }, size: Size(360, 800 - shrink));
    });

    testWidgets('only scrolls once the plot would drop below its minimum', (
      tester,
    ) async {
      await onHome(tester, () async {
        expect(scrollExtent(tester), greaterThan(0));
        expect(tester.takeException(), isNull, reason: 'no overflow');
        final plotBox = tester.getSize(find.byType(BarChart));
        expect(
          plotBox.height,
          AppSizes.chartPlotMinHeight + AppSizes.chartLabelReserve,
        );
        // Everything is still reachable by scrolling.
        await tester.drag(find.byType(Scrollable), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text('Mixed session'), findsOneWidget);
      }, size: const Size(360, 480));
    });
  });
}
