import 'package:backsolve/app.dart';
import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/seed/seeder.dart';
import 'package:backsolve/presentation/navigation/app_router.dart';
import 'package:backsolve/presentation/navigation/app_routes.dart';
import 'package:backsolve/presentation/providers/database_providers.dart';
import 'package:backsolve/presentation/screens/session_setup/session_setup_screen.dart';
import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:backsolve/presentation/widgets/category_card.dart';
import 'package:backsolve/presentation/widgets/custom_session_row.dart';
import 'package:backsolve/data/repositories/session_repository.dart';
import 'package:backsolve/presentation/widgets/settings_chip.dart';
import 'package:backsolve/presentation/widgets/setup_back_button.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Practice on a seeded in-memory database (US2). The expected badges are
/// the category rows of `lib/data/seed/seed_data.dart`.
void main() {
  late AppDatabase db;
  final now = DateTime(2026, 9, 16, 15, 30);

  /// Name, seeded level and seeded average time, in FR-017 order.
  const expectedCards = [
    ('Percentages', 'Level 5', '3.8s'),
    ('Multiplication', 'Level 4', '4.9s'),
    ('Division & Ratios', 'Level 3', '6.2s'),
    ('Fractions to %', 'Level 4', '5.5s'),
    ('Growth & CAGR', 'Level 2', '9.1s'),
    ('Margins & Breakeven', 'Level 3', '6.8s'),
    ('Big Numbers', 'Level 4', '4.4s'),
    ('Estimation', 'Level 3', '7.4s'),
  ];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await Seeder(db, now: () => now).seedIfEmpty();
  });

  tearDown(() => db.close());

  /// Pumps the app, switches to Practice, runs [body], then returns the
  /// shared router to Home and disposes the tree with one more pump so
  /// drift's stream-cleanup timer fires inside the test zone.
  Future<void> onPractice(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
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
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    try {
      await body();
    } finally {
      appRouter.go(AppRoutes.homePath);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      // A duration is needed: a plain pump() only flushes microtasks and
      // would leave the zero-duration cleanup timers queued.
      await tester.pump(const Duration(milliseconds: 1));
    }
  }

  /// The one active pill of the bottom bar.
  final activePill = find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).color == AppColors.navActivePill,
  );

  testWidgets('shows the title and the CATEGORIES section as in practice.png '
      '(FR-012, FR-015, US2 scenarios 1–2)', (tester) async {
    await onPractice(tester, () async {
      expect(find.text('Practice'), findsNWidgets(2), reason: 'title + tab');
      expect(
        find.descendant(of: activePill, matching: find.text('Practice')),
        findsOneWidget,
        reason: 'Practice tab highlighted',
      );
      expect(find.text('Backsolve'), findsNothing);

      expect(find.text('CATEGORIES'), findsOneWidget);
      expect(find.byType(CustomSessionRow), findsOneWidget);
      expect(find.text('Custom session'), findsOneWidget);
      expect(find.text('Pick the categories to include'), findsOneWidget);
      expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);
      // Scoped to the row: the quick start chips carry a chevron too.
      expect(
        find.descendant(
          of: find.byType(CustomSessionRow),
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsOneWidget,
      );

      // The row comes before the grid.
      final row = tester.getRect(find.byType(CustomSessionRow));
      final firstCard = tester.getRect(find.byType(CategoryCard).first);
      expect(firstCard.top, greaterThan(row.bottom));
    });
  });

  testWidgets('lists the eight seeded categories in spec order with their '
      'level and time badges (FR-016, FR-017, SC-005)', (tester) async {
    await onPractice(tester, () async {
      final cards = tester
          .widgetList<CategoryCard>(find.byType(CategoryCard))
          .toList();
      expect(cards.map((card) => card.category.name), [
        for (final (name, _, _) in expectedCards) name,
      ]);

      for (final (name, level, time) in expectedCards) {
        final card = find.widgetWithText(CategoryCard, name);
        expect(card, findsOneWidget, reason: name);
        expect(
          find.descendant(of: card, matching: find.text(level)),
          findsOneWidget,
          reason: '$name level badge',
        );
        expect(
          find.descendant(of: card, matching: find.text(time)),
          findsOneWidget,
          reason: '$name time badge',
        );
      }
      expect(find.byIcon(Icons.signal_cellular_alt), findsNWidgets(8));
      expect(find.byIcon(Icons.timer), findsNWidgets(8));

      // Two columns: the first two cards share a row, the third starts the
      // next one.
      final rects = [
        for (final card in find.byType(CategoryCard).evaluate())
          tester.getRect(find.byWidget(card.widget)),
      ];
      expect(rects[0].top, rects[1].top);
      expect(rects[1].left, greaterThan(rects[0].right));
      expect(rects[2].top, greaterThan(rects[0].bottom));
      expect(rects[2].left, rects[0].left);
      expect(tester.takeException(), isNull, reason: 'no overflow');
    });
  });

  testWidgets('the tiles are as tall as their tokens say (AppSizes)', (
    tester,
  ) async {
    await onPractice(tester, () async {
      expect(
        tester.getSize(find.byType(CustomSessionRow)).height,
        greaterThanOrEqualTo(AppSizes.customSessionRowHeight),
      );
      for (var i = 0; i < 8; i++) {
        expect(
          tester.getSize(find.byType(CategoryCard).at(i)).height,
          greaterThanOrEqualTo(AppSizes.categoryCardHeight),
          reason: 'card $i',
        );
      }
    });
  });

  testWidgets('the last row keeps a gap above the floating bar, however far '
      'the list is scrolled (user request, 2026-09-23)', (tester) async {
    await onPractice(tester, () async {
      final navBar = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppColors.surface &&
            decoration.borderRadius == AppRadius.lgAll &&
            decoration.border != null;
      });
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(
        tester.getRect(navBar).top -
            tester.getRect(find.byType(CategoryCard).last).bottom,
        AppSpacing.sm,
      );
    });
  });

  testWidgets('the whole quick start card starts a session, while its chip '
      'opens Session Setup instead (user request, 2026-09-24)', (tester) async {
    await onPractice(tester, () async {
      Future<int> sessions() async =>
          (await tester.runAsync(() => SessionRepository(db).countAll()))!;
      final before = await sessions();

      // Anywhere on the card except the chip starts the session.
      await tester.tap(find.text('All categories'));
      await tester.pumpAndSettle();
      expect(find.text('Question answering is coming soon'), findsOneWidget);
      expect(await sessions(), before + 1);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // The chip sits deeper in the tree, so it wins its own taps: it is
      // added to the gesture arena first and takes the sweep.
      await tester.tap(find.byType(SettingsChip).first);
      await tester.pumpAndSettle();
      expect(find.text('SESSION TYPE'), findsOneWidget);
      expect(
        await sessions(),
        before + 1,
        reason: 'the chip must not start a session',
      );
    });
  });

  testWidgets('long names stay on one line inside the card (edge case '
      '"long category names")', (tester) async {
    await onPractice(tester, () async {
      for (final name in ['Margins & Breakeven', 'Division & Ratios']) {
        final text = find.text(name);
        final textRect = tester.getRect(text);
        final cardRect = tester.getRect(find.widgetWithText(CategoryCard, name));
        expect(textRect.left, greaterThanOrEqualTo(cardRect.left));
        expect(textRect.right, lessThanOrEqualTo(cardRect.right));
        final painter = tester.renderObject<RenderParagraph>(text);
        expect(painter.didExceedMaxLines, isFalse, reason: name);
      }
    });
  });

  testWidgets('a category card opens Session Setup titled with that '
      'category; back returns (FR-018, FR-004, US2 scenarios 5–6)', (
    tester,
  ) async {
    await onPractice(tester, () async {
      await tester.tap(find.text('Margins & Breakeven'));
      await tester.pumpAndSettle();
      expect(find.byType(SessionSetupScreen), findsOneWidget);
      expect(find.text('Margins & Breakeven'), findsOneWidget);
      expect(find.text('CATEGORIES'), findsNothing);
      expect(find.text('SESSION TYPE'), findsOneWidget);

      await tester.tap(find.byType(SetupBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(SessionSetupScreen), findsNothing);
      expect(find.text('CATEGORIES'), findsOneWidget);
      expect(find.byType(CategoryCard), findsNWidgets(8));
    });
  });

  testWidgets('the Custom session row opens Session Setup in custom mode '
      '(FR-018)', (tester) async {
    await onPractice(tester, () async {
      await tester.tap(find.byType(CustomSessionRow));
      await tester.pumpAndSettle();
      expect(find.byType(SessionSetupScreen), findsOneWidget);
      expect(find.text('Custom session'), findsOneWidget);
      expect(find.text('Pick the categories to include'), findsNothing);
      expect(appRouter.state.uri.queryParameters, {
        SessionSetupParams.mode: 'custom',
      });
    });
  });
}
