import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

void main() {
  group('categoryRegistry', () {
    const expectedIds = [
      'percentages',
      'multiplication',
      'division_ratios',
      'fractions_percent',
      'growth_cagr',
      'margins_breakeven',
      'big_numbers',
      'estimation',
    ];

    // FR-017 names, in grid order.
    const expectedNames = [
      'Percentages',
      'Multiplication',
      'Division & Ratios',
      'Fractions to %',
      'Growth & CAGR',
      'Margins & Breakeven',
      'Big Numbers',
      'Estimation',
    ];

    test('has exactly the eight spec categories in spec order', () {
      expect(categoryRegistry, hasLength(8));
      expect(categoryRegistry.map((d) => d.id).toList(), expectedIds);
      expect(categoryRegistry.map((d) => d.name).toList(), expectedNames);
    });

    test('ids are unique snake_case', () {
      final ids = categoryRegistry.map((d) => d.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      final snakeCase = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final id in ids) {
        expect(id, matches(snakeCase), reason: '"$id" is not snake_case');
        expect(CategoryDefinition.isSnakeCase(id), isTrue);
      }
    });

    test('displayOrder equals the index in the registry', () {
      for (var i = 0; i < categoryRegistry.length; i++) {
        expect(
          categoryRegistry[i].displayOrder,
          i,
          reason: '${categoryRegistry[i].id} is at index $i',
        );
      }
    });

    test('is unmodifiable', () {
      expect(
        () => categoryRegistry.add(
          const CategoryDefinition(id: 'x', name: 'X', displayOrder: 8),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('findCategoryDefinition', () {
    test('returns the definition for a known id', () {
      expect(findCategoryDefinition('percentages')?.name, 'Percentages');
      expect(
        findCategoryDefinition('margins_breakeven')?.name,
        'Margins & Breakeven',
      );
    });

    test('returns null for an unknown id', () {
      expect(findCategoryDefinition('nope'), isNull);
      expect(findCategoryDefinition(''), isNull);
    });
  });
}
