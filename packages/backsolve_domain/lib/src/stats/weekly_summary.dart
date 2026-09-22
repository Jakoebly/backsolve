import '../models/session.dart';
import 'calendar.dart' as calendar;

/// One calendar week of the Home chart (FR-033). Derived, not stored.
final class WeeklySummary {
  const WeeklySummary({
    required this.weekStart,
    required this.accuracy,
    required this.avgAnswerSeconds,
    required this.sessionCount,
  });

  /// Monday 00:00 local of the week.
  final DateTime weekStart;

  /// Mean `result.accuracy` of the completed sessions started this week;
  /// `null` when there is none.
  final double? accuracy;

  /// Mean `result.avgAnswerSeconds` of those sessions; `null` when none.
  final double? avgAnswerSeconds;

  /// Number of completed sessions started this week.
  final int sessionCount;

  /// A week "has data" exactly when it has a completed session.
  bool get hasData => accuracy != null;

  /// The eight weeks W1 → W8 ending with the week containing [now]
  /// (W8 = `weekStart(now)`). Every session is bucketed by `startedAt`; only
  /// completed sessions contribute to the averages and to [sessionCount].
  static List<WeeklySummary> lastEightWeeks(
    Iterable<Session> sessions,
    DateTime now,
  ) {
    final latest = calendar.weekStart(now);
    final starts = [
      for (var i = 7; i >= 0; i--)
        DateTime(latest.year, latest.month, latest.day - 7 * i),
    ];
    final indexByStart = {for (var i = 0; i < 8; i++) starts[i]: i};

    final counts = List<int>.filled(8, 0);
    final accuracySums = List<double>.filled(8, 0);
    final secondsSums = List<double>.filled(8, 0);
    for (final session in sessions) {
      final result = session.result;
      if (!session.isCompleted || result == null) continue;
      final index = indexByStart[calendar.weekStart(session.startedAt)];
      if (index == null) continue; // outside the last eight weeks
      counts[index]++;
      accuracySums[index] += result.accuracy;
      secondsSums[index] += result.avgAnswerSeconds;
    }

    return List.unmodifiable([
      for (var i = 0; i < 8; i++)
        WeeklySummary(
          weekStart: starts[i],
          accuracy: counts[i] == 0 ? null : accuracySums[i] / counts[i],
          avgAnswerSeconds: counts[i] == 0 ? null : secondsSums[i] / counts[i],
          sessionCount: counts[i],
        ),
    ]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklySummary &&
          other.weekStart == weekStart &&
          other.accuracy == accuracy &&
          other.avgAnswerSeconds == avgAnswerSeconds &&
          other.sessionCount == sessionCount;

  @override
  int get hashCode =>
      Object.hash(weekStart, accuracy, avgAnswerSeconds, sessionCount);

  @override
  String toString() =>
      'WeeklySummary(weekStart: $weekStart, accuracy: $accuracy, '
      'avgAnswerSeconds: $avgAnswerSeconds, sessionCount: $sessionCount)';
}
