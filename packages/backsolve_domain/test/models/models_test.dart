import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

void main() {
  group('DifficultyLevel', () {
    test('fromNumber throws ArgumentError outside 1..5', () {
      expect(() => DifficultyLevel.fromNumber(0), throwsArgumentError);
      expect(() => DifficultyLevel.fromNumber(6), throwsArgumentError);
    });

    test('fromNumber(n).number == n for 1..5', () {
      for (var n = 1; n <= 5; n++) {
        expect(DifficultyLevel.fromNumber(n).number, n);
      }
    });
  });

  group('DifficultySetting', () {
    test('has value equality', () {
      expect(
        const AdaptiveDifficultySetting(DifficultyLevel.l2),
        equals(const AdaptiveDifficultySetting(DifficultyLevel.l2)),
      );
      expect(
        const AdaptiveDifficultySetting(DifficultyLevel.l2).hashCode,
        const AdaptiveDifficultySetting(DifficultyLevel.l2).hashCode,
      );
      expect(
        const AdaptiveDifficultySetting(DifficultyLevel.l2),
        isNot(equals(const AdaptiveDifficultySetting(DifficultyLevel.l3))),
      );
      expect(
        const AdaptiveDifficultySetting(DifficultyLevel.l2),
        isNot(equals(const FixedDifficultySetting(DifficultyLevel.l2))),
      );
      expect(
        const FixedDifficultySetting(DifficultyLevel.l2),
        equals(const FixedDifficultySetting(DifficultyLevel.l2)),
      );
    });
  });

  group('SessionType', () {
    test('durationSeconds is 60 / null / null', () {
      expect(SessionType.timed.durationSeconds, 60);
      expect(SessionType.fixedSet.durationSeconds, isNull);
      expect(SessionType.open.durationSeconds, isNull);
    });

    test('questionCount is null / 20 / null', () {
      expect(SessionType.timed.questionCount, isNull);
      expect(SessionType.fixedSet.questionCount, 20);
      expect(SessionType.open.questionCount, isNull);
    });
  });

  group('SessionConfig', () {
    test('asserts on an empty categoryIds', () {
      expect(
        () => SessionConfig(
          type: SessionType.timed,
          difficulty: const AdaptiveDifficultySetting(DifficultyLevel.l3),
          answerMode: AnswerMode.exact,
          categoryIds: const [],
          presetKind: PresetKind.custom,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on duplicate categoryIds', () {
      expect(
        () => SessionConfig(
          type: SessionType.timed,
          difficulty: const AdaptiveDifficultySetting(DifficultyLevel.l3),
          answerMode: AnswerMode.exact,
          categoryIds: const ['percentages', 'percentages'],
          presetKind: PresetKind.custom,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('defaultsFor yields timed / adaptive(startLevel) / exact', () {
      final config = SessionConfig.defaultsFor(
        categoryIds: const ['percentages', 'multiplication'],
        startLevel: DifficultyLevel.l4,
        presetKind: PresetKind.all,
      );
      expect(config.type, SessionType.timed);
      expect(
        config.difficulty,
        const AdaptiveDifficultySetting(DifficultyLevel.l4),
      );
      expect(config.answerMode, AnswerMode.exact);
      expect(config.categoryIds, ['percentages', 'multiplication']);
      expect(config.presetKind, PresetKind.all);
    });

    test('has value equality and copyWith', () {
      final a = SessionConfig.defaultsFor(
        categoryIds: const ['percentages'],
        startLevel: DifficultyLevel.l2,
        presetKind: PresetKind.category,
      );
      final b = SessionConfig.defaultsFor(
        categoryIds: const ['percentages'],
        startLevel: DifficultyLevel.l2,
        presetKind: PresetKind.category,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a.copyWith(answerMode: AnswerMode.estimation), isNot(equals(b)));
      expect(
        a.copyWith(answerMode: AnswerMode.estimation).answerMode,
        AnswerMode.estimation,
      );
    });
  });

  group('SessionResult', () {
    SessionResult build({
      double accuracy = 80,
      double avgAnswerSeconds = 5.5,
      int questionCount = 10,
      int correctCount = 8,
    }) => SessionResult(
      accuracy: accuracy,
      avgAnswerSeconds: avgAnswerSeconds,
      questionCount: questionCount,
      correctCount: correctCount,
    );

    test('accepts valid values', () {
      expect(build().accuracy, 80);
      expect(build(accuracy: 0, correctCount: 0).correctCount, 0);
      expect(build(accuracy: 100, correctCount: 10).accuracy, 100);
    });

    test('asserts on accuracy outside 0–100', () {
      expect(() => build(accuracy: -1), throwsA(isA<AssertionError>()));
      expect(() => build(accuracy: 101), throwsA(isA<AssertionError>()));
    });

    test('asserts on avgAnswerSeconds <= 0', () {
      expect(() => build(avgAnswerSeconds: 0), throwsA(isA<AssertionError>()));
      expect(() => build(avgAnswerSeconds: -2), throwsA(isA<AssertionError>()));
    });

    test('asserts on questionCount < 1', () {
      expect(
        () => build(questionCount: 0, correctCount: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on correctCount > questionCount', () {
      expect(
        () => build(questionCount: 5, correctCount: 6),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Session', () {
    final config = SessionConfig.defaultsFor(
      categoryIds: const ['percentages'],
      startLevel: DifficultyLevel.l3,
      presetKind: PresetKind.category,
    );
    final startedAt = DateTime(2026, 9, 14, 9, 30);
    const result = SessionResult(
      accuracy: 75,
      avgAnswerSeconds: 6.0,
      questionCount: 8,
      correctCount: 6,
    );

    test('isCompleted is true only when both endedAt and result are set', () {
      final unfinished = Session(
        id: 1,
        startedAt: startedAt,
        endedAt: null,
        config: config,
        result: null,
      );
      expect(unfinished.isCompleted, isFalse);
      expect(
        unfinished
            .copyWith(endedAt: startedAt.add(const Duration(seconds: 60)))
            .isCompleted,
        isFalse,
      );
      expect(unfinished.copyWith(result: result).isCompleted, isFalse);
      expect(
        unfinished
            .copyWith(
              endedAt: startedAt.add(const Duration(seconds: 60)),
              result: result,
            )
            .isCompleted,
        isTrue,
      );
    });
  });

  group('SessionPreset', () {
    test('defaultConfig may be null only for custom', () {
      expect(
        SessionPreset(
          kind: PresetKind.custom,
          title: 'Custom session',
          categoryIds: const [],
          defaultConfig: null,
        ).defaultConfig,
        isNull,
      );
      expect(
        () => SessionPreset(
          kind: PresetKind.all,
          title: 'All categories',
          categoryIds: const ['percentages'],
          defaultConfig: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
