import 'dart:convert';
import 'dart:io';

import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand_image_utils.dart';

/// The iOS app icons (SC-003, FR-009…FR-011; contracts/brand-checks.md §4):
/// the icon master at every size the pre-feature `Contents.json` lists,
/// without an alpha channel, with that `Contents.json` and the Xcode project
/// left exactly as they were.
void main() {
  const appIconSet = '$kIosRunner/Assets.xcassets/AppIcon.appiconset';

  /// The pre-feature `Contents.json`, in order: (size, idiom, scale).
  const entries = [
    ('20x20', 'iphone', 2),
    ('20x20', 'iphone', 3),
    ('29x29', 'iphone', 1),
    ('29x29', 'iphone', 2),
    ('29x29', 'iphone', 3),
    ('40x40', 'iphone', 2),
    ('40x40', 'iphone', 3),
    ('60x60', 'iphone', 2),
    ('60x60', 'iphone', 3),
    ('20x20', 'ipad', 1),
    ('20x20', 'ipad', 2),
    ('29x29', 'ipad', 1),
    ('29x29', 'ipad', 2),
    ('40x40', 'ipad', 1),
    ('40x40', 'ipad', 2),
    ('76x76', 'ipad', 1),
    ('76x76', 'ipad', 2),
    ('83.5x83.5', 'ipad', 2),
    ('1024x1024', 'ios-marketing', 1),
  ];
  String fileName(String size, int scale) => 'Icon-App-$size@${scale}x.png';

  /// The distinct files, each with its pixel size (size × scale).
  final files = {
    for (final (size, _, scale) in entries)
      fileName(size, scale): (double.parse(size.split('x').first) * scale)
          .round(),
  };

  late Rgba iconMaster;

  setUpAll(() async {
    iconMaster = await decodeRgba(kIconMaster);
  });

  test('4.1 FR-011: Contents.json lists the 19 pre-feature entries', () {
    final json =
        jsonDecode(File('$appIconSet/Contents.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(
      [
        for (final image in json['images'] as List)
          (image['size'], image['idiom'], image['filename'], image['scale']),
      ],
      [
        for (final (size, idiom, scale) in entries)
          (size, idiom, fileName(size, scale), '${scale}x'),
      ],
    );
  });

  test('4.2 SC-003: 15 distinct icon files, each present', () {
    final json =
        jsonDecode(File('$appIconSet/Contents.json').readAsStringSync())
            as Map<String, dynamic>;
    final names = {
      for (final image in json['images'] as List) image['filename'] as String,
    };
    expect(names, hasLength(15));
    for (final name in names) {
      expect(
        File('$appIconSet/$name').existsSync(),
        isTrue,
        reason: '$appIconSet/$name is missing',
      );
    }
  });

  for (final MapEntry(key: name, value: px) in files.entries) {
    final path = '$appIconSet/$name';

    test('4.3 FR-009/010: $name is $px px, 8-bit, no alpha', () {
      final header = readPngHeader(path);
      expect(
        [header.width, header.height, header.bitDepth],
        [px, px, 8],
        reason: '$path: width, height, bit depth',
      );
      expect(
        header.colorType,
        anyOf(2, 0),
        reason: '$path: colour type (2 RGB or 0 grey, without alpha)',
      );
      expect(header.hasTrns, isFalse, reason: '$path has a tRNS chunk');
    });

    test('4.4 SC-003: $name is the icon master', () async {
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

  test('4.5 SC-007: the icon set holds exactly those 15 PNGs', () {
    expect(pngPathsUnder(appIconSet), files.keys.toSet());
  });

  test('4.6 project.pbxproj keeps its asset-symbol build setting', () {
    const path = 'ios/Runner.xcodeproj/project.pbxproj';
    const setting =
        'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS';
    final text = File(path).readAsStringSync();
    // Profile, Debug and Release; flutter_launcher_icons rewrites the value
    // to AppIcon (research R-03).
    expect(
      '$setting = YES;'.allMatches(text).length,
      3,
      reason: '$path: "$setting = YES;"',
    );
    expect(text, isNot(contains('$setting = AppIcon;')), reason: path);
  });
}
