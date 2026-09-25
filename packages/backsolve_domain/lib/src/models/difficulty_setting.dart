import 'difficulty_level.dart';

/// The difficulty a session is configured with: either adaptive from a start
/// level, or fixed at one level. Value type.
sealed class DifficultySetting {
  const DifficultySetting();
}

/// Adaptive difficulty starting at [startLevel]; the transition policy itself
/// is deferred to the question-answering feature (research.md R-03).
final class AdaptiveDifficultySetting extends DifficultySetting {
  const AdaptiveDifficultySetting(this.startLevel);

  final DifficultyLevel startLevel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveDifficultySetting && other.startLevel == startLevel;

  @override
  int get hashCode => Object.hash(runtimeType, startLevel);

  @override
  String toString() => 'AdaptiveDifficultySetting(startLevel: $startLevel)';
}

/// Every question is asked at [level].
final class FixedDifficultySetting extends DifficultySetting {
  const FixedDifficultySetting(this.level);

  final DifficultyLevel level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedDifficultySetting && other.level == level;

  @override
  int get hashCode => Object.hash(runtimeType, level);

  @override
  String toString() => 'FixedDifficultySetting(level: $level)';
}
