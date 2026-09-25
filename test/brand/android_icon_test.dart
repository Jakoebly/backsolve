import 'dart:io';

import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand_image_utils.dart';

/// The Android launcher icon (SC-002, FR-004…FR-008, FR-022;
/// contracts/brand-checks.md §2): an adaptive icon, the glyph master inset
/// into the safe zone over the brand teal, plus legacy mipmaps from the icon
/// master. The inventory check is split with android_launch_screen_test
/// (§3.2 half) so that each story passes on its own.
void main() {
  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };
  const adaptiveXml = '$kAndroidRes/mipmap-anydpi-v26/ic_launcher.xml';

  /// brand-assets.md §3.1 (launcher icon) and §3.2 (launch screen) PNGs.
  final launcherPngs = {
    for (final d in densities.keys) ...[
      'mipmap-$d/ic_launcher.png',
      'drawable-$d/ic_launcher_foreground.png',
    ],
  };
  final launchPngs = {
    for (final d in densities.keys) ...[
      'drawable-$d/splash.png',
      'drawable-$d/android12splash.png',
      'drawable-night-$d/android12splash.png',
    ],
    'drawable/background.png',
    'drawable-v21/background.png',
  };

  late Rgba iconMaster;
  late Rgba glyphMaster;

  setUpAll(() async {
    iconMaster = await decodeRgba(kIconMaster);
    glyphMaster = await decodeRgba(kGlyphMaster);
  });

  /// The attributes of the `<inset>` inside `<foreground>`, or null.
  String? insetAttributes(String xml) =>
      RegExp(r'<foreground>\s*<inset\b([^>]*?)/?>').firstMatch(xml)?.group(1);

  /// The foreground inset N from `android:inset="N%"`, in percent.
  double foregroundInset() {
    final attributes = insetAttributes(File(adaptiveXml).readAsStringSync());
    final inset = attributes == null
        ? null
        : RegExp(r'android:inset="(\d+(?:\.\d+)?)%"').firstMatch(attributes);
    if (inset == null) fail('$adaptiveXml has no <foreground><inset> in %');
    return double.parse(inset.group(1)!);
  }

  test('2.1 the adaptive icon: teal colour, inset glyph, no monochrome', () {
    final xml = File(adaptiveXml).readAsStringSync();
    expect(
      xml,
      matches(
        RegExp(
          r'<background\s+android:drawable="@color/ic_launcher_background"\s*/>',
        ),
      ),
      reason: adaptiveXml,
    );
    final attributes = insetAttributes(xml);
    expect(attributes, isNotNull, reason: '$adaptiveXml: <foreground><inset>');
    expect(
      attributes,
      contains('android:drawable="@drawable/ic_launcher_foreground"'),
      reason: adaptiveXml,
    );
    expect(foregroundInset(), greaterThan(0), reason: adaptiveXml);
    expect(
      xml,
      isNot(contains('<monochrome')),
      reason: '$adaptiveXml: no monochrome layer (FR-022)',
    );
  });

  test('2.2 the adaptive background colour is AppColors.primary', () {
    const path = '$kAndroidRes/values/colors.xml';
    final match = RegExp(
      r'<color\s+name="ic_launcher_background"\s*>\s*#((?:[0-9A-Fa-f]{2})?[0-9A-Fa-f]{6})\s*</color>',
    ).firstMatch(File(path).readAsStringSync());
    expect(match, isNotNull, reason: '$path: ic_launcher_background');
    final hex = match!.group(1)!;
    expect(
      int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16),
      AppColors.primary.toARGB32(),
      reason: '$path: ic_launcher_background is #$hex',
    );
  });

  for (final MapEntry(key: d, value: scale) in densities.entries) {
    final path = '$kAndroidRes/drawable-$d/ic_launcher_foreground.png';
    final size = (108 * scale).round();

    /// The foreground at [path], after checking it is [size] px square.
    Future<Rgba> foreground() async {
      final header = readPngHeader(path);
      expect([header.width, header.height], [size, size], reason: path);
      return decodeRgba(path);
    }

    test('2.3 SC-002: $d foreground lies inside the safe zone', () async {
      final img = await foreground();
      final inset = foregroundInset();
      // The inset shrinks the 108 dp layer; in the PNG's pixels the full
      // icon canvas is therefore larger than the PNG (research R-02).
      final canvas = size / (1 - 2 * inset / 100);
      final origin = inset / 100 * canvas;
      final farthest = farthestOpaqueRadius(
        img,
        canvas: canvas,
        originX: origin,
        originY: origin,
      );
      expect(
        farthest,
        lessThanOrEqualTo(canvas * 33 / 108),
        reason:
            '$path: farthest opaque pixel ${farthest.toStringAsFixed(1)} px '
            'from the centre of a ${canvas.toStringAsFixed(1)} px canvas',
      );
    });

    test('2.4 FR-006: the $d mark spans 40–55 % of the viewport', () async {
      final img = await foreground();
      final canvas = size / (1 - 2 * foregroundInset() / 100);
      final span = opaqueSpan(img);
      expect(
        span / (canvas * 72 / 108),
        inInclusiveRange(0.40, 0.55),
        reason:
            '$path: mark $span px in a '
            '${(canvas * 72 / 108).toStringAsFixed(1)} px viewport',
      );
    });

    test('2.5 FR-002: the $d foreground is the glyph master', () async {
      final img = await foreground();
      final diff = meanAbsDiff(
        img,
        boxDownscale(glyphMaster, size),
        channels: [3],
      );
      expect(
        diff,
        lessThanOrEqualTo(kDerivedMeanTolerance),
        reason: '$path: alpha mean |Δ| against the downscaled glyph master',
      );
    });
  }

  for (final MapEntry(key: d, value: scale) in densities.entries) {
    final path = '$kAndroidRes/mipmap-$d/ic_launcher.png';
    final px = (48 * scale).round();

    test('2.6 FR-007: mipmap-$d is the icon master at $px px', () async {
      final header = readPngHeader(path);
      expect([header.width, header.height], [px, px], reason: path);
      final img = await decodeRgba(path);
      final diff = meanAbsDiff(
        img,
        boxDownscale(iconMaster, px),
        channels: [0, 1, 2],
      );
      expect(
        diff,
        lessThanOrEqualTo(kDerivedMeanTolerance),
        reason: '$path: RGB mean |Δ| against the downscaled icon master',
      );
      expectPixelNear(img, 0, 0, AppColors.primary, reason: path);
    });
  }

  final catalogued = {...launcherPngs, ...launchPngs};

  test('2.7 SC-007: every mipmap/drawable PNG is catalogued', () {
    final found = pngPathsUnder(
      kAndroidRes,
    ).where((p) => p.startsWith('mipmap-') || p.startsWith('drawable'));
    expect(
      found.toSet().difference(catalogued),
      isEmpty,
      reason: 'PNGs in $kAndroidRes outside brand-assets.md §3.1 + §3.2',
    );
  });

  test('2.7 every launcher-icon PNG (brand-assets.md §3.1) exists', () {
    expect(
      launcherPngs.difference(pngPathsUnder(kAndroidRes)),
      isEmpty,
      reason: 'missing from $kAndroidRes',
    );
  });

  test('2.8 FR-022: the manifest keeps the icon and the label', () {
    const path = 'android/app/src/main/AndroidManifest.xml';
    final xml = File(path).readAsStringSync();
    expect(xml, contains('android:icon="@mipmap/ic_launcher"'), reason: path);
    expect(xml, contains('android:label="Backsolve"'), reason: path);
  });
}
