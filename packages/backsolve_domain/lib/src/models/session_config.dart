import 'answer_mode.dart';
import 'difficulty_level.dart';
import 'difficulty_setting.dart';
import 'preset_kind.dart';
import 'session_type.dart';

/// Everything a session is configured with (FR-025). Value type.
final class SessionConfig {
  /// [categoryIds] must be non-empty (FR-020), in display order, without
  /// duplicates.
  SessionConfig({
    required this.type,
    required this.difficulty,
    required this.answerMode,
    required List<String> categoryIds,
    required this.presetKind,
  }) : assert(categoryIds.isNotEmpty, 'categoryIds must not be empty'),
       assert(
         categoryIds.toSet().length == categoryIds.length,
         'categoryIds must not contain duplicates',
       ),
       categoryIds = List.unmodifiable(categoryIds);

  /// The timed / adaptive-from-[startLevel] / exact default that every entry
  /// point pre-selects (spec Assumptions "Quick start defaults").
  static SessionConfig defaultsFor({
    required List<String> categoryIds,
    required DifficultyLevel startLevel,
    required PresetKind presetKind,
  }) {
    return SessionConfig(
      type: SessionType.timed,
      difficulty: AdaptiveDifficultySetting(startLevel),
      answerMode: AnswerMode.exact,
      categoryIds: categoryIds,
      presetKind: presetKind,
    );
  }

  final SessionType type;
  final DifficultySetting difficulty;
  final AnswerMode answerMode;

  /// Ids of the categories involved; order = display order; no duplicates.
  final List<String> categoryIds;

  /// Which entry point produced this config.
  final PresetKind presetKind;

  SessionConfig copyWith({
    SessionType? type,
    DifficultySetting? difficulty,
    AnswerMode? answerMode,
    List<String>? categoryIds,
    PresetKind? presetKind,
  }) {
    return SessionConfig(
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      answerMode: answerMode ?? this.answerMode,
      categoryIds: categoryIds ?? this.categoryIds,
      presetKind: presetKind ?? this.presetKind,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionConfig &&
          other.type == type &&
          other.difficulty == difficulty &&
          other.answerMode == answerMode &&
          other.presetKind == presetKind &&
          _listEquals(other.categoryIds, categoryIds);

  @override
  int get hashCode => Object.hash(
    type,
    difficulty,
    answerMode,
    presetKind,
    Object.hashAll(categoryIds),
  );

  @override
  String toString() =>
      'SessionConfig(type: $type, difficulty: $difficulty, '
      'answerMode: $answerMode, categoryIds: $categoryIds, '
      'presetKind: $presetKind)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
