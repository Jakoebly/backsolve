/// Static content for one practice category, declared in its own file under
/// `src/categories/` and listed in the registry (Constitution III).
///
/// Question templates are not part of this version (spec Out of Scope); the
/// question-answering feature adds a `templates` field here.
class CategoryDefinition {
  /// [id] must be non-empty snake_case. Only the length can be checked in a
  /// `const` constructor; the full snake_case rule is [isSnakeCase], which
  /// the registry test enforces for every registered definition.
  const CategoryDefinition({
    required this.id,
    required this.name,
    required this.displayOrder,
  }) : assert(id.length > 0, 'id must not be empty'),
       assert(displayOrder >= 0, 'displayOrder must not be negative');

  /// Stable snake_case key, also used as the storage key.
  final String id;

  /// Display name, e.g. "Margins & Breakeven".
  final String name;

  /// 0-based position in the Practice grid (== index in the registry).
  final int displayOrder;

  static final RegExp _snakeCase = RegExp(r'^[a-z][a-z0-9_]*$');

  /// Whether [id] is a valid category id: lowercase letters, digits and
  /// underscores, starting with a letter.
  static bool isSnakeCase(String id) => _snakeCase.hasMatch(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDefinition &&
          other.id == id &&
          other.name == name &&
          other.displayOrder == displayOrder;

  @override
  int get hashCode => Object.hash(id, name, displayOrder);

  @override
  String toString() =>
      'CategoryDefinition(id: $id, name: $name, displayOrder: $displayOrder)';
}
