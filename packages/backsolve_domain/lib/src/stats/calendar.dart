/// Calendar helpers (research.md R-07). Weeks start on Monday (spec
/// Assumptions "Weeks"); all arithmetic is in local time and goes through the
/// [DateTime] constructor so daylight-saving shifts never move a midnight.
library;

/// [d] with the time of day stripped: local midnight of the same date.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Monday 00:00 (local) of the week containing [d].
DateTime weekStart(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));

/// Whether [a] and [b] fall on the same calendar date.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
