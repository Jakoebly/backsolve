import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

Category category({
  required int order,
  required double accuracy,
  int level = 3,
  String? name,
}) => Category(
  id: 'c$order',
  name: name ?? 'C$order',
  displayOrder: order,
  level: DifficultyLevel.fromNumber(level),
  accuracy: accuracy,
  avgAnswerSeconds: 6,
  levelHistory: const [],
);

List<String> idsOf(Iterable<Category> categories) => [
  for (final category in categories) category.id,
];

List<String> namesOf(Iterable<Category> categories) => [
  for (final category in categories) category.name,
];

/// The eight seeded categories (T037 `lib/data/seed/seed_data.dart`), each
/// with the registry's name and display order. The accuracies and levels are
/// repeated here because the seed table lives in the app, not the domain.
List<Category> seeded() {
  const stats = <String, ({int level, double accuracy})>{
    'percentages': (level: 5, accuracy: 91),
    'multiplication': (level: 4, accuracy: 84),
    'division_ratios': (level: 3, accuracy: 72),
    'fractions_percent': (level: 4, accuracy: 80),
    'growth_cagr': (level: 2, accuracy: 61),
    'margins_breakeven': (level: 3, accuracy: 68),
    'big_numbers': (level: 4, accuracy: 83),
    'estimation': (level: 3, accuracy: 70),
  };
  return [
    for (final definition in categoryRegistry)
      Category(
        id: definition.id,
        name: definition.name,
        displayOrder: definition.displayOrder,
        level: DifficultyLevel.fromNumber(stats[definition.id]!.level),
        accuracy: stats[definition.id]!.accuracy,
        avgAnswerSeconds: 6,
        levelHistory: const [],
      ),
  ];
}

void main() {
  group('weakestCategories', () {
    test('picks the three lowest accuracies, in display order', () {
      final categories = [
        category(order: 0, accuracy: 91),
        category(order: 1, accuracy: 61),
        category(order: 2, accuracy: 84),
        category(order: 3, accuracy: 68),
        category(order: 4, accuracy: 70),
      ];

      expect(idsOf(weakestCategories(categories)), ['c1', 'c3', 'c4']);
    });

    test('the input order does not matter', () {
      final categories = [
        category(order: 4, accuracy: 70),
        category(order: 0, accuracy: 91),
        category(order: 3, accuracy: 68),
        category(order: 2, accuracy: 84),
        category(order: 1, accuracy: 61),
      ];

      expect(idsOf(weakestCategories(categories)), ['c1', 'c3', 'c4']);
    });

    test('on equal accuracy the lower level is weaker', () {
      final categories = [
        category(order: 0, accuracy: 70, level: 2),
        category(order: 1, accuracy: 70, level: 5),
        category(order: 2, accuracy: 70, level: 1),
        category(order: 3, accuracy: 70, level: 4),
      ];

      // L1, L2, L4 are taken; the L5 category (c1) is dropped.
      expect(idsOf(weakestCategories(categories)), ['c0', 'c2', 'c3']);
    });

    test('on equal accuracy and level the lower display order is weaker', () {
      final categories = [
        category(order: 0, accuracy: 70, level: 3),
        category(order: 1, accuracy: 70, level: 3),
        category(order: 2, accuracy: 70, level: 3),
        category(order: 3, accuracy: 70, level: 3),
      ];

      expect(idsOf(weakestCategories(categories)), ['c0', 'c1', 'c2']);
    });

    test('accuracy outranks level', () {
      final categories = [
        // The weakest level, but the best accuracy.
        category(order: 0, accuracy: 95, level: 1),
        category(order: 1, accuracy: 60, level: 5),
        category(order: 2, accuracy: 61, level: 5),
        category(order: 3, accuracy: 62, level: 5),
      ];

      expect(idsOf(weakestCategories(categories)), ['c1', 'c2', 'c3']);
    });

    test('all identical: the first three in display order', () {
      final categories = [
        for (var order = 0; order < 8; order++)
          category(order: order, accuracy: 70, level: 3),
      ];

      expect(idsOf(weakestCategories(categories)), ['c0', 'c1', 'c2']);
    });

    test('a count larger than the list returns the whole list', () {
      final categories = [
        category(order: 0, accuracy: 91),
        category(order: 1, accuracy: 61),
      ];

      expect(idsOf(weakestCategories(categories)), ['c0', 'c1']);
      expect(idsOf(weakestCategories(categories, count: 10)), ['c0', 'c1']);
    });

    test('an empty input returns an empty list', () {
      expect(weakestCategories(const []), isEmpty);
    });

    test('count selects how many are returned', () {
      final categories = [
        category(order: 0, accuracy: 91),
        category(order: 1, accuracy: 61),
        category(order: 2, accuracy: 84),
        category(order: 3, accuracy: 68),
      ];

      expect(weakestCategories(categories, count: 0), isEmpty);
      expect(idsOf(weakestCategories(categories, count: 1)), ['c1']);
      expect(idsOf(weakestCategories(categories, count: 2)), ['c1', 'c3']);
    });

    test('rejects a negative count', () {
      expect(
        () => weakestCategories(const [], count: -1),
        throwsArgumentError,
      );
    });

    test('does not modify the input', () {
      final categories = [
        category(order: 0, accuracy: 91),
        category(order: 1, accuracy: 61),
        category(order: 2, accuracy: 84),
      ];

      weakestCategories(categories);

      expect(idsOf(categories), ['c0', 'c1', 'c2']);
    });

    test('the seeded values are Growth & CAGR, Margins & Breakeven, '
        'Estimation', () {
      expect(namesOf(weakestCategories(seeded())), [
        'Growth & CAGR',
        'Margins & Breakeven',
        'Estimation',
      ]);
    });
  });
}
