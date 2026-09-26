import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'brand_image_utils.dart';

/// The Android launch screen (FR-012…FR-014, FR-017; contracts/brand-checks.md
/// §3): the rounded app-icon tile on #034A4A, through the Android 12+ splash
/// styles (light and night) and the pre-12 launch drawable. `NormalTheme` is
/// left as the Flutter template has it (research R-06). The inventory check
/// is the §3.2 half of contract check 2.7; android_icon_test has the rest.
void main() {
  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };

  /// brand-assets.md §3.2 (launch screen).
  final launchPngs = {
    for (final d in densities.keys) ...[
      'drawable-$d/splash.png',
      'drawable-$d/android12splash.png',
      'drawable-night-$d/android12splash.png',
    ],
    'drawable/background.png',
    'drawable-v21/background.png',
  };
  const launchXml = [
    'drawable/launch_background.xml',
    'drawable-v21/launch_background.xml',
    'values/styles.xml',
    'values-night/styles.xml',
    'values-v31/styles.xml',
    'values-night-v31/styles.xml',
  ];

  late Rgba iconMaster;

  setUpAll(() async {
    iconMaster = await decodeRgba(kIconMaster);
  });

  /// The resource file [path] (relative to res/), without XML comments: the
  /// Flutter template's comments hold a commented-out `<bitmap>`.
  String readXml(String path) => File(
    '$kAndroidRes/$path',
  ).readAsStringSync().replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

  /// The body of `<style name="[name]" …>…</style>` in the styles file at
  /// [path].
  String style(String path, String name) {
    final body = RegExp(
      '<style\\s+name="$name"[^>]*>(.*?)</style>',
      dotAll: true,
    ).firstMatch(readXml(path))?.group(1);
    if (body == null) fail('$path has no $name style');
    return body;
  }

  /// The trimmed value of `<item name="[name]">…</item>` in a style body.
  String? item(String style, String name) => RegExp(
    '<item\\s+name="$name"\\s*>\\s*([^<]*?)\\s*</item>',
  ).firstMatch(style)?.group(1);

  /// The value of attribute [name] among an element's [attributes].
  String? attribute(String attributes, String name) =>
      RegExp('(?:^|\\s)$name="([^"]*)"').firstMatch(attributes)?.group(1);

  for (final folder in ['values-v31', 'values-night-v31']) {
    test('3.1 FR-012/013: $folder LaunchTheme shows the tile on #034A4A', () {
      final path = '$folder/styles.xml';
      final launch = style(path, 'LaunchTheme');
      final background = item(launch, 'android:windowSplashScreenBackground');
      final hex = RegExp(
        r'^#([0-9A-Fa-f]{6})$',
      ).firstMatch(background ?? '')?.group(1);
      expect(
        hex == null ? null : int.parse('FF$hex', radix: 16),
        kLaunchBackground.toARGB32(),
        reason: '$path: windowSplashScreenBackground is $background',
      );
      expect(
        item(launch, 'android:windowSplashScreenAnimatedIcon'),
        '@drawable/android12splash',
        reason: '$path: windowSplashScreenAnimatedIcon',
      );
      expect(
        readXml(path),
        isNot(contains('windowSplashScreenIconBackgroundColor')),
        reason: '$path: no icon background behind the tile',
      );
    });
  }

  for (final folder in ['values', 'values-night']) {
    test('3.2 FR-014: $folder LaunchTheme uses the launch drawable', () {
      final path = '$folder/styles.xml';
      expect(
        item(style(path, 'LaunchTheme'), 'android:windowBackground'),
        '@drawable/launch_background',
        reason: '$path: LaunchTheme windowBackground',
      );
      expect(
        item(style(path, 'NormalTheme'), 'android:windowBackground'),
        '?android:colorBackground',
        reason: '$path: NormalTheme stays untouched (research R-06)',
      );
    });
  }

  for (final folder in ['drawable', 'drawable-v21']) {
    test('3.3 FR-014: $folder layers the tile on a #034A4A fill', () async {
      final path = '$folder/launch_background.xml';
      final bitmaps = [
        for (final m in RegExp(r'<bitmap\b([^>]*)>').allMatches(readXml(path)))
          m.group(1)!,
      ];
      expect(bitmaps, hasLength(2), reason: '$path: <bitmap> layers');
      expect(
        [
          for (final b in bitmaps) ...[
            attribute(b, 'android:src'),
            attribute(b, 'android:gravity'),
          ],
        ],
        ['@drawable/background', 'fill', '@drawable/splash', 'center'],
        reason: '$path: src and gravity of each layer',
      );

      final png = '$kAndroidRes/$folder/background.png';
      final header = readPngHeader(png);
      expect([header.width, header.height], [1, 1], reason: png);
      expectPixelNear(
        await decodeRgba(png),
        0,
        0,
        kLaunchBackground,
        tolerance: 0,
        reason: png,
      );
    });
  }

  for (final MapEntry(key: d, value: scale) in densities.entries) {
    final px = (288 * scale).round();
    for (final name in ['splash', 'android12splash']) {
      test('3.4 FR-012/014: drawable-$d/$name.png is the tile', () async {
        final path = '$kAndroidRes/drawable-$d/$name.png';
        final header = readPngHeader(path);
        expect([header.width, header.height], [px, px], reason: path);
        expectLaunchTile(await decodeRgba(path), iconMaster, path: path);
      });
    }

    test('3.4 drawable-night-$d/android12splash.png is the day image', () {
      final night = File('$kAndroidRes/drawable-night-$d/android12splash.png');
      final day = File('$kAndroidRes/drawable-$d/android12splash.png');
      expect(
        night.readAsBytesSync(),
        day.readAsBytesSync(),
        reason: '${night.path} differs from ${day.path}',
      );
    });
  }

  test('3.5 FR-017: the tile is 96 dp before and after Android 12', () async {
    const pre12 = '$kAndroidRes/drawable-mdpi/splash.png';
    const android12 = '$kAndroidRes/drawable-xxxhdpi/android12splash.png';
    // mdpi: 1 px = 1 dp. Android 12+ shows the 1152 px image in 288 dp.
    expect(
      opaqueSpan(await decodeRgba(pre12)),
      inInclusiveRange(95, 97),
      reason: '$pre12: tile width in dp',
    );
    expect(
      opaqueSpan(await decodeRgba(android12)) * 288 / 1152,
      inInclusiveRange(95, 97),
      reason: '$android12: tile width in dp',
    );
  });

  test('2.7 SC-007: every launch resource exists, and no dark or '
      'monochrome extras', () {
    final files = {
      for (final e in Directory(kAndroidRes).listSync(recursive: true))
        if (e is File)
          e.path.substring(kAndroidRes.length + 1).replaceAll(r'\', '/'),
    };
    expect(
      {...launchPngs, ...launchXml}.difference(files),
      isEmpty,
      reason: 'brand-assets.md §3.2 files missing from $kAndroidRes',
    );
    expect(
      files.where(
        RegExp(
          r'^drawable-night[^/]*/(splash\.png|background\.png|launch_background\.xml)$',
        ).hasMatch,
      ),
      isEmpty,
      reason: 'no dark launch resources: there are no *_dark keys (R-04)',
    );
    expect(
      files.where((f) => f.contains('monochrome')),
      isEmpty,
      reason: 'no monochrome resources (FR-022)',
    );
  });
}
