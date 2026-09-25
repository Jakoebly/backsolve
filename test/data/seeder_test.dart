import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/repositories/category_repository.dart';
import 'package:backsolve/data/repositories/session_repository.dart';
import 'package:backsolve/data/seed/seed_data.dart';
import 'package:backsolve/data/seed/seeder.dart';
import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Install moments that exercise every bucketing edge (data-model.md §3).
final fixedNows = <String, DateTime>{
  'a Monday': DateTime(2026, 9, 14, 10, 0),
  'a Wednesday': DateTime(2026, 9, 16, 15, 30),
  'a Sunday': DateTime(2026, 9, 20, 18, 0),
  '2026-01-01 (year boundary)': DateTime(2026, 1, 1, 9, 15),
  'a Tuesday at 00:30 (today-row clamp)': DateTime(2026, 9, 15, 0, 30),
  'a Saturday at 23:59 (today-row clamp)': DateTime(2026, 9, 19, 23, 59),
};

DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days, d.hour, d.minute, d.second);

double mean(Iterable<double> values) =>
    values.reduce((a, b) => a + b) / values.length;

void main() {
  test('seed table shape: 42 rows, 7 streak + 35 baseline, 5 per week', () {
    expect(seedSessions, hasLength(42));
    final streak = seedSessions.where((r) => r.isStreakRow).toList();
    expect(streak.map((r) => r.daysAgo).toList(), [6, 5, 4, 3, 2, 1, 0]);
    for (var weekOffset = 1; weekOffset <= 7; weekOffset++) {
      expect(
        seedSessions.where((r) => r.weekOffset == weekOffset),
        hasLength(5),
        reason: 'weekOffset $weekOffset',
      );
    }
    expect(seedCategories.keys, categoryRegistry.map((d) => d.id));
    for (final seed in [...seedCategories.values, defaultSeedCategory]) {
      expect(seed.levelHistory, isNotEmpty);
      expect(seed.levelHistory.last.level, seed.level);
    }
  });

  test('every streak row beats every baseline row', () {
    final streak = seedSessions.where((r) => r.isStreakRow);
    final baseline = seedSessions.where((r) => !r.isStreakRow);
    for (final s in streak) {
      for (final b in baseline) {
        expect(s.accuracy, greaterThan(b.accuracy));
        expect(s.avgAnswerSeconds, lessThan(b.avgAnswerSeconds));
      }
    }
    // Strictly improving toward today.
    final ordered = streak.toList()
      ..sort((a, b) => b.daysAgo!.compareTo(a.daysAgo!));
    for (var i = 1; i < ordered.length; i++) {
      expect(ordered[i].accuracy, greaterThan(ordered[i - 1].accuracy));
      expect(
        ordered[i].avgAnswerSeconds,
        lessThan(ordered[i - 1].avgAnswerSeconds),
      );
    }
  });

  for (final entry in fixedNows.entries) {
    group('seeded on ${entry.key}', () {
      final now = entry.value;
      late AppDatabase db;
      late List<Category> categories;
      late List<Session> sessions;

      setUp(() async {
        db = AppDatabase(NativeDatabase.memory());
        expect(await Seeder(db, now: () => now).seedIfEmpty(), isTrue);
        categories = await CategoryRepository(db).getAll();
        sessions = await SessionRepository(db).watchAll().first;
      });

      tearDown(() => db.close());

      test('categories: registry order, realistic stats, level history', () {
        expect(categories, hasLength(8));
        expect(
          categories.map((c) => c.id).toList(),
          categoryRegistry.map((d) => d.id).toList(),
        );
        expect(
          categories.map((c) => c.name).toList(),
          categoryRegistry.map((d) => d.name).toList(),
        );
        expect(
          categories.map((c) => c.displayOrder).toList(),
          List.generate(8, (i) => i),
        );
        expect(
          categories.map((c) => c.level).toSet().length,
          greaterThanOrEqualTo(3),
          reason: 'FR-029: at least three distinct levels',
        );
        for (final c in categories) {
          expect(c.level.number, inInclusiveRange(1, 5));
          expect(c.accuracy, inInclusiveRange(0, 100));
          expect(
            c.avgAnswerSeconds,
            inInclusiveRange(3.0, 10.0),
            reason: 'SC-005',
          );
          expect(c.levelHistory, isNotEmpty);
          expect(c.levelHistory.last.level, c.level);
          for (var i = 1; i < c.levelHistory.length; i++) {
            expect(
              c.levelHistory[i].at.isAfter(c.levelHistory[i - 1].at),
              isTrue,
            );
          }
          expect(c.levelHistory.last.at.isBefore(now), isTrue);
        }
        expect(overallLevel(categories), DifficultyLevel.l4, reason: 'FR-035');
      });

      test('sessions: 40–49 completed timed/adaptive/exact rows, none in the '
          'future', () {
        expect(sessions.length, inInclusiveRange(40, 49));
        for (final s in sessions) {
          expect(s.isCompleted, isTrue);
          expect(s.config.type, SessionType.timed);
          expect(s.config.difficulty, isA<AdaptiveDifficultySetting>());
          expect(s.config.answerMode, AnswerMode.exact);
          expect(s.config.categoryIds, isNotEmpty);
          expect(s.startedAt.isAfter(now), isFalse, reason: 'startedAt');
          expect(s.endedAt!.isAfter(now), isFalse, reason: 'endedAt');
          expect(
            s.endedAt!.difference(s.startedAt).inSeconds,
            inInclusiveRange(60, 90),
          );
          expect(s.result!.questionCount, inInclusiveRange(6, 12));
          expect(
            s.result!.correctCount,
            inInclusiveRange(0, s.result!.questionCount),
          );
          expect(s.result!.avgAnswerSeconds, greaterThan(0));
          // No seeded session straddles midnight.
          expect(isSameDay(s.startedAt, s.endedAt!), isTrue);
        }
        // Newest first.
        for (var i = 1; i < sessions.length; i++) {
          expect(
            sessions[i].startedAt.isAfter(sessions[i - 1].startedAt),
            isFalse,
          );
        }
      });

      test(
        'adaptive start level is the rounded mean of the row categories',
        () {
          final byId = {for (final c in categories) c.id: c};
          for (final s in sessions) {
            final selected = s.config.categoryIds.map((id) => byId[id]!);
            final start =
                (s.config.difficulty as AdaptiveDifficultySetting).startLevel;
            expect(start, startLevelFor(selected));
            expect(
              s.config.presetKind,
              s.config.categoryIds.length == 8
                  ? PresetKind.all
                  : s.config.categoryIds.length == 1
                  ? PresetKind.category
                  : PresetKind.weakest,
            );
          }
        },
      );

      test('every one of the last eight weeks has a completed session '
          '(FR-030)', () {
        final thisWeek = weekStart(now);
        for (var w = 0; w < 8; w++) {
          final start = addDays(thisWeek, -7 * (7 - w));
          final end = addDays(start, 7);
          final inWeek = sessions.where(
            (s) =>
                s.isCompleted &&
                !s.startedAt.isBefore(start) &&
                s.startedAt.isBefore(end),
          );
          expect(inWeek, isNotEmpty, reason: 'W${w + 1} starting $start');
        }
      });

      test('a session started today exists and the streak ending today is '
          'at least 7 days', () {
        final today = dateOnly(now);
        final todaySessions = sessions.where(
          (s) => isSameDay(s.startedAt, today),
        );
        expect(todaySessions, isNotEmpty);
        for (final s in todaySessions) {
          expect(
            s.startedAt.isAfter(now.subtract(const Duration(minutes: 2))),
            isFalse,
            reason: 'startedAt must be at most now − 2 min',
          );
        }

        final days = sessions
            .where((s) => s.isCompleted)
            .map((s) => dateOnly(s.startedAt))
            .toSet();
        var streak = 0;
        var day = today;
        while (days.contains(day)) {
          streak++;
          day = addDays(day, -1);
        }
        expect(streak, greaterThanOrEqualTo(7));
      });

      test('per-week accuracy is non-decreasing and speed non-increasing '
          'W1 to W8', () {
        final thisWeek = weekStart(now);
        final accuracies = <double>[];
        final speeds = <double>[];
        for (var w = 0; w < 8; w++) {
          final start = addDays(thisWeek, -7 * (7 - w));
          final end = addDays(start, 7);
          final inWeek = sessions
              .where(
                (s) =>
                    s.isCompleted &&
                    !s.startedAt.isBefore(start) &&
                    s.startedAt.isBefore(end),
              )
              .toList();
          accuracies.add(mean(inWeek.map((s) => s.result!.accuracy)));
          speeds.add(mean(inWeek.map((s) => s.result!.avgAnswerSeconds)));
        }
        for (var w = 1; w < 8; w++) {
          expect(
            accuracies[w],
            greaterThanOrEqualTo(accuracies[w - 1]),
            reason: 'accuracy W${w + 1} vs W$w: $accuracies',
          );
          expect(
            speeds[w],
            lessThanOrEqualTo(speeds[w - 1]),
            reason: 'speed W${w + 1} vs W$w: $speeds',
          );
        }
        // Generally improving as in home.png: W1 ≈ 62 % / 8.2 s, W8 better.
        expect(accuracies.first, lessThan(65));
        expect(accuracies.last, greaterThan(78));
        expect(speeds.first, greaterThan(8.0));
        expect(speeds.last, lessThan(6.0));
      });

      test('a second seedIfEmpty is a no-op (FR-031)', () async {
        expect(await Seeder(db, now: () => now).seedIfEmpty(), isFalse);
        expect(
          await Seeder(
            db,
            now: () => now.add(const Duration(days: 3)),
          ).seedIfEmpty(),
          isFalse,
        );
        expect(await CategoryRepository(db).getAll(), hasLength(8));
        expect(await SessionRepository(db).countAll(), sessions.length);
      });
    });
  }
}
