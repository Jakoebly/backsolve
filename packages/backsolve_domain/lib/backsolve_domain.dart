/// Backsolve domain layer: pure Dart, no Flutter imports.
///
/// Source folders under `src/`:
/// - `models/`     — enums, value types, and the `Category` / `Session` records
/// - `categories/` — one `CategoryDefinition` per file plus the registry
/// - `stats/`      — calendar helpers, level rounding, derived statistics
/// - `format/`     — the spec's exact display strings
library;

export 'src/models/answer_mode.dart';
export 'src/models/category.dart';
export 'src/models/category_definition.dart';
export 'src/models/difficulty_level.dart';
export 'src/models/difficulty_setting.dart';
export 'src/models/preset_kind.dart';
export 'src/models/session.dart';
export 'src/models/session_config.dart';
export 'src/models/session_preset.dart';
export 'src/models/session_result.dart';
export 'src/models/session_type.dart';

// The registry imports the per-category files itself; nothing outside the
// domain needs the individual `<name>Category` symbols (Constitution III).
export 'src/categories/category_registry.dart';

export 'src/format/formatters.dart';
export 'src/stats/calendar.dart';
export 'src/stats/levels.dart';
export 'src/stats/home_stats.dart';
export 'src/stats/streak.dart';
export 'src/stats/weekly_summary.dart';
