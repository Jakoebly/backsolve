import '../models/category.dart';

/// The [count] categories the user is weakest at, returned in display order
/// (FR-024).
///
/// "Weakest" is lowest accuracy first. Ties are broken by the stored level
/// (a lower level is weaker) and then by [Category.displayOrder], so the
/// result is deterministic for any input — including the edge case where
/// every category has the same accuracy, which yields the first [count] in
/// display order.
///
/// Fewer than [count] categories returns all of them; [count] must not be
/// negative.
List<Category> weakestCategories(
  Iterable<Category> categories, {
  int count = 3,
}) {
  if (count < 0) {
    throw ArgumentError.value(count, 'count', 'must not be negative');
  }
  // `displayOrder` is the last comparison, so the ranking is total and the
  // sort needs no stability guarantee from the platform.
  final ranked = categories.toList()..sort(_byWeakness);
  return ranked.take(count).toList()..sort(_byDisplayOrder);
}

int _byWeakness(Category a, Category b) {
  final byAccuracy = a.accuracy.compareTo(b.accuracy);
  if (byAccuracy != 0) return byAccuracy;
  final byLevel = a.level.number.compareTo(b.level.number);
  if (byLevel != 0) return byLevel;
  return _byDisplayOrder(a, b);
}

int _byDisplayOrder(Category a, Category b) =>
    a.displayOrder.compareTo(b.displayOrder);
