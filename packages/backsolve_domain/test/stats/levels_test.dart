import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

Category category(int level, {int order = 0}) => Category(
  id: 'c$order',
  name: 'C$order',
  displayOrder: order,
  level: DifficultyLevel.fromNumber(level),
  accuracy: 70,
  avgAnswerSeconds: 6,
  levelHistory: const [],
);

List<Category> categories(List<int> levels) => [
  for (var i = 0; i < levels.length; i++) category(levels[i], order: i),
];

void main() {
  group('overallLevel', () {
    test('rounds the mean half up: [5,4,3,4,2,3,4,3] is L4', () {
      // mean 3.5 → 4 (FR-035)
      expect(
        overallLevel(categories([5, 4, 3, 4, 2, 3, 4, 3])),
        DifficultyLevel.l4,
      );
    });

    test('rounds down below .5', () {
      // mean 3.25 → 3
      expect(overallLevel(categories([3, 3, 3, 4])), DifficultyLevel.l3);
    });

    test('all-equal levels return that level', () {
      for (var n = 1; n <= 5; n++) {
        expect(
          overallLevel(categories([n, n, n])),
          DifficultyLevel.fromNumber(n),
        );
      }
    });

    test('throws ArgumentError on an empty iterable', () {
      expect(() => overallLevel(const []), throwsArgumentError);
    });
  });

  group('startLevelFor', () {
    test('a single category yields its own level', () {
      expect(startLevelFor([category(2)]), DifficultyLevel.l2);
      expect(startLevelFor([category(5)]), DifficultyLevel.l5);
    });

    test('uses the rounded mean for several categories', () {
      // L2 + L5 → 3.5 → L4 (quickstart step 11)
      expect(startLevelFor(categories([2, 5])), DifficultyLevel.l4);
      // 2 + 3 → 2.5 → L3
      expect(startLevelFor(categories([2, 3])), DifficultyLevel.l3);
    });

    test('throws ArgumentError on an empty iterable', () {
      expect(() => startLevelFor(const []), throwsArgumentError);
    });
  });
}
