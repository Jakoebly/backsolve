import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/repositories/category_repository.dart';
import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// On Windows the native sqlite3 library must be loadable for
// NativeDatabase.memory(); see the drift docs "Testing" note (a sqlite3.dll on
// PATH) — never a runtime dependency.
void main() {
  late AppDatabase db;
  late CategoryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CategoryRepository(db);
  });

  tearDown(() => db.close());

  Future<void> insert(
    String id,
    int displayOrder, {
    int level = 3,
    List<LevelChange> history = const [],
  }) {
    return db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            name: id.toUpperCase(),
            displayOrder: displayOrder,
            level: level,
            accuracy: 70,
            avgAnswerSeconds: 6.0,
            levelHistory: history,
          ),
        );
  }

  group('ordering', () {
    setUp(() async {
      await insert('third', 2);
      await insert('first', 0);
      await insert('second', 1);
    });

    test('getAll returns displayOrder ASC', () async {
      final all = await repository.getAll();
      expect(all.map((c) => c.id).toList(), ['first', 'second', 'third']);
      expect(all.map((c) => c.displayOrder).toList(), [0, 1, 2]);
    });

    test('watchAll emits displayOrder ASC and re-emits on change', () async {
      final stream = repository.watchAll();
      final first = await stream.first;
      expect(first.map((c) => c.id).toList(), ['first', 'second', 'third']);

      final updated = stream.skip(1).first;
      await repository.updateStats('second', accuracy: 99);
      expect((await updated).firstWhere((c) => c.id == 'second').accuracy, 99);
    });
  });

  group('getById', () {
    test('returns null for an unknown id', () async {
      expect(await repository.getById('nope'), isNull);
    });

    test('round-trips levelHistory sorted by at', () async {
      final newer = LevelChange(
        at: DateTime(2026, 9, 10, 12),
        level: DifficultyLevel.l3,
      );
      final older = LevelChange(
        at: DateTime(2026, 8, 1, 9, 30),
        level: DifficultyLevel.l2,
      );
      await insert('percentages', 0, level: 3, history: [newer, older]);

      final category = await repository.getById('percentages');
      expect(category, isNotNull);
      expect(category!.name, 'PERCENTAGES');
      expect(category.level, DifficultyLevel.l3);
      expect(category.accuracy, 70);
      expect(category.avgAnswerSeconds, 6.0);
      expect(category.levelHistory, [older, newer]);
    });
  });

  group('updateStats', () {
    setUp(() async {
      await insert(
        'percentages',
        0,
        level: 3,
        history: [
          LevelChange(at: DateTime(2026, 8, 1), level: DifficultyLevel.l3),
        ],
      );
    });

    test('with a new level appends exactly one LevelChange', () async {
      final at = DateTime(2026, 9, 14, 8, 30);
      await repository.updateStats(
        'percentages',
        level: DifficultyLevel.l4,
        accuracy: 81.5,
        avgAnswerSeconds: 5.1,
        at: at,
      );

      final category = (await repository.getById('percentages'))!;
      expect(category.level, DifficultyLevel.l4);
      expect(category.accuracy, 81.5);
      expect(category.avgAnswerSeconds, 5.1);
      expect(category.levelHistory, hasLength(2));
      expect(
        category.levelHistory.last,
        LevelChange(at: at, level: DifficultyLevel.l4),
      );
    });

    test('with the same level appends nothing', () async {
      await repository.updateStats(
        'percentages',
        level: DifficultyLevel.l3,
        accuracy: 75,
      );

      final category = (await repository.getById('percentages'))!;
      expect(category.level, DifficultyLevel.l3);
      expect(category.accuracy, 75);
      expect(category.avgAnswerSeconds, 6.0, reason: 'untouched');
      expect(category.levelHistory, hasLength(1));
    });

    test('without a level leaves level and history untouched', () async {
      await repository.updateStats('percentages', avgAnswerSeconds: 4.2);

      final category = (await repository.getById('percentages'))!;
      expect(category.level, DifficultyLevel.l3);
      expect(category.avgAnswerSeconds, 4.2);
      expect(category.levelHistory, hasLength(1));
    });

    test('throws ArgumentError for an unknown id', () async {
      expect(
        () => repository.updateStats('nope', accuracy: 1),
        throwsArgumentError,
      );
    });
  });
}
