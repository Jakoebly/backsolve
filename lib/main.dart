import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database/app_database.dart';
import 'data/seed/seeder.dart';
import 'presentation/providers/database_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = openAppDatabase();
  // Seed once, before the first frame, so Home and Practice are fully
  // populated on a fresh install (FR-029–FR-031, SC-001).
  await Seeder(db).seedIfEmpty();

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const BacksolveApp(),
    ),
  );
}
