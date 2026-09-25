import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/repositories/session_repository.dart';
import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SessionRepository(db);
  });

  tearDown(() => db.close());

  final startedAt = DateTime(2026, 9, 14, 9, 30);
  const result = SessionResult(
    accuracy: 75,
    avgAnswerSeconds: 6.0,
    questionCount: 8,
    correctCount: 6,
  );

  SessionConfig config({
    SessionType type = SessionType.timed,
    DifficultySetting difficulty = const AdaptiveDifficultySetting(
      DifficultyLevel.l3,
    ),
    AnswerMode answerMode = AnswerMode.exact,
    List<String> categoryIds = const ['percentages'],
    PresetKind presetKind = PresetKind.category,
  }) => SessionConfig(
    type: type,
    difficulty: difficulty,
    answerMode: answerMode,
    categoryIds: categoryIds,
    presetKind: presetKind,
  );

  group('start', () {
    test('persists all 36 type × difficulty × answer-mode combinations '
        '(SC-006)', () async {
      final difficulties = <DifficultySetting>[
        const AdaptiveDifficultySetting(DifficultyLevel.l3),
        for (final level in DifficultyLevel.values)
          FixedDifficultySetting(level),
      ];
      var combinations = 0;
      for (final type in SessionType.values) {
        for (final difficulty in difficulties) {
          for (final answerMode in AnswerMode.values) {
            final expected = config(
              type: type,
              difficulty: difficulty,
              answerMode: answerMode,
              categoryIds: const ['percentages', 'growth_cagr'],
              presetKind: PresetKind.custom,
            );
            final started = await repository.start(
              expected,
              startedAt: startedAt,
            );
            expect(started.config, expected);
            combinations++;
          }
        }
      }
      expect(combinations, 36);

      final all = await repository.watchAll().first;
      expect(all, hasLength(36));
      expect(all.map((s) => s.config).toSet(), hasLength(36));
    });

    test('returns an unfinished session with its id and never writes '
        'result columns', () async {
      final session = await repository.start(config(), startedAt: startedAt);
      expect(session.id, greaterThan(0));
      expect(session.startedAt, startedAt);
      expect(session.endedAt, isNull);
      expect(session.result, isNull);
      expect(session.isCompleted, isFalse);

      final row = await (db.select(db.sessions)).getSingle();
      expect(row.endedAt, isNull);
      expect(row.accuracy, isNull);
      expect(row.avgAnswerSeconds, isNull);
      expect(row.questionCount, isNull);
      expect(row.correctCount, isNull);
    });

    test('stores adaptive as NULL difficulty_level + start level', () async {
      await repository.start(
        config(difficulty: const AdaptiveDifficultySetting(DifficultyLevel.l4)),
        startedAt: startedAt,
      );
      final row = await (db.select(db.sessions)).getSingle();
      expect(row.difficultyLevel, isNull);
      expect(row.adaptiveStartLevel, 4);
    });

    test('stores a fixed level as difficulty_level with NULL start', () async {
      await repository.start(
        config(difficulty: const FixedDifficultySetting(DifficultyLevel.l2)),
        startedAt: startedAt,
      );
      final row = await (db.select(db.sessions)).getSingle();
      expect(row.difficultyLevel, 2);
      expect(row.adaptiveStartLevel, isNull);
    });

    test('assigns increasing ids', () async {
      final a = await repository.start(config(), startedAt: startedAt);
      final b = await repository.start(config(), startedAt: startedAt);
      expect(b.id, greaterThan(a.id));
    });
  });

  group('complete', () {
    test('fills endedAt and the result', () async {
      final session = await repository.start(config(), startedAt: startedAt);
      final endedAt = startedAt.add(const Duration(seconds: 70));
      await repository.complete(session.id, endedAt: endedAt, result: result);

      final completed = (await repository.watchAll().first).single;
      expect(completed.id, session.id);
      expect(completed.endedAt, endedAt);
      expect(completed.result, result);
      expect(completed.isCompleted, isTrue);
    });
  });

  group('watchAll', () {
    test('is newest first and includes unfinished rows', () async {
      final older = await repository.start(
        config(),
        startedAt: DateTime(2026, 9, 10, 8),
      );
      final newest = await repository.start(
        config(),
        startedAt: DateTime(2026, 9, 14, 20),
      );
      final middle = await repository.start(
        config(),
        startedAt: DateTime(2026, 9, 12, 12),
      );
      await repository.complete(
        older.id,
        endedAt: DateTime(2026, 9, 10, 8, 1),
        result: result,
      );

      final all = await repository.watchAll().first;
      expect(all.map((s) => s.id).toList(), [newest.id, middle.id, older.id]);
      expect(all.where((s) => !s.isCompleted), hasLength(2));
    });

    test('re-emits when a session is started', () async {
      final stream = repository.watchAll();
      expect(await stream.first, isEmpty);
      final next = stream.skip(1).first;
      await repository.start(config(), startedAt: startedAt);
      expect(await next, hasLength(1));
    });
  });

  group('getBetween', () {
    test('is half-open on [from, to)', () async {
      final from = DateTime(2026, 9, 14);
      final to = DateTime(2026, 9, 21);
      await repository.start(
        config(),
        startedAt: from.subtract(const Duration(seconds: 1)),
      );
      final atFrom = await repository.start(config(), startedAt: from);
      final inside = await repository.start(
        config(),
        startedAt: DateTime(2026, 9, 17, 12),
      );
      final justBeforeTo = await repository.start(
        config(),
        startedAt: to.subtract(const Duration(seconds: 1)),
      );
      await repository.start(config(), startedAt: to);

      final between = await repository.getBetween(from, to);
      expect(between.map((s) => s.id).toList(), [
        atFrom.id,
        inside.id,
        justBeforeTo.id,
      ]);
    });
  });

  group('countAll', () {
    test('increases by one per start (SC-008)', () async {
      expect(await repository.countAll(), 0);
      await repository.start(config(), startedAt: startedAt);
      expect(await repository.countAll(), 1);
      await repository.start(config(), startedAt: startedAt);
      expect(await repository.countAll(), 2);
    });
  });
}
