import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// The only read/write path for the `categories` table
/// (contracts/repositories.md "CategoryRepository"). Every public signature
/// uses domain types; no Drift type leaks out.
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  /// All categories ordered by `displayOrder`. Emits again whenever a row
  /// changes.
  Stream<List<Category>> watchAll() =>
      _orderedQuery().watch().map(_toDomainList);

  /// One-shot read, same ordering.
  Future<List<Category>> getAll() async =>
      _toDomainList(await _orderedQuery().get());

  Future<Category?> getById(String id) async {
    final row = await (_db.select(
      _db.categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Replaces the given statistics and appends a [LevelChange] dated [at]
  /// (default: now) when [level] differs from the stored one. Not called by
  /// any screen in this version; the next feature's single write path.
  ///
  /// Throws an [ArgumentError] when no category has [id].
  Future<void> updateStats(
    String id, {
    DifficultyLevel? level,
    double? accuracy,
    double? avgAnswerSeconds,
    DateTime? at,
  }) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.categories,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw ArgumentError.value(id, 'id', 'unknown category');
      }

      final levelChanged = level != null && level.number != row.level;
      final history = levelChanged
          ? [
              ...row.levelHistory,
              LevelChange(at: at ?? DateTime.now(), level: level),
            ]
          : null;

      await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(
          level: level == null ? const Value.absent() : Value(level.number),
          accuracy: accuracy == null ? const Value.absent() : Value(accuracy),
          avgAnswerSeconds: avgAnswerSeconds == null
              ? const Value.absent()
              : Value(avgAnswerSeconds),
          levelHistory: history == null ? const Value.absent() : Value(history),
        ),
      );
    });
  }

  SimpleSelectStatement<$CategoriesTable, CategoryRow> _orderedQuery() =>
      _db.select(_db.categories)
        ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]);

  static List<Category> _toDomainList(List<CategoryRow> rows) =>
      List.unmodifiable(rows.map(_toDomain));

  static Category _toDomain(CategoryRow row) => Category(
    id: row.id,
    name: row.name,
    displayOrder: row.displayOrder,
    level: DifficultyLevel.fromNumber(row.level),
    accuracy: row.accuracy,
    avgAnswerSeconds: row.avgAnswerSeconds,
    levelHistory: row.levelHistory,
  );
}
