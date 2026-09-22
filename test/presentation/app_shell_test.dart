import 'package:backsolve/app.dart';
import 'package:backsolve/data/database/app_database.dart';
import 'package:backsolve/data/seed/seeder.dart';
import 'package:backsolve/presentation/providers/database_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test for the foundation shell (T051/T052): launches the real app
/// on a seeded in-memory database and exercises the bottom bar.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await Seeder(db, now: () => DateTime(2026, 9, 16, 15, 30)).seedIfEmpty();
  });

  tearDown(() => db.close());

  /// Pumps the app, runs [body], then disposes the tree and pumps once more
  /// so drift's stream-cleanup timer fires inside the test zone.
  Future<void> inApp(WidgetTester tester, Future<void> Function() body) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const BacksolveApp(),
      ),
    );
    await tester.pumpAndSettle();
    try {
      await body();
    } finally {
      await tester.pumpWidget(const SizedBox());
      // A duration is needed: a plain pump() only flushes microtasks and
      // would leave the zero-duration cleanup timers queued.
      await tester.pump(const Duration(milliseconds: 1));
    }
  }

  testWidgets('launches on Home with the three-tab bar (FR-001, FR-002)', (
    tester,
  ) async {
    await inApp(tester, () async {
      expect(find.text('Backsolve'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });
  });

  testWidgets('Practice switches branch and back (FR-002)', (tester) async {
    await inApp(tester, () async {
      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      expect(find.text('Practice'), findsNWidgets(2), reason: 'title + tab');
      expect(find.text('Backsolve'), findsNothing);

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Backsolve'), findsOneWidget);
    });
  });

  testWidgets('Progress shows the coming-soon sheet and stays on Home '
      '(FR-003)', (tester) async {
    await inApp(tester, () async {
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('Progress is coming soon'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('Progress is coming soon'), findsNothing);
      expect(find.text('Backsolve'), findsOneWidget);
    });
  });
}
