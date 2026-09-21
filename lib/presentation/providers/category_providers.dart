import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';

/// All categories in display order; re-emits whenever a row changes.
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);
