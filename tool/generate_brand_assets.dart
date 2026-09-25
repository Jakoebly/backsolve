/// Regenerates every derived brand asset (the Android and iOS launcher icons
/// and launch screens) from the two masters in `assets/brand/`, and repairs
/// what the generators get wrong
/// (specs/002-app-icon-launch-screen/contracts/brand-assets.md §2).
///
/// From the repo root, after `flutter pub get`:
///
///     dart run tool/generate_brand_assets.dart
///
/// then verify with `flutter test test/brand`.
///
/// Never run `flutter_launcher_icons` or `flutter_native_splash:create`
/// directly: they rewrite Info.plist, project.pbxproj and the AppIcon
/// Contents.json (research R-03, R-04).
library;

import 'dart:convert';
import 'dart:io';

/// The two masters (FR-001).
const _masters = [
  'assets/brand/backsolve_icon_1024.png',
  'assets/brand/backsolve_glyph_1024.png',
];

const _appIconSet = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

/// Files the generators rewrite although the spec requires them unchanged
/// (data-model §5). Their bytes are restored after the generators run.
const _guardedFiles = [
  'ios/Runner/Info.plist',
  'ios/Runner.xcodeproj/project.pbxproj',
  '$_appIconSet/Contents.json',
  'ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json',
];

/// The generators, in order, each run as `dart run <args>`.
const List<List<String>> _generators = [
  ['flutter_launcher_icons'],
];

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) _fail('run from the repo root');

  // Step 1: both masters exist.
  for (final master in _masters) {
    if (!File(master).existsSync()) _fail('missing master $master');
  }

  // Step 3: snapshot the guarded files.
  final guarded = <String, List<int>>{};
  for (final path in _guardedFiles) {
    final file = File(path);
    if (!file.existsSync()) _fail('missing guarded file $path');
    guarded[path] = file.readAsBytesSync();
  }

  // Step 4: run the generators, stopping at the first failure. Step 5
  // restores the guarded files even then.
  String? failure;
  try {
    for (final args in _generators) {
      final code = await _run(args);
      if (code != 0) {
        failure = '`dart run ${args.join(' ')}` exited with $code';
        break;
      }
    }
  } finally {
    for (final entry in guarded.entries) {
      File(entry.key).writeAsBytesSync(entry.value, flush: true);
    }
  }
  if (failure != null) _fail(failure);

  // Step 6: delete the icons the restored Contents.json does not list, the
  // tool's legacy 50, 57 and 72 pt files (research R-03).
  final listed = _listedIcons();
  for (final file in Directory(_appIconSet).listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (name.endsWith('.png') && !listed.contains(name)) {
      file.deleteSync();
      stdout.writeln('Deleted unlisted icon $_appIconSet/$name');
    }
  }

  // Step 8.
  stdout.writeln(
    'Brand assets regenerated. Verify with: flutter test test/brand',
  );
}

/// Runs `dart run <args>` with the Dart running this script, without a
/// shell, streaming the tool's output to the console. Returns its exit code.
Future<int> _run(List<String> args) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    'run',
    ...args,
  ], mode: ProcessStartMode.inheritStdio);
  return process.exitCode;
}

/// The file names the AppIcon `Contents.json` lists.
Set<String> _listedIcons() {
  const path = '$_appIconSet/Contents.json';
  final Object? json;
  try {
    json = jsonDecode(File(path).readAsStringSync());
  } on FormatException catch (e) {
    _fail('cannot parse $path: ${e.message}');
  }
  if (json case {'images': final List<Object?> images}) {
    return {
      for (final image in images)
        if (image case {'filename': final String name}) name,
    };
  }
  _fail('$path has no images list');
}

Never _fail(String message) {
  stderr.writeln('generate_brand_assets: $message');
  exit(1);
}
