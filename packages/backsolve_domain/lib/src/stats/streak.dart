import '../models/session.dart';
import 'calendar.dart';

/// Consecutive calendar days, ending today or yesterday, on which at least
/// one completed session was started; 0 when neither today nor yesterday
/// has one (FR-034). A session belongs to the day of its `startedAt`.
int dayStreak(Iterable<Session> sessions, DateTime now) {
  final practisedDays = {
    for (final session in sessions)
      if (session.isCompleted) dateOnly(session.startedAt),
  };

  var day = dateOnly(now);
  if (!practisedDays.contains(day)) {
    day = _dayBefore(day);
    if (!practisedDays.contains(day)) return 0;
  }

  var streak = 0;
  while (practisedDays.contains(day)) {
    streak++;
    day = _dayBefore(day);
  }
  return streak;
}

DateTime _dayBefore(DateTime day) => DateTime(day.year, day.month, day.day - 1);
