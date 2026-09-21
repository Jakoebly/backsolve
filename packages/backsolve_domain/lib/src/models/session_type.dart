/// How a session runs. Duration and question count are fixed in this version
/// (FR-021); display strings live in the presentation layer.
enum SessionType {
  timed,
  fixedSet,
  open;

  /// Seconds a [timed] session lasts; `null` for the other types.
  int? get durationSeconds => this == timed ? 60 : null;

  /// Questions in a [fixedSet] session; `null` for the other types.
  int? get questionCount => this == fixedSet ? 20 : null;
}
