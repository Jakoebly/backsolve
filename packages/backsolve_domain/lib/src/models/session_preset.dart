import 'preset_kind.dart';
import 'session_config.dart';

/// The bundle a quick start card or Session Setup entry point represents:
/// a title, a category set, and the default configuration (derived, not
/// stored — data-model.md "Derived").
final class SessionPreset {
  /// [defaultConfig] is `null` only for [PresetKind.custom], whose
  /// [categoryIds] starts empty and therefore cannot form a [SessionConfig].
  SessionPreset({
    required this.kind,
    required this.title,
    required List<String> categoryIds,
    required this.defaultConfig,
  }) : assert(
         defaultConfig != null || kind == PresetKind.custom,
         'defaultConfig may only be null for the custom preset',
       ),
       categoryIds = List.unmodifiable(categoryIds);

  final PresetKind kind;

  /// Session Setup title (FR-019): the category name, "All categories",
  /// "Weakest categories", or "Custom session".
  final String title;

  /// Ids of the categories covered, in display order.
  final List<String> categoryIds;

  /// The timed / adaptive / exact defaults the play control starts with.
  final SessionConfig? defaultConfig;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionPreset &&
          other.kind == kind &&
          other.title == title &&
          other.defaultConfig == defaultConfig &&
          _listEquals(other.categoryIds, categoryIds);

  @override
  int get hashCode =>
      Object.hash(kind, title, defaultConfig, Object.hashAll(categoryIds));

  @override
  String toString() =>
      'SessionPreset(kind: $kind, title: $title, categoryIds: $categoryIds, '
      'defaultConfig: $defaultConfig)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
