import '../models/category.dart';
import '../models/difficulty_level.dart';

/// The user's overall level: the rounded mean of the stored levels across all
/// [categories] (FR-035; `num.round()` rounds half away from zero, so 3.5 → L4).
///
/// Throws an [ArgumentError] when [categories] is empty.
DifficultyLevel overallLevel(Iterable<Category> categories) =>
    _roundedMeanLevel(categories, 'categories');

/// The adaptive start level for a session over [selected]: the rounded mean
/// of their stored levels (FR-022).
///
/// Throws an [ArgumentError] when [selected] is empty.
DifficultyLevel startLevelFor(Iterable<Category> selected) =>
    _roundedMeanLevel(selected, 'selected');

DifficultyLevel _roundedMeanLevel(Iterable<Category> categories, String name) {
  var sum = 0;
  var count = 0;
  for (final category in categories) {
    sum += category.level.number;
    count++;
  }
  if (count == 0) {
    throw ArgumentError.value(categories, name, 'must not be empty');
  }
  return DifficultyLevel.fromNumber((sum / count).round());
}
