import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'brand_image_utils.dart';

/// The iOS launch screen (SC-005, FR-015…FR-017, FR-022;
/// contracts/brand-checks.md §5): the storyboard's own background is
/// #034A4A, a 1×1 #034A4A image fills the screen, and the launch image (the
/// rounded tile at @1x/@2x/@3x) sits centred at its natural size. Info.plist
/// stays as it was.
void main() {
  const storyboard = '$kIosRunner/Base.lproj/LaunchScreen.storyboard';
  const launchImageSet = '$kIosRunner/Assets.xcassets/LaunchImage.imageset';
  const backgroundSet = '$kIosRunner/Assets.xcassets/LaunchBackground.imageset';
  const launchImages = [
    'LaunchImage.png',
    'LaunchImage@2x.png',
    'LaunchImage@3x.png',
  ];

  late Rgba iconMaster;

  setUpAll(() async {
    iconMaster = await decodeRgba(kIconMaster);
  });

  /// The value of attribute [name] among an element's [attributes].
  String? attribute(String attributes, String name) =>
      RegExp('(?:^|\\s)$name="([^"]*)"').firstMatch(attributes)?.group(1);

  /// The attributes of the storyboard's `<imageView>` showing [image].
  String imageView(String xml, String image) {
    for (final m in RegExp(r'<imageView\b([^>]*)>').allMatches(xml)) {
      if (attribute(m.group(1)!, 'image') == image) return m.group(1)!;
    }
    fail('$storyboard has no imageView with image="$image"');
  }

  /// The edges and centres by which the view [id] is pinned to the root
  /// view: each `<constraint>` relating the same attribute of both, with no
  /// offset. An omitted item is the view that holds the constraints, the
  /// root view.
  Set<String> pinned(String xml, String id) {
    final root = RegExp(
      r'<view key="view"[^>]*\sid="([^"]+)"',
    ).firstMatch(xml)?.group(1);
    final pins = <String>{};
    for (final m in RegExp(r'<constraint\b([^>]*)>').allMatches(xml)) {
      final a = m.group(1)!;
      final first = attribute(a, 'firstItem') ?? root;
      final second = attribute(a, 'secondItem') ?? root;
      final edge = attribute(a, 'firstAttribute');
      final constant = double.tryParse(attribute(a, 'constant') ?? '0');
      if (edge == null ||
          edge != attribute(a, 'secondAttribute') ||
          constant != 0) {
        continue;
      }
      if ((first == id && second == root) || (first == root && second == id)) {
        pins.add(edge);
      }
    }
    return pins;
  }

  const edges = {'leading', 'trailing', 'top', 'bottom'};

  test('5.1 FR-015/SC-005: the storyboard background is #034A4A sRGB', () {
    final colors = RegExp(
      r'<color key="backgroundColor"[^>]*/>',
    ).allMatches(File(storyboard).readAsStringSync()).toList();
    expect(colors, hasLength(1), reason: '$storyboard: backgroundColor');
    final color = colors.single.group(0)!;
    expect(
      [
        attribute(color, 'colorSpace'),
        attribute(color, 'customColorSpace'),
        attribute(color, 'alpha'),
      ],
      ['custom', 'sRGB', '1'],
      reason: '$storyboard: $color',
    );
    int? byte(String component) {
      final value = double.tryParse(attribute(color, component) ?? '');
      return value == null ? null : (value * 255).round();
    }

    expect(
      [byte('red'), byte('green'), byte('blue')],
      [
        channel8(kLaunchBackground.r),
        channel8(kLaunchBackground.g),
        channel8(kLaunchBackground.b),
      ],
      reason: '$storyboard: $color',
    );
  });

  test('5.2 FR-015: the launch image is centred at its natural size', () {
    final xml = File(storyboard).readAsStringSync();
    final view = imageView(xml, 'LaunchImage');
    expect(attribute(view, 'contentMode'), 'center', reason: storyboard);
    final pins = pinned(xml, attribute(view, 'id')!);
    expect(
      pins.containsAll(edges) || pins.containsAll({'centerX', 'centerY'}),
      isTrue,
      reason: '$storyboard: LaunchImage is pinned by $pins',
    );
  });

  test('5.3 FR-015: a #034A4A image fills the screen', () async {
    final xml = File(storyboard).readAsStringSync();
    final view = imageView(xml, 'LaunchBackground');
    final pins = pinned(xml, attribute(view, 'id')!);
    expect(
      pins.containsAll(edges),
      isTrue,
      reason: '$storyboard: LaunchBackground is pinned by $pins',
    );

    const png = '$backgroundSet/background.png';
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

  test('5.4 FR-016: LaunchImage Contents.json lists @1x, @2x and @3x', () {
    final json =
        jsonDecode(File('$launchImageSet/Contents.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(
      [
        for (final image in json['images'] as List)
          (image['filename'], image['scale']),
      ],
      [
        (launchImages[0], '1x'),
        (launchImages[1], '2x'),
        (launchImages[2], '3x'),
      ],
    );
    for (final name in launchImages) {
      expect(
        File('$launchImageSet/$name').existsSync(),
        isTrue,
        reason: '$launchImageSet/$name is missing',
      );
    }
  });

  test('5.5 FR-016/SC-005: the launch images scale exactly 1:2:3', () {
    final sizes = [
      for (final name in launchImages) readPngHeader('$launchImageSet/$name'),
    ];
    for (final (i, h) in sizes.indexed) {
      expect(
        [h.width, h.height],
        isNot([1, 1]),
        reason: '${launchImages[i]} is a 1 × 1 placeholder',
      );
    }
    final (w1, h1) = (sizes[0].width, sizes[0].height);
    expect(
      [sizes[1].width, sizes[1].height, sizes[2].width, sizes[2].height],
      [2 * w1, 2 * h1, 3 * w1, 3 * h1],
      reason: '@2x and @3x against @1x ($w1 × $h1)',
    );
  });

  for (final name in launchImages) {
    test('5.6 FR-016/017: $name is the tile', () async {
      final path = '$launchImageSet/$name';
      expectLaunchTile(await decodeRgba(path), iconMaster, path: path);
    });
  }

  test('5.6 FR-017: the tile is 96 pt, the same as on Android', () async {
    const path = '$launchImageSet/LaunchImage.png';
    expect(
      opaqueSpan(await decodeRgba(path)),
      inInclusiveRange(95, 97),
      reason: '$path: tile width in pt (@1x)',
    );
  });

  test('5.7 R-04: no dark launch images', () {
    expect(
      [
        for (final e in Directory(launchImageSet).listSync())
          if (e.uri.pathSegments.last.startsWith('LaunchImageDark'))
            e.uri.pathSegments.last,
      ],
      isEmpty,
      reason: launchImageSet,
    );
    expect(
      File('$backgroundSet/darkbackground.png').existsSync(),
      isFalse,
      reason: backgroundSet,
    );
  });

  test('5.8 FR-022: Info.plist keeps its status bar and display name', () {
    const path = '$kIosRunner/Info.plist';
    final plist = File(path).readAsStringSync();
    expect(plist, isNot(contains('<key>UIStatusBarHidden</key>')));
    expect(
      plist,
      matches(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>Backsolve</string>'),
      ),
      reason: path,
    );
  });
}
