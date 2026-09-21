import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';

/// All sessions, newest first, including unfinished ones; re-emits whenever
/// a row changes.
final sessionsProvider = StreamProvider<List<Session>>(
  (ref) => ref.watch(sessionRepositoryProvider).watchAll(),
);
