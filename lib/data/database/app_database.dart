import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The single local SQLite database (Constitution II). Only files under
/// `lib/data/` may import this.
@DriftDatabase(tables: [Categories, Sessions, QuestionAttempts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Opens the on-device database (`backsolve.sqlite` in the app support
/// directory on Android and iOS — research.md R-12).
AppDatabase openAppDatabase() => AppDatabase(driftDatabase(name: 'backsolve'));
