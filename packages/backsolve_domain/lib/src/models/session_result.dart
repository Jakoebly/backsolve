/// The outcome of a completed session (FR-028). Value type.
final class SessionResult {
  const SessionResult({
    required this.accuracy,
    required this.avgAnswerSeconds,
    required this.questionCount,
    required this.correctCount,
  }) : assert(
         accuracy >= 0 && accuracy <= 100,
         'accuracy must be between 0 and 100',
       ),
       assert(avgAnswerSeconds > 0, 'avgAnswerSeconds must be positive'),
       assert(questionCount >= 1, 'questionCount must be at least 1'),
       assert(
         correctCount >= 0 && correctCount <= questionCount,
         'correctCount must be between 0 and questionCount',
       );

  /// Percentage of correct answers, 0–100.
  final double accuracy;

  /// Average answer time in seconds, > 0.
  final double avgAnswerSeconds;

  /// Questions answered, at least 1.
  final int questionCount;

  /// Correct answers, 0..[questionCount].
  final int correctCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResult &&
          other.accuracy == accuracy &&
          other.avgAnswerSeconds == avgAnswerSeconds &&
          other.questionCount == questionCount &&
          other.correctCount == correctCount;

  @override
  int get hashCode =>
      Object.hash(accuracy, avgAnswerSeconds, questionCount, correctCount);

  @override
  String toString() =>
      'SessionResult(accuracy: $accuracy, avgAnswerSeconds: $avgAnswerSeconds, '
      'questionCount: $questionCount, correctCount: $correctCount)';
}
