/// The five difficulty levels a category or session can be at.
enum DifficultyLevel {
  l1,
  l2,
  l3,
  l4,
  l5;

  /// The level as shown to the user: 1 for [l1] … 5 for [l5].
  int get number => index + 1;

  /// The level whose [number] is [n].
  ///
  /// Throws an [ArgumentError] when [n] is outside 1..5.
  static DifficultyLevel fromNumber(int n) {
    if (n < 1 || n > values.length) {
      throw ArgumentError.value(n, 'n', 'must be between 1 and 5');
    }
    return values[n - 1];
  }
}
