import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// The only read/write path for the `sessions` table
/// (contracts/repositories.md "SessionRepository"). Every public signature
/// uses domain types; no Drift type leaks out.
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  /// Inserts an unfinished session (`endedAt` and every outcome column
  /// `NULL`) and returns it as stored, with its id (FR-025).
  Future<Session> start(
    SessionConfig config, {
    required DateTime startedAt,
  }) async {
    final (fixedLevel, adaptiveStartLevel) = switch (config.difficulty) {
      FixedDifficultySetting(:final level) => (level.number, null),
      AdaptiveDifficultySetting(:final startLevel) => (null, startLevel.number),
    };
    final id = await _db
        .into(_db.sessions)
        .insert(
          SessionsCompanion.insert(
            startedAt: startedAt,
            sessionType: config.type,
            difficultyLevel: Value(fixedLevel),
            adaptiveStartLevel: Value(adaptiveStartLevel),
            answerMode: config.answerMode,
            presetKind: config.presetKind,
            categoryIds: config.categoryIds,
          ),
        );
    final row = await (_db.select(
      _db.sessions,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toDomain(row);
  }

  /// Marks session [id] finished. Not called by any screen in this version.
  Future<void> complete(
    int id, {
    required DateTime endedAt,
    required SessionResult result,
  }) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(id))).write(
      SessionsCompanion(
        endedAt: Value(endedAt),
        accuracy: Value(result.accuracy),
        avgAnswerSeconds: Value(result.avgAnswerSeconds),
        questionCount: Value(result.questionCount),
        correctCount: Value(result.correctCount),
      ),
    );
  }

  /// All sessions, newest first, including unfinished ones. Emits again
  /// whenever a row changes.
  Stream<List<Session>> watchAll() =>
      (_db.select(_db.sessions)..orderBy([
            (t) => OrderingTerm.desc(t.startedAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
          .watch()
          .map(_toDomainList);

  /// Sessions with `startedAt` in `[from, to)`, oldest first. One-shot.
  Future<List<Session>> getBetween(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.sessions)
              ..where(
                (t) =>
                    t.startedAt.isBiggerOrEqualValue(from) &
                    t.startedAt.isSmallerThanValue(to),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.startedAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return _toDomainList(rows);
  }

  Future<int> countAll() => _db.sessions.count().getSingle();

  static List<Session> _toDomainList(List<SessionRow> rows) =>
      List.unmodifiable(rows.map(_toDomain));

  /// Row → [Session] per data-model.md "Mapping rules".
  static Session _toDomain(SessionRow row) {
    final DifficultySetting difficulty;
    if (row.difficultyLevel != null) {
      difficulty = FixedDifficultySetting(
        DifficultyLevel.fromNumber(row.difficultyLevel!),
      );
    } else if (row.adaptiveStartLevel != null) {
      difficulty = AdaptiveDifficultySetting(
        DifficultyLevel.fromNumber(row.adaptiveStartLevel!),
      );
    } else {
      throw StateError(
        'session ${row.id} has neither a fixed nor an adaptive start level',
      );
    }

    final accuracy = row.accuracy;
    final avgAnswerSeconds = row.avgAnswerSeconds;
    final questionCount = row.questionCount;
    final correctCount = row.correctCount;
    final result =
        accuracy != null &&
            avgAnswerSeconds != null &&
            questionCount != null &&
            correctCount != null
        ? SessionResult(
            accuracy: accuracy,
            avgAnswerSeconds: avgAnswerSeconds,
            questionCount: questionCount,
            correctCount: correctCount,
          )
        : null;

    return Session(
      id: row.id,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      config: SessionConfig(
        type: row.sessionType,
        difficulty: difficulty,
        answerMode: row.answerMode,
        categoryIds: row.categoryIds,
        presetKind: row.presetKind,
      ),
      result: result,
    );
  }
}
