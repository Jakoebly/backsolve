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

/// Starting a session straight from a quick start card, with no trip
/// through Session Setup (FR-011, FR-014).
final class QuickStart {
  const QuickStart(this._ref);

  final Ref _ref;

  /// Persists an unfinished session with [preset]'s default configuration —
  /// timed / adaptive / exact over its categories (spec Assumptions "Quick
  /// start defaults") — and returns it as stored.
  ///
  /// Throws an [ArgumentError] for a preset without defaults, which is only
  /// [PresetKind.custom]: it has no categories yet, so there is nothing to
  /// start (FR-020).
  Future<Session> start(SessionPreset preset) {
    final config = preset.defaultConfig;
    if (config == null) {
      throw ArgumentError.value(
        preset,
        'preset',
        'has no default configuration to start',
      );
    }
    return _ref
        .read(sessionRepositoryProvider)
        .start(config, startedAt: _ref.read(clockProvider)());
  }
}

final quickStartProvider = Provider<QuickStart>(QuickStart.new);
