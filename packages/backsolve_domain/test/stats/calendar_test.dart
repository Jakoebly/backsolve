import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

void main() {
  group('weekStart', () {
    test('on a Monday returns the same date at 00:00', () {
      final monday = DateTime(2026, 9, 14, 15, 45); // Monday
      expect(monday.weekday, DateTime.monday);
      expect(weekStart(monday), DateTime(2026, 9, 14));
    });

    test('on a Sunday returns the previous Monday', () {
      final sunday = DateTime(2026, 9, 20, 23, 59); // Sunday
      expect(sunday.weekday, DateTime.sunday);
      expect(weekStart(sunday), DateTime(2026, 9, 14));
    });

    test('mid-week returns the Monday of that week', () {
      expect(weekStart(DateTime(2026, 9, 17, 8)), DateTime(2026, 9, 14));
    });

    test('crosses a year boundary', () {
      expect(weekStart(DateTime(2026, 1, 1)), DateTime(2025, 12, 29));
    });

    test('always returns a Monday at midnight', () {
      var d = DateTime(2026, 1, 1);
      for (var i = 0; i < 400; i++) {
        final start = weekStart(d);
        expect(start.weekday, DateTime.monday);
        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.isAfter(d), isFalse);
        expect(d.difference(start).inDays, lessThan(7));
        d = DateTime(d.year, d.month, d.day + 1, 13);
      }
    });
  });

  group('dateOnly', () {
    test('strips the time of day', () {
      expect(
        dateOnly(DateTime(2026, 9, 14, 23, 59, 59, 999)),
        DateTime(2026, 9, 14),
      );
      expect(dateOnly(DateTime(2026, 9, 14, 0, 0, 1)), DateTime(2026, 9, 14));
    });
  });

  group('isSameDay', () {
    test('is true for two times on the same date', () {
      expect(
        isSameDay(DateTime(2026, 9, 14, 0, 1), DateTime(2026, 9, 14, 23, 59)),
        isTrue,
      );
    });

    test('is false across midnight', () {
      expect(
        isSameDay(DateTime(2026, 9, 14, 23, 59), DateTime(2026, 9, 15, 0, 0)),
        isFalse,
      );
    });
  });
}
