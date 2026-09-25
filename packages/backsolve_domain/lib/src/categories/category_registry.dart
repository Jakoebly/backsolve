import '../models/category_definition.dart';
import 'big_numbers.dart';
import 'division_ratios.dart';
import 'estimation.dart';
import 'fractions_percent.dart';
import 'growth_cagr.dart';
import 'margins_breakeven.dart';
import 'multiplication.dart';
import 'percentages.dart';

/// Every registered category in Practice-grid order (FR-017).
///
/// Adding a category is exactly two changes (Constitution III): create one
/// `src/categories/<id>.dart` declaring its [CategoryDefinition] and append
/// it here. Each definition's `displayOrder` equals its index in this list
/// (enforced by `test/categories/registry_test.dart`).
final List<CategoryDefinition> categoryRegistry = List.unmodifiable([
  percentagesCategory,
  multiplicationCategory,
  divisionRatiosCategory,
  fractionsPercentCategory,
  growthCagrCategory,
  marginsBreakevenCategory,
  bigNumbersCategory,
  estimationCategory,
]);

/// The registered definition with [id], or `null` when none matches.
CategoryDefinition? findCategoryDefinition(String id) {
  for (final definition in categoryRegistry) {
    if (definition.id == id) return definition;
  }
  return null;
}
