import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

final config = SessionConfig.defaultsFor(
  categoryIds: const ['percentages'],
  startLevel: DifficultyLevel.l3,
  presetKind: PresetKind.category,
);

var _nextId = 1;

/// A completed session unless [completed] is false; [endedAt] defaults to
/// 70 s after [startedAt].
Session session(
  DateTime startedAt, {
  double accuracy = 80,
  double seconds = 6.0,
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
        ? SessionResult(
            accuracy: accuracy,
            avgAnswerSeconds: seconds,
            questionCount: 10,
            correctCount: 8,
          )
        : null,
  );
}

void main() {
  // Wednesday 2026-09-16 → W8 starts Monday 2026-09-14.
  final now = DateTime(2026, 9, 16, 15, 30);

  group('WeeklySummary.lastEightWeeks', () {
    test('returns exactly 8 buckets in W1 → W8 order ending with now\'s '
        'week', () {
      final weeks = WeeklySummary.lastEightWeeks(const [], now);
      expect(weeks, hasLength(8));
      expect(weeks.map((w) => w.weekStart).toList(), [
        DateTime(2026, 7, 27),
        DateTime(2026, 8, 3),
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 17),
        DateTime(2026, 8, 24),
        DateTime(2026, 8, 31),
        DateTime(2026, 9, 7),
        DateTime(2026, 9, 14),
      ]);
      expect(weeks.last.weekStart, weekStart(now));
      for (final week in weeks) {
        expect(week.weekStart.weekday, DateTime.monday);
      }
    });

    test('an empty week yields null accuracy/speed and sessionCount 0', () {
      final weeks = WeeklySummary.lastEightWeeks(const [], now);
      for (final week in weeks) {
        expect(week.accuracy, isNull);
        expect(week.avgAnswerSeconds, isNull);
        expect(week.sessionCount, 0);
        expect(week.hasData, isFalse);
      }
    });

    test('averages match hand-computed values', () {
      final weeks = WeeklySummary.lastEightWeeks([
        session(DateTime(2026, 9, 14, 8), accuracy: 80, seconds: 5.0),
        session(DateTime(2026, 9, 16, 12), accuracy: 90, seconds: 6.0),
        session(DateTime(2026, 9, 9, 19), accuracy: 70, seconds: 7.5),
      ], now);
      final w8 = weeks[7];
      expect(w8.accuracy, 85);
      expect(w8.avgAnswerSeconds, 5.5);
      expect(w8.sessionCount, 2);
      expect(w8.hasData, isTrue);

      final w7 = weeks[6];
      expect(w7.accuracy, 70);
      expect(w7.avgAnswerSeconds, 7.5);
      expect(w7.sessionCount, 1);

      for (final week in weeks.take(6)) {
        expect(week.sessionCount, 0);
      }
    });

    test('buckets by startedAt: a session started 23:59 Sunday belongs to '
        'that week even if it ends after midnight', () {
      final sunday = DateTime(2026, 9, 13, 23, 59);
      final weeks = WeeklySummary.lastEightWeeks([
        session(sunday, accuracy: 66, endedAt: DateTime(2026, 9, 14, 0, 20)),
      ], now);
      expect(weeks[6].sessionCount, 1, reason: 'W7 (Sep 7–13)');
      expect(weeks[6].accuracy, 66);
      expect(weeks[7].sessionCount, 0, reason: 'W8 (Sep 14–20)');
    });

    test('sessions across a year boundary land in the right week', () {
      final newYear = DateTime(2026, 1, 1, 9); // Thursday; W8 = 2025-12-29
      final weeks = WeeklySummary.lastEightWeeks([
        session(DateTime(2025, 12, 31, 23), accuracy: 90), // W8
        session(DateTime(2025, 12, 28, 10), accuracy: 70), // W7 (Dec 22–28)
        session(DateTime(2025, 11, 10, 7), accuracy: 50), // W1 (Nov 10–16)
        session(DateTime(2025, 11, 9, 23), accuracy: 10), // before W1
      ], newYear);
      expect(weeks.first.weekStart, DateTime(2025, 11, 10));
      expect(weeks.last.weekStart, DateTime(2025, 12, 29));
      expect(weeks[7].accuracy, 90);
      expect(weeks[6].accuracy, 70);
      expect(weeks[0].accuracy, 50);
      expect(weeks.fold(0, (sum, w) => sum + w.sessionCount), 3);
    });

    test('unfinished sessions are excluded from averages and counts', () {
      final weeks = WeeklySummary.lastEightWeeks([
        session(DateTime(2026, 9, 15, 9), accuracy: 80, seconds: 5.0),
        session(DateTime(2026, 9, 15, 10), completed: false),
        session(DateTime(2026, 9, 8, 10), completed: false),
      ], now);
      expect(weeks[7].accuracy, 80);
      expect(weeks[7].avgAnswerSeconds, 5.0);
      expect(weeks[7].sessionCount, 1);
      expect(weeks[6].sessionCount, 0);
      expect(weeks[6].hasData, isFalse);
    });

    test('sessions after now\'s week are ignored', () {
      final weeks = WeeklySummary.lastEightWeeks([
        session(DateTime(2026, 9, 21, 9), accuracy: 99),
      ], now);
      expect(weeks.every((w) => w.sessionCount == 0), isTrue);
    });
  });
}
