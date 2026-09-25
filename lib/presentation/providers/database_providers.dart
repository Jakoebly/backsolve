import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/session_repository.dart';

/// The opened database; `main()` overrides this with the real instance.
/// This is the one presentation file that may import `AppDatabase`
/// (contracts/repositories.md "Riverpod wiring").
final appDatabaseProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError('override appDatabaseProvider in main()'),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(appDatabaseProvider)),
);

/// The wall clock; overridable in tests.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);
