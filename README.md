# Backsolve

Mental math practice for case interviews. Backsolve drills the arithmetic a
case interview actually asks for — percentages, growth rates, margins,
estimation — and tracks accuracy and answer speed per category so practice
targets the weak spots.

The app is fully offline: everything is stored in a local SQLite database on
the device, and the release build declares no network permissions.

## Layers

The codebase is split into three layers, and dependencies only ever point
downwards:

| Layer | Path | Contents |
|---|---|---|
| Domain | `packages/backsolve_domain` | A separate **pure-Dart** package — models, the category registry, statistics and the display strings. No Flutter import, so it is testable with the Dart SDK alone. |
| Data | `lib/data` | The only place that touches the database: the Drift schema, the seeder, and the repositories that map rows to domain types. Drift types never leave this layer. |
| Presentation | `lib/presentation` | Screens, widgets, Riverpod providers, the route table and the single theme file. Reads and writes through the repositories only. |

## Commands

Install dependencies (the app and the domain package resolve separately):

```bash
flutter pub get
```

```bash
dart pub get --directory packages/backsolve_domain
```

Generate the Drift code — re-run whenever `lib/data/database/tables.dart`
changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the domain unit tests. These need the Dart SDK only: no Flutter, no
emulator. Run them **from inside the package** — from the repository root
`dart test` resolves `package:test` against the app's pubspec, which does not
declare it, and fails:

```bash
cd packages/backsolve_domain && dart test
```

Run the app's tests (data layer against in-memory SQLite, plus the widget
tests):

```bash
flutter test
```

Static analysis, expected to print `No issues found!`:

```bash
flutter analyze
```

Launch the app on a connected device or emulator:

```bash
flutter run
```
