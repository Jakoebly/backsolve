import 'package:backsolve/app.dart';
import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/repositories/session_repository.dart';
import 'package:backsolve/data/seed/seeder.dart';
import 'package:backsolve/presentation/navigation/app_router.dart';
import 'package:backsolve/presentation/navigation/app_routes.dart';
import 'package:backsolve/presentation/providers/database_providers.dart';
import 'package:backsolve/presentation/screens/session_setup/session_setup_screen.dart';
import 'package:backsolve/presentation/widgets/primary_button.dart';
import 'package:backsolve/presentation/widgets/segmented_control.dart';
import 'package:backsolve/presentation/widgets/session_type_card.dart';
import 'package:backsolve/presentation/widgets/setup_back_button.dart';
import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Session Setup on a seeded in-memory database (US2 title, US3). Seeded
/// levels: Margins & Breakeven L3; all eight categories average 3.5 → L4.
void main() {
  late AppDatabase db;
  final now = DateTime(2026, 9, 16, 15, 30);

  const marginsKey = {
    SessionSetupParams.mode: 'category',
    SessionSetupParams.category: 'margins_breakeven',
  };
  const adaptiveL3 = 'Starts at L3, Fast/right moves up, wrong moves down.';
  const adaptiveL4 = 'Starts at L4, Fast/right moves up, wrong moves down.';
  const estimationHelper =
      'Answers must match within ±2% of the actual answer.';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await Seeder(db, now: () => now).seedIfEmpty();
  });

  tearDown(() => db.close());

  /// Pumps the app and pushes Session Setup with [query], runs [body], then
  /// returns the shared router to Home and disposes the tree with one more
  /// pump so drift's stream-cleanup timer fires inside the test zone.
  Future<void> onSetup(
    WidgetTester tester,
    Map<String, String> query,
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
    appRouter.pushNamed(AppRoutes.sessionSetup, queryParameters: query);
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

  bool isSelected(WidgetTester tester, String title) => tester
      .widget<SessionTypeCard>(find.widgetWithText(SessionTypeCard, title))
      .selected;

  DifficultyLevel? selectedDifficulty(WidgetTester tester) => tester
      .widget<SegmentedControl<DifficultyLevel?>>(
        find.byType(SegmentedControl<DifficultyLevel?>),
      )
      .selected;

  AnswerMode selectedAnswerMode(WidgetTester tester) => tester
      .widget<SegmentedControl<AnswerMode>>(
        find.byType(SegmentedControl<AnswerMode>),
      )
      .selected;

  VoidCallback? startCallback(WidgetTester tester) => tester
      .widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, 'Start Session'),
      )
      .onPressed;

  /// Direct database reads run outside the fake-async zone of the test.
  Future<int> sessionCount(WidgetTester tester) async =>
      (await tester.runAsync(() => SessionRepository(db).countAll()))!;

  Future<Session> newestSession(WidgetTester tester) async {
    final sessions = await tester.runAsync(
      () => SessionRepository(db).watchAll().first,
    );
    return sessions!.first;
  }

  testWidgets('opens for a category with every element of session_setup.png '
      'and the spec defaults (FR-019, FR-021–FR-023, US2 scenario 5)', (
    tester,
  ) async {
    await onSetup(tester, marginsKey, () async {
      expect(find.byType(SetupBackButton), findsOneWidget);
      expect(find.text('Margins & Breakeven'), findsOneWidget);

      expect(find.text('SESSION TYPE'), findsOneWidget);
      expect(find.text('Timed Session'), findsOneWidget);
      expect(find.text('60 seconds'), findsOneWidget);
      expect(find.text('Fixed Set'), findsOneWidget);
      expect(find.text('20 questions, no clock'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Practice until you stop'), findsOneWidget);
      expect(isSelected(tester, 'Timed Session'), isTrue);
      expect(isSelected(tester, 'Fixed Set'), isFalse);
      expect(isSelected(tester, 'Open'), isFalse);

      expect(find.text('DIFFICULTY'), findsOneWidget);
      for (final label in ['Adaptive', 'L1', 'L2', 'L3', 'L4', 'L5']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(selectedDifficulty(tester), isNull, reason: 'adaptive');
      expect(find.text(adaptiveL3), findsOneWidget);

      expect(find.text('ANSWERS'), findsOneWidget);
      expect(find.text('Exact'), findsOneWidget);
      expect(find.text('Estimation'), findsOneWidget);
      expect(selectedAnswerMode(tester), AnswerMode.exact);
      expect(find.text('Answers must match exactly.'), findsOneWidget);

      expect(find.text('Start Session'), findsOneWidget);
      expect(startCallback(tester), isNotNull, reason: 'Start enabled');
      expect(tester.takeException(), isNull, reason: 'no overflow');
    });
  });

  testWidgets('each choice updates its selection and helper line (US3 '
      'scenarios 1–4, quickstart step 6)', (tester) async {
    await onSetup(tester, marginsKey, () async {
      await tester.tap(find.text('Fixed Set'));
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'Fixed Set'), isTrue);
      expect(isSelected(tester, 'Timed Session'), isFalse);

      await tester.tap(find.text('L2'));
      await tester.pumpAndSettle();
      expect(selectedDifficulty(tester), DifficultyLevel.l2);
      expect(
        find.text('Every question is at L2. Never moves up or down.'),
        findsOneWidget,
      );
      expect(find.text(adaptiveL3), findsNothing);

      await tester.tap(find.text('Estimation'));
      await tester.pumpAndSettle();
      expect(selectedAnswerMode(tester), AnswerMode.estimation);
      expect(find.text(estimationHelper), findsOneWidget);
      expect(find.text('Answers must match exactly.'), findsNothing);

      await tester.tap(find.text('Adaptive'));
      await tester.pumpAndSettle();
      expect(selectedDifficulty(tester), isNull);
      expect(find.text(adaptiveL3), findsOneWidget);
    });
  });

  // The Difficulty helper's one-line rendering is checked with the real
  // Roboto in `helper_text_test.dart`: the font `flutter test` falls back
  // to is much wider than Roboto and wraps these lines where no device
  // does, so line counts cannot be asserted here.

  testWidgets('Start persists the chosen configuration, shows the placeholder, '
      'and dismissing it keeps the selections (FR-025, US3 scenarios 5–6)', (
    tester,
  ) async {
    await onSetup(tester, marginsKey, () async {
      final before = await sessionCount(tester);
      await tester.tap(find.text('Fixed Set'));
      await tester.tap(find.text('L2'));
      await tester.tap(find.text('Estimation'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Session'));
      await tester.pumpAndSettle();
      expect(find.text('Question answering is coming soon'), findsOneWidget);
      expect(await sessionCount(tester), before + 1);

      final session = await newestSession(tester);
      expect(session.startedAt, now);
      expect(session.endedAt, isNull);
      expect(session.result, isNull);
      expect(
        session.config,
        SessionConfig(
          type: SessionType.fixedSet,
          difficulty: const FixedDifficultySetting(DifficultyLevel.l2),
          answerMode: AnswerMode.estimation,
          categoryIds: const ['margins_breakeven'],
          presetKind: PresetKind.category,
        ),
      );

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('Question answering is coming soon'), findsNothing);
      expect(find.byType(SessionSetupScreen), findsOneWidget);
      expect(isSelected(tester, 'Fixed Set'), isTrue);
      expect(
        find.text('Every question is at L2. Never moves up or down.'),
        findsOneWidget,
      );
      expect(find.text(estimationHelper), findsOneWidget);
      expect(startCallback(tester), isNotNull, reason: 'usable again');
    });
  });

  testWidgets('the defaults persist an adaptive session starting at the '
      "category's level (FR-022, FR-025)", (tester) async {
    await onSetup(tester, marginsKey, () async {
      await tester.tap(find.text('Start Session'));
      await tester.pumpAndSettle();
      final session = await newestSession(tester);
      expect(session.config.type, SessionType.timed);
      expect(
        session.config.difficulty,
        const AdaptiveDifficultySetting(DifficultyLevel.l3),
      );
      expect(session.config.answerMode, AnswerMode.exact);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('selections survive a rotation but reset when the screen is '
      'reopened (FR-026)', (tester) async {
    await onSetup(tester, marginsKey, () async {
      await tester.tap(find.text('Open'));
      await tester.tap(find.text('L5'));
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(800, 360);
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'Open'), isTrue);
      expect(selectedDifficulty(tester), DifficultyLevel.l5);
      expect(tester.takeException(), isNull, reason: 'landscape overflow');
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SetupBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(SessionSetupScreen), findsNothing);

      appRouter.pushNamed(AppRoutes.sessionSetup, queryParameters: marginsKey);
      await tester.pumpAndSettle();
      expect(isSelected(tester, 'Timed Session'), isTrue);
      expect(isSelected(tester, 'Open'), isFalse);
      expect(selectedDifficulty(tester), isNull);
      expect(find.text(adaptiveL3), findsOneWidget);
    });
  });

  testWidgets('a mixed preset lists the categories covered and starts at the '
      'overall level (FR-019, FR-035, US4 scenario 4)', (tester) async {
    await onSetup(tester, {SessionSetupParams.mode: 'all'}, () async {
      expect(find.text('All categories'), findsOneWidget);
      expect(
        find.text(
          'Percentages · Multiplication · Division & Ratios · Fractions to % '
          '· Growth & CAGR · Margins & Breakeven · Big Numbers · Estimation',
        ),
        findsOneWidget,
      );
      expect(find.text(adaptiveL4), findsOneWidget);

      await tester.tap(find.text('Start Session'));
      await tester.pumpAndSettle();
      final session = await newestSession(tester);
      expect(session.config.presetKind, PresetKind.all);
      expect(session.config.categoryIds, [
        for (final definition in categoryRegistry) definition.id,
      ]);
      expect(
        session.config.difficulty,
        const AdaptiveDifficultySetting(DifficultyLevel.l4),
      );
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('custom mode opens with no categories: Start is disabled and '
      'the helper shows the overall level (FR-020, edge case)', (tester) async {
    await onSetup(tester, {SessionSetupParams.mode: 'custom'}, () async {
      expect(find.text('Custom session'), findsOneWidget);
      expect(find.textContaining(' · '), findsNothing, reason: 'no names');
      expect(startCallback(tester), isNull, reason: 'Start disabled');
      expect(find.text(adaptiveL4), findsOneWidget);
    });
  });

  testWidgets('an unknown category shows the Unknown preset page instead of '
      'crashing (contracts/routes.md)', (tester) async {
    await onSetup(
      tester,
      {SessionSetupParams.mode: 'category', SessionSetupParams.category: 'x'},
      () async {
        expect(find.text('Unknown session preset'), findsOneWidget);
        expect(find.text('SESSION TYPE'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
