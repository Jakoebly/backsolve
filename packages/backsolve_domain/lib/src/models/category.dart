import 'difficulty_level.dart';

/// One dated entry of a level history.
final class LevelChange {
  const LevelChange({required this.at, required this.level});

  final DateTime at;
  final DifficultyLevel level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelChange && other.at == at && other.level == level;

  @override
  int get hashCode => Object.hash(at, level);

  @override
  String toString() => 'LevelChange(at: $at, level: $level)';
}

/// The persisted state of a practice category (FR-027).
final class Category {
  Category({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.level,
    required this.accuracy,
    required this.avgAnswerSeconds,
    required List<LevelChange> levelHistory,
  }) : assert(
         accuracy >= 0 && accuracy <= 100,
         'accuracy must be between 0 and 100',
       ),
       assert(avgAnswerSeconds > 0, 'avgAnswerSeconds must be positive'),
       levelHistory = List.unmodifiable(levelHistory);

  /// Equals the registry definition id.
  final String id;

  /// Copied from the definition at seed time.
  final String name;

  /// Copied from the definition at seed time.
  final int displayOrder;

  /// The stored level.
  final DifficultyLevel level;

  /// Percentage of correct answers, 0–100.
  final double accuracy;

  /// Average answer time in seconds, > 0.
  final double avgAnswerSeconds;

  /// Dated level changes ordered by [LevelChange.at] ascending; the last
  /// entry equals [level].
  final List<LevelChange> levelHistory;

  Category copyWith({
    String? id,
    String? name,
    int? displayOrder,
    DifficultyLevel? level,
    double? accuracy,
    double? avgAnswerSeconds,
    List<LevelChange>? levelHistory,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      level: level ?? this.level,
      accuracy: accuracy ?? this.accuracy,
      avgAnswerSeconds: avgAnswerSeconds ?? this.avgAnswerSeconds,
      levelHistory: levelHistory ?? this.levelHistory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          other.id == id &&
          other.name == name &&
          other.displayOrder == displayOrder &&
          other.level == level &&
          other.accuracy == accuracy &&
          other.avgAnswerSeconds == avgAnswerSeconds &&
          _listEquals(other.levelHistory, levelHistory);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    displayOrder,
    level,
    accuracy,
    avgAnswerSeconds,
    Object.hashAll(levelHistory),
  );

  @override
  String toString() =>
      'Category(id: $id, name: $name, displayOrder: $displayOrder, '
      'level: $level, accuracy: $accuracy, '
      'avgAnswerSeconds: $avgAnswerSeconds, levelHistory: $levelHistory)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
