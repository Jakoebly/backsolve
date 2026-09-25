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
  bool completed = true,
  DateTime? endedAt,
}) {
  return Session(
    id: _nextId++,
    startedAt: startedAt,
    endedAt: completed
        ? (endedAt ?? startedAt.add(const Duration(seconds: 70)))
        : null,
    config: config,
    result: completed
        ? const SessionResult(
            accuracy: 80,
            avgAnswerSeconds: 6,
            questionCount: 10,
            correctCount: 8,
          )
        : null,
  );
}

/// One completed session on each of the [daysAgo] offsets (0 = today).
List<Session> onDays(DateTime now, Iterable<int> daysAgo) => [
  for (final d in daysAgo)
    session(DateTime(now.year, now.month, now.day - d, 18, 30)),
];

void main() {
  final now = DateTime(2026, 9, 16, 15, 30); // Wednesday

  group('dayStreak', () {
    test('counts consecutive days ending today', () {
      expect(dayStreak(onDays(now, [0, 1, 2, 3, 4, 5, 6]), now), 7);
      expect(dayStreak(onDays(now, [0]), now), 1);
    });

    test('counts a streak ending yesterday when today is absent', () {
      expect(dayStreak(onDays(now, [1, 2, 3]), now), 3);
    });

    test('is 0 when neither today nor yesterday was practised', () {
      expect(dayStreak(onDays(now, [2, 3, 4]), now), 0);
      expect(dayStreak(const [], now), 0);
    });

    test('stops at the first gap', () {
      expect(dayStreak(onDays(now, [0, 1, 3, 4, 5]), now), 2);
      expect(dayStreak(onDays(now, [1, 2, 4]), now), 2);
    });

    test('several sessions on one day count once', () {
      expect(
        dayStreak([
          ...onDays(now, [0, 0, 0, 1]),
          session(DateTime(2026, 9, 15, 7)),
          session(DateTime(2026, 9, 15, 21)),
        ], now),
        2,
      );
    });

    test('keys days on startedAt, not endedAt', () {
      // Started yesterday at 23:50, finished today at 00:20 → yesterday.
      final acrossMidnight = session(
        DateTime(2026, 9, 15, 23, 50),
        endedAt: DateTime(2026, 9, 16, 0, 20),
      );
      expect(dayStreak([acrossMidnight], now), 1);
      expect(
        dayStreak([
          acrossMidnight,
          ...onDays(now, [2]),
        ], now),
        2,
        reason: 'yesterday + the day before',
      );
    });

    test('unfinished sessions do not count', () {
      expect(dayStreak([session(now, completed: false)], now), 0);
      expect(
        dayStreak([
          session(now, completed: false),
          ...onDays(now, [1, 2]),
        ], now),
        2,
        reason: 'the unfinished session today does not extend the streak',
      );
    });

    test('crosses a month boundary', () {
      final first = DateTime(2026, 10, 1, 9); // Thursday
      expect(dayStreak(onDays(first, [0, 1, 2, 3]), first), 4);
    });
  });
}
