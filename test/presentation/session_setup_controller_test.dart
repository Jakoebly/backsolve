import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/repositories/session_repository.dart';
import 'package:backsolve/data/seed/seeder.dart';
import 'package:backsolve/presentation/providers/category_providers.dart';
import 'package:backsolve/presentation/providers/database_providers.dart';
import 'package:backsolve/presentation/providers/session_preset_provider.dart';
import 'package:backsolve/presentation/providers/session_setup_controller.dart';
import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The preset provider and the Session Setup controller against a seeded
/// in-memory database, without widgets. Seeded levels: Margins & Breakeven
/// L3, Growth & CAGR L2, Percentages L5; the eight average 3.5 → L4.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final now = DateTime(2026, 9, 16, 15, 30);

  const margins = (kind: PresetKind.category, categoryId: 'margins_breakeven');
  const all = (kind: PresetKind.all, categoryId: null);
  const custom = (kind: PresetKind.custom, categoryId: null);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await Seeder(db, now: () => now).seedIfEmpty();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    // The presets derive from the category stream. Riverpod 3 pauses a
    // provider nobody listens to, so keep a listener (as the screens do)
    // while waiting for the first value.
    container.listen(categoriesProvider, (_, _) {});
    await container.read(categoriesProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Keeps the auto-disposed controller alive for the test and returns it.
  SessionSetupController controllerFor(PresetKey key) {
    final subscription = container.listen(
      sessionSetupControllerProvider(key),
      (_, _) {},
    );
    addTearDown(subscription.close);
    return container.read(sessionSetupControllerProvider(key).notifier);
  }

  SessionSetupState stateOf(PresetKey key) =>
      container.read(sessionSetupControllerProvider(key));

  group('sessionPresetProvider (FR-019)', () {
    test('a category preset carries its name, id and level', () {
      final preset = container.read(sessionPresetProvider(margins)).requireValue;
      expect(preset.kind, PresetKind.category);
      expect(preset.title, 'Margins & Breakeven');
      expect(preset.categoryIds, ['margins_breakeven']);
      expect(
        preset.defaultConfig,
        SessionConfig.defaultsFor(
          categoryIds: const ['margins_breakeven'],
          startLevel: DifficultyLevel.l3,
          presetKind: PresetKind.category,
        ),
      );
    });

    test('the mixed preset covers every category in display order at the '
        'overall level (FR-035)', () {
      final preset = container.read(sessionPresetProvider(all)).requireValue;
      final ids = [for (final definition in categoryRegistry) definition.id];
      expect(preset.title, 'All categories');
      expect(preset.categoryIds, ids);
      expect(
        preset.defaultConfig,
        SessionConfig.defaultsFor(
          categoryIds: ids,
          startLevel: DifficultyLevel.l4,
          presetKind: PresetKind.all,
        ),
      );
    });

    test('the weakest preset is titled for FR-024 (category set narrowed in '
        'T087)', () {
      const key = (kind: PresetKind.weakest, categoryId: null);
      final preset = container.read(sessionPresetProvider(key)).requireValue;
      expect(preset.title, 'Weakest categories');
      expect(preset.kind, PresetKind.weakest);
      expect(preset.defaultConfig?.presetKind, PresetKind.weakest);
    });

    test('the custom preset has no categories and no default config', () {
      final preset = container.read(sessionPresetProvider(custom)).requireValue;
      expect(preset.title, 'Custom session');
      expect(preset.categoryIds, isEmpty);
      expect(preset.defaultConfig, isNull);
    });

    test('an unknown category id is an error value, not a throw', () {
      const key = (kind: PresetKind.category, categoryId: 'nope');
      final preset = container.read(sessionPresetProvider(key));
      expect(preset.hasError, isTrue);
      expect(preset.error, isA<ArgumentError>());
    });
  });

  group('SessionSetupController', () {
    test('starts from timed / adaptive / exact over the preset categories '
        '(spec Assumptions "Session Setup defaults")', () {
      final controller = controllerFor(margins);
      final state = stateOf(margins);
      expect(state.type, SessionType.timed);
      expect(state.fixedLevel, isNull);
      expect(state.isAdaptive, isTrue);
      expect(state.answerMode, AnswerMode.exact);
      expect(state.selectedCategoryIds, ['margins_breakeven']);
      expect(state.isStarting, isFalse);
      expect(controller.startLevel, DifficultyLevel.l3);
      expect(
        controller.difficultySetting,
        const AdaptiveDifficultySetting(DifficultyLevel.l3),
      );
      expect(controller.canStart, isTrue);
    });

    test('setters replace one selection at a time (FR-021–FR-023)', () {
      final controller = controllerFor(margins);

      controller.setType(SessionType.open);
      expect(stateOf(margins).type, SessionType.open);

      controller.setDifficulty(DifficultyLevel.l5);
      expect(stateOf(margins).fixedLevel, DifficultyLevel.l5);
      expect(
        controller.difficultySetting,
        const FixedDifficultySetting(DifficultyLevel.l5),
      );

      controller.setDifficulty(null);
      expect(stateOf(margins).fixedLevel, isNull, reason: 'back to adaptive');
      expect(
        controller.difficultySetting,
        const AdaptiveDifficultySetting(DifficultyLevel.l3),
      );

      controller.setAnswerMode(AnswerMode.estimation);
      final state = stateOf(margins);
      expect(state.answerMode, AnswerMode.estimation);
      expect(state.type, SessionType.open, reason: 'unchanged');
      expect(state.selectedCategoryIds, ['margins_breakeven']);
    });

    test('the mixed preset starts at the rounded mean level (FR-022)', () {
      final controller = controllerFor(all);
      expect(controller.startLevel, DifficultyLevel.l4);
    });

    test('custom mode: nothing selected, Start disabled, helper level = '
        'overall level (FR-020, edge case)', () async {
      final controller = controllerFor(custom);
      expect(stateOf(custom).selectedCategoryIds, isEmpty);
      expect(controller.canStart, isFalse);
      expect(controller.startLevel, DifficultyLevel.l4);
      await expectLater(controller.start(), throwsStateError);
    });

    test('start() persists the selections with the preset kind and the '
        'clock time, then clears the in-flight flag (FR-025)', () async {
      final controller = controllerFor(margins);
      controller.setType(SessionType.fixedSet);
      controller.setDifficulty(DifficultyLevel.l2);
      controller.setAnswerMode(AnswerMode.estimation);

      final before = await SessionRepository(db).countAll();
      final future = controller.start();
      expect(stateOf(margins).isStarting, isTrue);
      expect(controller.canStart, isFalse, reason: 'no double start');
      final session = await future;
      expect(stateOf(margins).isStarting, isFalse);
      expect(controller.canStart, isTrue);

      expect(await SessionRepository(db).countAll(), before + 1);
      expect(session.startedAt, now);
      expect(session.endedAt, isNull);
      expect(session.isCompleted, isFalse);
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
      final stored = (await SessionRepository(db).watchAll().first).first;
      expect(stored, session);
    });

    test('an adaptive start records the start level (data-model.md '
        '"Mapping rules")', () async {
      final controller = controllerFor(all);
      final session = await controller.start();
      expect(
        session.config.difficulty,
        const AdaptiveDifficultySetting(DifficultyLevel.l4),
      );
      expect(session.config.presetKind, PresetKind.all);
      expect(session.config.categoryIds, hasLength(8));
    });

    test('is disposed when nothing listens any more, so a re-open starts '
        'from the defaults (FR-026, R-11)', () async {
      final subscription = container.listen(
        sessionSetupControllerProvider(margins),
        (_, _) {},
      );
      container
          .read(sessionSetupControllerProvider(margins).notifier)
          .setType(SessionType.open);
      expect(stateOf(margins).type, SessionType.open);

      subscription.close();
      // Auto-dispose runs asynchronously; afterwards a read builds a fresh
      // controller from the preset again.
      await container.pump();
      expect(stateOf(margins).type, SessionType.timed);
    });
  });
}
