import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_providers.dart';

/// Which Session Setup entry point a preset describes: the `mode` query
/// parameter plus the `category` id when [kind] is [PresetKind.category].
/// A record, so it has value equality and can key the Riverpod families
/// (contracts/repositories.md "Riverpod wiring").
typedef PresetKey = ({PresetKind kind, String? categoryId});

/// The [SessionPreset] for a [PresetKey] — title, category set and default
/// configuration — derived from the stored categories (FR-019, data-model.md
/// "SessionPreset"). Loading until the categories have emitted; an unknown
/// category id is an [AsyncError] rather than a crash.
final sessionPresetProvider =
    Provider.family<AsyncValue<SessionPreset>, PresetKey>((ref, key) {
      final categories = ref.watch(categoriesProvider);
      if (categories.hasError) {
        return AsyncValue.error(categories.error!, categories.stackTrace!);
      }
      if (!categories.hasValue) return const AsyncValue.loading();
      try {
        return AsyncValue.data(_presetFor(key, categories.requireValue));
      } catch (error, stackTrace) {
        return AsyncValue.error(error, stackTrace);
      }
    });

/// Builds the preset from [categories] (already in display order).
SessionPreset _presetFor(PresetKey key, List<Category> categories) {
  switch (key.kind) {
    case PresetKind.category:
      final category = categories
          .where((category) => category.id == key.categoryId)
          .firstOrNull;
      if (category == null) {
        throw ArgumentError.value(
          key.categoryId,
          'categoryId',
          'not a stored category',
        );
      }
      return SessionPreset(
        kind: key.kind,
        title: category.name,
        categoryIds: [category.id],
        defaultConfig: SessionConfig.defaultsFor(
          categoryIds: [category.id],
          startLevel: category.level,
          presetKind: key.kind,
        ),
      );

    case PresetKind.all:
      return _mixedPreset(key.kind, 'All categories', categories);

    // Temporarily the whole category set; T087 narrows it to the three
    // weakest categories (FR-024).
    case PresetKind.weakest:
      return _mixedPreset(key.kind, 'Weakest categories', categories);

    // No categories yet, so no default configuration (FR-020).
    case PresetKind.custom:
      return SessionPreset(
        kind: key.kind,
        title: 'Custom session',
        categoryIds: const [],
        defaultConfig: null,
      );
  }
}

/// A preset over every one of [categories], starting at the overall level
/// (FR-035).
SessionPreset _mixedPreset(
  PresetKind kind,
  String title,
  List<Category> categories,
) {
  final ids = [for (final category in categories) category.id];
  return SessionPreset(
    kind: kind,
    title: title,
    categoryIds: ids,
    defaultConfig: SessionConfig.defaultsFor(
      categoryIds: ids,
      startLevel: overallLevel(categories),
      presetKind: kind,
    ),
  );
}
