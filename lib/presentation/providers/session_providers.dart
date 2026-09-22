import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_providers.dart';
import 'database_providers.dart';

/// All sessions, newest first, including unfinished ones; re-emits whenever
/// a row changes.
final sessionsProvider = StreamProvider<List<Session>>(
  (ref) => ref.watch(sessionRepositoryProvider).watchAll(),
);

/// Everything Home shows, recomputed whenever the categories or sessions
/// change. Loading until both streams have emitted; an error from either
/// stream (or from the derivation itself) surfaces as [AsyncError].
final homeStatsProvider = Provider<AsyncValue<HomeStats>>((ref) {
  final categories = ref.watch(categoriesProvider);
  final sessions = ref.watch(sessionsProvider);
  final clock = ref.watch(clockProvider);

  if (categories.hasError) {
    return AsyncValue.error(categories.error!, categories.stackTrace!);
  }
  if (sessions.hasError) {
    return AsyncValue.error(sessions.error!, sessions.stackTrace!);
  }
  if (!categories.hasValue || !sessions.hasValue) {
    return const AsyncValue.loading();
  }
  try {
    return AsyncValue.data(
      HomeStats.from(categories.requireValue, sessions.requireValue, clock()),
    );
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});
