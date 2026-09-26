/// Regenerates every derived brand asset (the Android and iOS launcher icons
/// and launch screens) from the two masters in `assets/brand/`, and repairs
/// what the generators get wrong
/// (specs/002-app-icon-launch-screen/contracts/brand-assets.md §2). It first
/// builds the launch tile, the icon master with rounded corners, because
/// neither generator can round corners.
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

import 'package:image/image.dart' as img;

/// The launch tile's side in dp (pt on iOS) on every platform, the one
/// adjustable value (research R-05). Step 2 refuses sizes whose corners
/// would cross Android 12's circular mask (above about 161).
const tileDp = 96;

/// The launch image's side in px. Android 12+ shows it in its 288 dp icon
/// view, and the splash tool treats it as @4x (a 288 dp/pt canvas) for
/// Android before 12 and iOS, so the tile has the same size everywhere
/// (FR-017).
const canvasPx = 1152;

/// The tile's corner radius over its side. Mirrors `AppSizes.appIconRadius /
/// AppSizes.appIcon` (14/52), the Home logo tile; the brand tests enforce it.
const tileRadiusRatio = 14 / 52;

/// The launch background, #034A4A (spec Clarifications 2026-09-25), which
/// the `flutter_native_splash:` config in pubspec.yaml also sets. Step 7
/// writes it into the iOS storyboard.
const launchBackgroundHex = '034A4A';

/// The two masters (FR-001). The first is the icon master.
const _masters = [
  'assets/brand/backsolve_icon_1024.png',
  'assets/brand/backsolve_glyph_1024.png',
];

/// The launch tile image the splash tool reads (see pubspec.yaml). It is
/// rebuilt on every run; `build/` is gitignored.
const _launchTile = 'build/brand/launch_tile.png';

const _appIconSet = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const _storyboard = 'ios/Runner/Base.lproj/LaunchScreen.storyboard';

/// The storyboard root view's background, [launchBackgroundHex] in sRGB,
/// verbatim from contracts/brand-assets.md §2 (step 7).
const _storyboardBackground =
    '<color key="backgroundColor" red="0.011764705882352941" '
    'green="0.29019607843137257" blue="0.29019607843137257" alpha="1" '
    'colorSpace="custom" customColorSpace="sRGB"/>';

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
  ['flutter_native_splash:create'],
];

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) _fail('run from the repo root');
  _checkStoryboardBackground();

  // Step 1: both masters exist.
  for (final master in _masters) {
    if (!File(master).existsSync()) _fail('missing master $master');
  }

  // Step 2: the launch tile, before the splash tool needs it.
  _buildLaunchTile();

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

  // Step 7: the splash tool rewrites the storyboard from its template on
  // every run and leaves the view's own background white (research R-04).
  // Anything but exactly one colour element means the template changed.
  final storyboard = File(_storyboard).readAsStringSync();
  final background = RegExp(r'<color key="backgroundColor"[^>]*/>');
  final colours = background.allMatches(storyboard).length;
  if (colours != 1) {
    _fail('$_storyboard has $colours backgroundColor elements, expected 1');
  }
  File(_storyboard).writeAsStringSync(
    storyboard.replaceFirst(background, _storyboardBackground),
  );

  // Step 8.
  stdout.writeln(
    'Brand assets regenerated. Verify with: flutter test test/brand',
  );
}

/// Fails unless [_storyboardBackground]'s components, × 255 and rounded,
/// are the bytes of [launchBackgroundHex], so the two cannot drift apart.
void _checkStoryboardBackground() {
  int byte(String component) {
    final value = RegExp(
      '$component="([^"]+)"',
    ).firstMatch(_storyboardBackground)!.group(1)!;
    return (double.parse(value) * 255).round();
  }

  final rgb = byte('red') << 16 | byte('green') << 8 | byte('blue');
  if (rgb != int.parse(launchBackgroundHex, radix: 16)) {
    _fail('the storyboard colour is not #$launchBackgroundHex');
  }
}

/// Step 2 (research R-12): the icon master scaled to `tileDp × 4` px, its
/// corners rounded like the Home logo tile with 4 × 4 supersampled coverage,
/// centred on a transparent `canvasPx` square and written to [_launchTile].
/// The pixels are copied, not composited, so their straight alpha is exact.
void _buildLaunchTile() {
  const tilePx = tileDp * 4;
  if (tilePx > canvasPx * 0.56) {
    _fail('tileDp $tileDp is too large: the tile would cross the mask');
  }
  final master = img.decodePng(File(_masters.first).readAsBytesSync());
  if (master == null) _fail('cannot decode ${_masters.first}');
  final tile = img.copyResize(
    master,
    width: tilePx,
    height: tilePx,
    interpolation: img.Interpolation.average,
  );

  const radius = tilePx * tileRadiusRatio;
  const offset = (canvasPx - tilePx) ~/ 2;
  // A fresh image is all zero, i.e. transparent.
  final canvas = img.Image(width: canvasPx, height: canvasPx, numChannels: 4);
  for (var y = 0; y < tilePx; y++) {
    for (var x = 0; x < tilePx; x++) {
      // A sample is inside when it lies within `radius` of the inner
      // square [radius, tilePx − radius]².
      var covered = 0;
      for (var j = 0; j < 4; j++) {
        for (var i = 0; i < 4; i++) {
          final dx = _outside(x + (i + 0.5) / 4, radius, tilePx - radius);
          final dy = _outside(y + (j + 0.5) / 4, radius, tilePx - radius);
          if (dx * dx + dy * dy <= radius * radius) covered++;
        }
      }
      if (covered == 0) continue;
      final p = tile.getPixel(x, y);
      canvas.setPixelRgba(
        offset + x,
        offset + y,
        p.r,
        p.g,
        p.b,
        (p.a * covered / 16).round(),
      );
    }
  }
  Directory('build/brand').createSync(recursive: true);
  File(_launchTile).writeAsBytesSync(img.encodePng(canvas));
}

/// How far [v] lies outside [lo, hi]; 0 inside.
double _outside(double v, double lo, double hi) =>
    v < lo ? lo - v : (v > hi ? v - hi : 0);

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
