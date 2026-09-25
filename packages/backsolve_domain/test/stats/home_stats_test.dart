import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

final config = SessionConfig.defaultsFor(
  categoryIds: const ['percentages'],
  startLevel: DifficultyLevel.l3,
  presetKind: PresetKind.category,
);

var _nextId = 1;

Session session(
  DateTime startedAt, {
  double accuracy = 80,
  double seconds = 6.0,
  bool completed = true,
}) {
  return Session(
    id: _nextId++,
    startedAt: startedAt,
    endedAt: completed ? startedAt.add(const Duration(seconds: 70)) : null,
    config: config,
    result: completed
        ? SessionResult(
            accuracy: accuracy,
            avgAnswerSeconds: seconds,
            questionCount: 10,
            correctCount: 8,
          )
        : null,
  );
}

Category category(int order, int level) => Category(
  id: 'c$order',
  name: 'C$order',
  displayOrder: order,
  level: DifficultyLevel.fromNumber(level),
  accuracy: 70,
  avgAnswerSeconds: 6,
  levelHistory: const [],
);

/// The T037 seed levels in spec order (mean 3.5 → L4).
final seedCategories = [
  for (final (i, level) in [5, 4, 3, 4, 2, 3, 4, 3].indexed) category(i, level),
];

void main() {
  final now = DateTime(2026, 9, 16, 15, 30); // Wednesday; W8 = Sep 14–20
  final w8 = DateTime(2026, 9, 15, 9); // Tuesday this week
  final w7 = DateTime(2026, 9, 9, 9); // Wednesday last week
  final w6 = DateTime(2026, 9, 2, 9);

  group('HomeStats.from', () {
    test('shows the current week with deltas against the previous week', () {
      final stats = HomeStats.from(seedCategories, [
        session(w8, accuracy: 82.4, seconds: 5.84),
        session(w7, accuracy: 77.6, seconds: 6.44),
      ], now);

      expect(stats.weeks, hasLength(8));
      expect(stats.accuracy, 82);
      expect(stats.speedSeconds, 5.84);
      // Deltas compare the displayed (rounded) values: 82 − 78, 5.8 − 6.4.
      expect(stats.accuracyDelta, 4);
      expect(stats.speedDelta, closeTo(-0.6, 1e-9));
      expect(formatAccuracyDelta(stats.accuracyDelta!), '+4 this week');
      expect(formatSpeedDelta(stats.speedDelta!), '−0.6s this week');
      expect(stats.sessionsThisWeek, 1);
      expect(stats.sessionsAllTime, 2);
      expect(stats.overallLevel, DifficultyLevel.l4);
    });

    test('a positive speed delta means slower', () {
      final stats = HomeStats.from(seedCategories, [
        session(w8, accuracy: 70, seconds: 6.5),
        session(w7, accuracy: 75, seconds: 6.1),
      ], now);
      expect(stats.accuracyDelta, -5);
      expect(stats.speedDelta, closeTo(0.4, 1e-9));
    });

    test('omits the deltas when the previous week has no data', () {
      final stats = HomeStats.from(seedCategories, [
        session(w8, accuracy: 82, seconds: 5.8),
        session(w6, accuracy: 60, seconds: 8.0),
      ], now);
      expect(stats.accuracy, 82);
      expect(stats.speedSeconds, 5.8);
      expect(stats.accuracyDelta, isNull);
      expect(stats.speedDelta, isNull);
    });

    test('shows the most recent week with data when the current week is '
        'empty', () {
      final stats = HomeStats.from(seedCategories, [
        session(w7, accuracy: 77, seconds: 6.4),
        session(w6, accuracy: 72, seconds: 6.9),
      ], now);
      expect(stats.accuracy, 77);
      expect(stats.speedSeconds, 6.4);
      expect(stats.accuracyDelta, 5, reason: 'W7 vs W6');
      expect(stats.speedDelta, closeTo(-0.5, 1e-9));
      expect(stats.sessionsThisWeek, 0);
      expect(stats.weeks.last.hasData, isFalse);
    });

    test('has no tile values at all without any completed session', () {
      final stats = HomeStats.from(seedCategories, const [], now);
      expect(stats.accuracy, isNull);
      expect(stats.accuracyDelta, isNull);
      expect(stats.speedSeconds, isNull);
      expect(stats.speedDelta, isNull);
      expect(stats.sessionsThisWeek, 0);
      expect(stats.sessionsAllTime, 0);
      expect(stats.dayStreak, 0);
      expect(stats.overallLevel, DifficultyLevel.l4);
    });

    test('session counts include unfinished sessions; averages and the '
        'streak do not', () {
      final stats = HomeStats.from(seedCategories, [
        session(w8, accuracy: 80, seconds: 6.0),
        session(DateTime(2026, 9, 16, 14), completed: false), // today
        session(DateTime(2026, 9, 10, 14), completed: false), // W7
      ], now);
      expect(stats.sessionsThisWeek, 2);
      expect(stats.sessionsAllTime, 3);
      expect(stats.accuracy, 80);
      expect(stats.accuracyDelta, isNull, reason: 'W7 has no completed row');
      expect(stats.weeks[6].sessionCount, 0);
      expect(
        stats.dayStreak,
        1,
        reason:
            'yesterday\'s completed session; today\'s unfinished one '
            'adds nothing',
      );
    });

    test('counts the week by startedAt and the streak from T058', () {
      final stats = HomeStats.from(seedCategories, [
        for (var d = 0; d < 7; d++)
          session(DateTime(2026, 9, 16 - d, 18), accuracy: 80 + d.toDouble()),
        session(DateTime(2026, 9, 13, 23, 59)), // Sunday → W7
      ], now);
      expect(stats.dayStreak, 7);
      expect(stats.sessionsThisWeek, 3, reason: 'Mon 14, Tue 15, Wed 16');
      expect(stats.sessionsAllTime, 8);
    });

    test('overallLevel of the seed levels is L4', () {
      expect(
        HomeStats.from(seedCategories, const [], now).overallLevel,
        DifficultyLevel.l4,
      );
    });

    test('throws ArgumentError without categories', () {
      expect(
        () => HomeStats.from(const [], const [], now),
        throwsArgumentError,
      );
    });
  });
}
