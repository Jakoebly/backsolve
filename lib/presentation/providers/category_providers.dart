import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';

/// All categories in display order; re-emits whenever a row changes.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// The three categories the user is weakest at, in display order (FR-024).
/// Carries the loading and error states of [categoriesProvider].
final weakestCategoriesProvider = Provider<AsyncValue<List<Category>>>(
  (ref) => ref
      .watch(categoriesProvider)
      .whenData((categories) => weakestCategories(categories)),
);
