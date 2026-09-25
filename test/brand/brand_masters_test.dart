import 'dart:io';
import 'dart:ui' as ui;

import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand_image_utils.dart';

/// The masters in `assets/brand/` are the supplied artwork, unmodified
/// (FR-001, contracts/brand-checks.md §1). Their SHA-256 was checked at copy
/// time (quickstart V1); from then on these measured pixel facts pin them,
/// since hashing here would need `package:crypto`. The masters feed the
/// generators only, so they must stay out of the app bundle (research R-08).
void main() {
  late Rgba icon;
  late Rgba glyph;

  setUpAll(() async {
    icon = await decodeRgba(kIconMaster);
    glyph = await decodeRgba(kGlyphMaster);
  });

  test('1.1 both masters are 1024 × 1024, 8-bit RGBA', () {
    for (final path in [kIconMaster, kGlyphMaster]) {
      expect(File(path).existsSync(), isTrue, reason: '$path is missing');
      final header = readPngHeader(path);
      expect(
        [header.width, header.height, header.bitDepth, header.colorType],
        [1024, 1024, 8, 6],
        reason: '$path: width, height, bit depth, colour type',
      );
    }
  });

  test('1.2 the icon master: opaque teal, three white squares, one muted', () {
    var translucent = 0;
    for (var y = 0; y < icon.height; y++) {
      for (var x = 0; x < icon.width; x++) {
        if (icon.at(x, y, 3) != 255) translucent++;
      }
    }
    expect(translucent, 0, reason: 'pixels with alpha < 255 in $kIconMaster');

    expectPixelNear(
      icon,
      0,
      0,
      AppColors.primary,
      tolerance: 0,
      reason: '$kIconMaster corner',
    );
    for (final (x, y) in [(390, 390), (634, 390), (390, 634)]) {
      expectPixelNear(
        icon,
        x,
        y,
        AppColors.onPrimary,
        tolerance: 0,
        reason: '$kIconMaster white square',
      );
    }

    // The muted square is white at 107/255 over the teal. AppColors.mutedTeal
    // (US3) is tied to the same composite by app_logo_test's check 6.5.
    final muted = _onPrimaryOverPrimary(107);
    expect(
      [channel8(muted.r), channel8(muted.g), channel8(muted.b)],
      [107, 178, 182],
    );
    expectPixelNear(
      icon,
      634,
      634,
      muted,
      tolerance: 0,
      reason: '$kIconMaster muted square',
    );
  });

  test('1.3 the glyph master: the mark on transparency', () {
    var left = glyph.width, top = glyph.height, right = 0, bottom = 0;
    for (var y = 0; y < glyph.height; y++) {
      for (var x = 0; x < glyph.width; x++) {
        if (glyph.at(x, y, 3) == 0) continue;
        if (x < left) left = x;
        if (y < top) top = y;
        if (x >= right) right = x + 1;
        if (y >= bottom) bottom = y + 1;
      }
    }
    expect(
      [left, top, right, bottom],
      [273, 273, 751, 751],
      reason: '$kGlyphMaster: [left, top, right, bottom) of alpha > 0',
    );

    for (final (x, y) in [(390, 390), (634, 390), (390, 634)]) {
      expect(
        glyph.at(x, y, 3),
        255,
        reason: '$kGlyphMaster alpha of the white square at ($x, $y)',
      );
    }
    expect(
      glyph.at(634, 634, 3),
      inInclusiveRange(106, 108),
      reason: '$kGlyphMaster alpha of the muted square at (634, 634)',
    );
    expectPixelNear(
      glyph,
      634,
      634,
      AppColors.onPrimary,
      tolerance: 0,
      reason: '$kGlyphMaster muted square',
    );
    expect(
      glyph.at(512, 512, 3),
      0,
      reason: '$kGlyphMaster alpha at the gap crossing (512, 512)',
    );
  });

  test('1.4 pubspec.yaml does not bundle assets/brand under flutter:', () {
    final lines = File('pubspec.yaml').readAsLinesSync();
    final start = lines.indexWhere(RegExp(r'^flutter:\s*$').hasMatch);
    expect(start, isNonNegative, reason: 'no top-level flutter: section');
    // The block runs to the next top-level key; a column-0 comment is not
    // one. Comments are dropped, since the flutter_launcher_icons: section's
    // comment legitimately names the folder.
    final end = lines.indexWhere(RegExp(r'^[^\s#]').hasMatch, start + 1);
    final entries = [
      for (final line in lines.sublist(start, end < 0 ? lines.length : end))
        line.split(RegExp(r'(^|\s)#')).first,
    ];
    expect(entries.where((e) => e.contains('assets/brand')), isEmpty);
  });
}

/// [AppColors.onPrimary] at [alpha]/255 over [AppColors.primary], rounded
/// per channel.
ui.Color _onPrimaryOverPrimary(int alpha) {
  int blend(double top, double base) =>
      ((channel8(top) * alpha + channel8(base) * (255 - alpha)) / 255).round();
  return ui.Color.fromARGB(
    255,
    blend(AppColors.onPrimary.r, AppColors.primary.r),
    blend(AppColors.onPrimary.g, AppColors.primary.g),
    blend(AppColors.onPrimary.b, AppColors.primary.b),
  );
}
