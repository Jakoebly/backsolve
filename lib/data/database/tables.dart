// Drift's documented check-constraint idiom (`integer().check(level.isBetweenValues(1, 5))`)
// references the column getter from its own body; the generator wraps it in a
// closure, so the lint's recursion warning is a false positive here.
// ignore_for_file: recursive_getters

import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/drift.dart';

import 'converters.dart';

/// Exactly three tables (data-model.md §2, research.md R-05). Data classes
/// carry a `Row` suffix so they never collide with the domain's `Category`
/// and `Session`.

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get displayOrder => integer().unique()();
  IntColumn get level => integer().check(level.isBetweenValues(1, 5))();
  RealColumn get accuracy => real().check(accuracy.isBetweenValues(0, 100))();
  RealColumn get avgAnswerSeconds =>
      real().check(avgAnswerSeconds.isBiggerThanValue(0))();
  TextColumn get levelHistory => text().map(const LevelHistoryConverter())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SessionRow')
@TableIndex(name: 'sessions_started_at', columns: {#startedAt})
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get sessionType => textEnum<SessionType>()();

  /// `NULL` = adaptive, 1–5 = fixed level.
  IntColumn get difficultyLevel => integer().nullable()();

  /// Set only when adaptive: the L{N} shown in the helper text at start.
  IntColumn get adaptiveStartLevel => integer().nullable()();
  TextColumn get answerMode => textEnum<AnswerMode>()();
  TextColumn get presetKind => textEnum<PresetKind>()();
  TextColumn get categoryIds => text().map(const StringListConverter())();

  // Outcome columns: all `NULL` while the session is unfinished.
  RealColumn get accuracy => real().nullable()();
  RealColumn get avgAnswerSeconds => real().nullable()();
  IntColumn get questionCount => integer().nullable()();
  IntColumn get correctCount => integer().nullable()();
}

/// Empty in this version (spec Out of Scope: question content); present so
/// the question-answering feature adds rows, not a migration.
@DataClassName('QuestionAttemptRow')
class QuestionAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get templateId => text()();
  IntColumn get level => integer().check(level.isBetweenValues(1, 5))();
  TextColumn get questionText => text()();
  RealColumn get expectedAnswer => real()();
  RealColumn get givenAnswer => real().nullable()();
  BoolColumn get isCorrect => boolean()();
  RealColumn get answerSeconds => real()();
  DateTimeColumn get answeredAt => dateTime()();
}
