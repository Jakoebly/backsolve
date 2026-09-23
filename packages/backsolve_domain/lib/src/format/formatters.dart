import '../models/answer_mode.dart';
import '../models/difficulty_level.dart';
import '../models/difficulty_setting.dart';
import '../models/session_config.dart';
import '../models/session_type.dart';

/// The spec's exact display strings (contracts/domain-api.md "Formatting
/// helpers"). Kept in the domain so the wording is unit-tested once.

/// U+2212 MINUS SIGN, used for negative deltas (FR-008, FR-009).
const String minusSign = '−';

/// "82%"
String formatAccuracy(int pct) => '$pct%';

/// "5.8s"
String formatSeconds(double s) => '${s.toStringAsFixed(1)}s';

/// "+5 this week" / "−3 this week" (FR-008). Zero is "+0 this week".
String formatAccuracyDelta(int d) =>
    '${d < 0 ? minusSign : '+'}${d.abs()} this week';

/// "−0.6s this week" / "+0.4s this week" (FR-009); negative means faster.
/// The sign is decided after rounding to one decimal, so a delta that rounds
/// to zero reads "+0.0s this week".
String formatSpeedDelta(double d) {
  final rounded = (d * 10).round() / 10;
  final sign = rounded < 0 ? minusSign : '+';
  return '$sign${rounded.abs().toStringAsFixed(1)}s this week';
}

/// "L4"
String formatLevel(DifficultyLevel l) => 'L${l.number}';

/// "60 seconds · adaptive · L4" — the Home quick start summary (FR-011). The
/// level is the adaptive start level or the fixed level of [c]'s difficulty.
String quickStartSummary(SessionConfig c) =>
    '${_typeLong(c.type)} · ${_difficultyWord(c.difficulty)} · '
    '${formatLevel(_levelOf(c.difficulty))}';

/// "60s · adaptive · exact" — the Practice settings chip (FR-013).
String settingsChip(SessionConfig c) =>
    '${_typeShort(c.type)} · ${_difficultyWord(c.difficulty)} · '
    '${_answerModeWord(c.answerMode)}';

/// The Difficulty helper line (FR-022).
///
/// Both variants are written short enough to render on a **single line**
/// on a phone (52 and 48 characters ≈ 286 and 256 dp in Roboto 12, against
/// the ~305 dp a 360 dp-wide screen leaves between the screen padding), so
/// the block keeps its height whichever difficulty is selected. Keep any
/// edit within that budget — `formatters_test.dart` guards the length.
String difficultyHelper(DifficultySetting s) => switch (s) {
  AdaptiveDifficultySetting(:final startLevel) =>
    'Starts at ${formatLevel(startLevel)}, '
        'Fast/right moves up, wrong moves down.',
  FixedDifficultySetting(:final level) =>
    'Every question is at ${formatLevel(level)}. '
        'Never moves up or down.',
};

/// The Answers helper line (FR-023).
String answerModeHelper(AnswerMode m) => switch (m) {
  AnswerMode.exact => 'Answers must match exactly.',
  AnswerMode.estimation =>
    'Answers must match within ±2% of the actual answer.',
};

String _typeLong(SessionType type) => switch (type) {
  SessionType.timed => '${type.durationSeconds} seconds',
  SessionType.fixedSet => '${type.questionCount} questions',
  SessionType.open => 'open',
};

String _typeShort(SessionType type) => switch (type) {
  SessionType.timed => '${type.durationSeconds}s',
  SessionType.fixedSet => '${type.questionCount} questions',
  SessionType.open => 'open',
};

String _difficultyWord(DifficultySetting s) => switch (s) {
  AdaptiveDifficultySetting() => 'adaptive',
  FixedDifficultySetting(:final level) => formatLevel(level),
};

DifficultyLevel _levelOf(DifficultySetting s) => switch (s) {
  AdaptiveDifficultySetting(:final startLevel) => startLevel,
  FixedDifficultySetting(:final level) => level,
};

String _answerModeWord(AnswerMode m) => switch (m) {
  AnswerMode.exact => 'exact',
  AnswerMode.estimation => 'estimation',
};
