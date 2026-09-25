/// Route names and paths of the single declared route table
/// (contracts/routes.md, Constitution V). Screens navigate only via
/// `context.goNamed` / `context.pushNamed` with these names.
abstract final class AppRoutes {
  static const String home = 'home';
  static const String practice = 'practice';
  static const String sessionSetup = 'sessionSetup';

  static const String homePath = '/';
  static const String practicePath = '/practice';
  static const String sessionSetupPath = '/session-setup';
}

/// Query parameter keys of the `sessionSetup` route.
abstract final class SessionSetupParams {
  /// `category` | `all` | `weakest` | `custom` (a `PresetKind` name).
  static const String mode = 'mode';

  /// A registry id; required when [mode] is `category`.
  static const String category = 'category';
}
