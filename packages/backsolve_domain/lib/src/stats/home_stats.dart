import '../models/category.dart';
import '../models/difficulty_level.dart';
import '../models/session.dart';
import 'calendar.dart' as calendar;
import 'levels.dart' as levels;
import 'streak.dart' as streaks;
import 'weekly_summary.dart';

/// Everything the Home screen shows, derived from the stored categories and
/// sessions (FR-008–FR-011, FR-033–FR-035). Reproducible by hand (SC-007).
final class HomeStats {
  const HomeStats({
    required this.weeks,
    required this.accuracy,
    required this.accuracyDelta,
    required this.speedSeconds,
    required this.speedDelta,
    required this.sessionsThisWeek,
    required this.sessionsAllTime,
    required this.dayStreak,
    required this.overallLevel,
  });

  /// W1 → W8; W8 is the current week.
  final List<WeeklySummary> weeks;

  /// Whole-number accuracy of the shown week — the latest week with data —
  /// or `null` when no week has one.
  final int? accuracy;

  /// [accuracy] minus the previous week's whole-number accuracy; `null`
  /// when the week before the shown one has no data.
  final int? accuracyDelta;

  /// Average answer seconds of the shown week, or `null`.
  final double? speedSeconds;

  /// [speedSeconds] minus the previous week's (both to one decimal; negative
  /// means faster); `null` when the week before the shown one has no data.
  final double? speedDelta;

  /// Sessions started in the current week, unfinished ones included.
  final int sessionsThisWeek;

  /// Sessions started ever, unfinished ones included.
  final int sessionsAllTime;

  /// FR-034.
  final int dayStreak;

  /// FR-035.
  final DifficultyLevel overallLevel;

  /// Throws an [ArgumentError] when [categories] is empty (no overall
  /// level can exist without categories).
  static HomeStats from(
    Iterable<Category> categories,
    Iterable<Session> sessions,
    DateTime now,
  ) {
    final sessionList = sessions.toList(growable: false);
    final weeks = WeeklySummary.lastEightWeeks(sessionList, now);

    int? accuracy;
    int? accuracyDelta;
    double? speedSeconds;
    double? speedDelta;
    final shownIndex = weeks.lastIndexWhere((week) => week.hasData);
    if (shownIndex >= 0) {
      final shown = weeks[shownIndex];
      accuracy = shown.accuracy!.round();
      speedSeconds = shown.avgAnswerSeconds;
      final previous = shownIndex > 0 ? weeks[shownIndex - 1] : null;
      if (previous != null && previous.hasData) {
        accuracyDelta = accuracy - previous.accuracy!.round();
        speedDelta =
            _oneDecimal(shown.avgAnswerSeconds!) -
            _oneDecimal(previous.avgAnswerSeconds!);
      }
    }

    final thisWeekStart = calendar.weekStart(now);
    final nextWeekStart = DateTime(
      thisWeekStart.year,
      thisWeekStart.month,
      thisWeekStart.day + 7,
    );
    final sessionsThisWeek = sessionList
        .where(
          (session) =>
              !session.startedAt.isBefore(thisWeekStart) &&
              session.startedAt.isBefore(nextWeekStart),
        )
        .length;

    return HomeStats(
      weeks: weeks,
      accuracy: accuracy,
      accuracyDelta: accuracyDelta,
      speedSeconds: speedSeconds,
      speedDelta: speedDelta,
      sessionsThisWeek: sessionsThisWeek,
      sessionsAllTime: sessionList.length,
      dayStreak: streaks.dayStreak(sessionList, now),
      overallLevel: levels.overallLevel(categories),
    );
  }

  /// Both tiles show one decimal, so the delta is taken between the shown
  /// values rather than the raw means.
  static double _oneDecimal(double seconds) => (seconds * 10).round() / 10;

  @override
  String toString() =>
      'HomeStats(accuracy: $accuracy, accuracyDelta: $accuracyDelta, '
      'speedSeconds: $speedSeconds, speedDelta: $speedDelta, '
      'sessionsThisWeek: $sessionsThisWeek, sessionsAllTime: $sessionsAllTime, '
      'dayStreak: $dayStreak, overallLevel: $overallLevel, weeks: $weeks)';
}
