import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'seed_data.dart';

/// Inserts the first-launch data once (FR-029–FR-031,
/// contracts/repositories.md "Seeder"). Category names and order come from
/// `categoryRegistry`; session timestamps are anchored to [now] so the FR-030
/// invariants hold on any install date (research.md R-06).
class Seeder {
  Seeder(this._db, {DateTime Function() now = DateTime.now}) : _now = now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Seeds categories and sessions inside one transaction unless the
  /// `categories` table already has rows. Returns `true` when it seeded.
  Future<bool> seedIfEmpty() {
    return _db.transaction(() async {
      final existing = await _db.categories.count().getSingle();
      if (existing > 0) return false;

      final now = _now();
      final today = dateOnly(now);

      final categories = await _seedCategories(today);
      await _seedSessions(now, today, categories);
      return true;
    });
  }

  Future<List<Category>> _seedCategories(DateTime today) async {
    final categories = <Category>[];
    for (final definition in categoryRegistry) {
      final seed = seedCategories[definition.id] ?? defaultSeedCategory;
      final history = [
        for (final change in seed.levelHistory)
          LevelChange(
            at: DateTime(
              today.year,
              today.month,
              today.day - change.daysAgo,
              12,
            ),
            level: DifficultyLevel.fromNumber(change.level),
          ),
      ];
      final category = Category(
        id: definition.id,
        name: definition.name,
        displayOrder: definition.displayOrder,
        level: DifficultyLevel.fromNumber(seed.level),
        accuracy: seed.accuracy,
        avgAnswerSeconds: seed.avgAnswerSeconds,
        levelHistory: history,
      );
      categories.add(category);
      await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: category.id,
              name: category.name,
              displayOrder: category.displayOrder,
              level: category.level.number,
              accuracy: category.accuracy,
              avgAnswerSeconds: category.avgAnswerSeconds,
              levelHistory: history,
            ),
          );
    }
    return categories;
  }

  Future<void> _seedSessions(
    DateTime now,
    DateTime today,
    List<Category> categories,
  ) async {
    final byId = {for (final category in categories) category.id: category};
    final allIds = [for (final category in categories) category.id];
    final thisWeek = weekStart(now);
    // The today row may never be in the future: clamp it to now − 2 min
    // (whole seconds, matching what the datetime column stores).
    final latestStart = _truncateToSeconds(
      now.subtract(const Duration(minutes: 2)),
    );

    for (final row in seedSessions) {
      var startedAt = switch (row.daysAgo) {
        final daysAgo? => DateTime(
          today.year,
          today.month,
          today.day - daysAgo,
          row.hour,
          row.minute,
        ),
        null => DateTime(
          thisWeek.year,
          thisWeek.month,
          thisWeek.day - 7 * row.weekOffset! + (row.weekday! - 1),
          row.hour,
          row.minute,
        ),
      };
      if (row.daysAgo == 0 && startedAt.isAfter(latestStart)) {
        startedAt = latestStart;
      }
      final endedAt = startedAt.add(Duration(seconds: row.durationSeconds));
      assert(
        !startedAt.isAfter(now) && !endedAt.isAfter(now),
        'seed session at $startedAt–$endedAt would be after $now',
      );

      final ids = row.categoryIds ?? allIds;
      final selected = [
        for (final id in ids)
          byId[id] ??
              (throw StateError(
                'seed session references unknown category $id',
              )),
      ];

      await _db
          .into(_db.sessions)
          .insert(
            SessionsCompanion.insert(
              startedAt: startedAt,
              endedAt: Value(endedAt),
              sessionType: SessionType.timed,
              difficultyLevel: const Value(null),
              adaptiveStartLevel: Value(startLevelFor(selected).number),
              answerMode: AnswerMode.exact,
              presetKind: row.presetKind,
              categoryIds: ids,
              accuracy: Value(row.accuracy),
              avgAnswerSeconds: Value(row.avgAnswerSeconds),
              questionCount: Value(row.questionCount),
              correctCount: Value(row.correctCount),
            ),
          );
    }
  }

  static DateTime _truncateToSeconds(DateTime t) =>
      DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
}
