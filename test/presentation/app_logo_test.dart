import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:backsolve/presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../brand/brand_image_utils.dart';

/// [AppLogo] draws the launcher mark from theme tokens alone
/// (contracts/brand-checks.md §6, FR-018–FR-020). The expected geometry is
/// data-model §3, measured on the 1024 px master: squares of 195 px with an
/// 88 px gap and a 46 px corner radius, centred, which scaled into the 52 dp
/// tile is 9.902 / 4.469 / 2.336 dp. The literals below are those measured
/// values, not the tokens, so a wrong token expression fails here. Check 6.4
/// closes the loop against the master's own pixels.
void main() {
  /// The mark's tile-local geometry, from data-model §3.
  const square = 9.902;
  const radius = 2.336;
  const origin = 13.863; // (52 − (2 × square + gap)) / 2
  const second = 28.234; // origin + square + gap

  /// Pumps the logo alone — no database, no `MaterialApp` — inside a
  /// [RepaintBoundary] so 6.3 and 6.4 can read its pixels. Returns the
  /// boundary's key.
  Future<GlobalKey> pumpLogo(
    WidgetTester tester, {
    double pixelRatio = 3,
  }) async {
    final boundaryKey = GlobalKey();
    tester.view.devicePixelRatio = pixelRatio;
    tester.view.physicalSize = Size(200 * pixelRatio, 200 * pixelRatio);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(key: boundaryKey, child: const AppLogo()),
        ),
      ),
    );
    return boundaryKey;
  }

  /// The pixels of the [RepaintBoundary] at [key]. Call inside
  /// [WidgetTester.runAsync]: `toImage` and `toByteData` need real async.
  Future<Rgba> capture(GlobalKey key, {required double pixelRatio}) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      return await rgbaFromImage(image);
    } finally {
      image.dispose();
    }
  }

  /// The four mark squares as (tile-local rect, decoration), row-major. The
  /// tile's own [DecoratedBox] — the one [Container] builds — drops out by
  /// size: it fills the tile, while every square is well under half of it.
  List<(Rect, BoxDecoration)> markSquares(WidgetTester tester) {
    final tileRect = tester.getRect(find.byType(AppLogo));
    final found = <(Rect, BoxDecoration)>[];
    final boxes = find.descendant(
      of: find.byType(AppLogo),
      matching: find.byType(DecoratedBox),
    );
    for (final element in boxes.evaluate()) {
      final box = element.renderObject! as RenderBox;
      if (box.size.width >= tileRect.width / 2) continue;
      found.add((
        (box.localToGlobal(Offset.zero) & box.size).shift(-tileRect.topLeft),
        (element.widget as DecoratedBox).decoration as BoxDecoration,
      ));
    }
    found.sort((a, b) {
      final byRow = a.$1.top.compareTo(b.$1.top);
      return byRow != 0 ? byRow : a.$1.left.compareTo(b.$1.left);
    });
    return found;
  }

  testWidgets('6.1 the tile is the unchanged 52 dp teal square (FR-021)', (
    tester,
  ) async {
    await pumpLogo(tester);

    expect(
      tester.getRect(find.byType(AppLogo)).size,
      const Size(AppSizes.appIcon, AppSizes.appIcon),
    );

    final tile = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppLogo),
        matching: find.byType(Container),
      ),
    );
    final decoration = tile.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.primary);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(AppSizes.appIconRadius),
    );
  });

  testWidgets('6.2 four mark squares sit on the master grid (FR-018)', (
    tester,
  ) async {
    await pumpLogo(tester);

    final squares = markSquares(tester);
    expect(squares, hasLength(4), reason: 'mark squares');

    const names = ['TL', 'TR', 'BL', 'BR'];
    const corners = [
      Offset(origin, origin),
      Offset(second, origin),
      Offset(origin, second),
      Offset(second, second),
    ];
    for (var i = 0; i < corners.length; i++) {
      final (rect, decoration) = squares[i];
      final name = names[i];
      expect(rect.left, closeTo(corners[i].dx, 1), reason: '$name left');
      expect(rect.top, closeTo(corners[i].dy, 1), reason: '$name top');
      expect(rect.width, closeTo(square, 1), reason: '$name width');
      expect(rect.height, closeTo(square, 1), reason: '$name height');
      final corner = (decoration.borderRadius! as BorderRadius).topLeft;
      expect(corner.x, closeTo(radius, 1), reason: '$name corner radius');
    }
  });

  testWidgets(
    '6.3 the rendered pixels are three white squares and one muted '
    '(FR-019, SC-006)',
    (tester) async {
      const pixelRatio = 3.0;
      final key = await pumpLogo(tester, pixelRatio: pixelRatio);
      final squares = markSquares(tester);

      late final Rgba pixels;
      await tester.runAsync(() async {
        pixels = await capture(key, pixelRatio: pixelRatio);
      });

      expect(pixels.width, (AppSizes.appIcon * pixelRatio).round());

      const names = ['TL', 'TR', 'BL', 'BR'];
      const colors = [
        AppColors.onPrimary,
        AppColors.onPrimary,
        AppColors.onPrimary,
        AppColors.mutedTeal,
      ];
      for (var i = 0; i < colors.length; i++) {
        final centre = squares[i].$1.center * pixelRatio;
        expectPixelNear(
          pixels,
          centre.dx.round(),
          centre.dy.round(),
          colors[i],
          reason: '${names[i]} centre',
        );
      }

      // The gap crossing at the tile's centre shows the tile through.
      final crossing = const Offset(26, 26) * pixelRatio;
      expectPixelNear(
        pixels,
        crossing.dx.round(),
        crossing.dy.round(),
        AppColors.primary,
        reason: 'the gap crossing',
      );
    },
  );

  testWidgets('6.4 the rendered logo matches the icon master (SC-006)', (
    tester,
  ) async {
    const pixelRatio = 2.0;
    const side = 104; // AppSizes.appIcon × pixelRatio
    final key = await pumpLogo(tester, pixelRatio: pixelRatio);

    late final int renderedSide;
    late final double meanDiff;
    await tester.runAsync(() async {
      final rendered = await capture(key, pixelRatio: pixelRatio);
      renderedSide = rendered.width;
      final master = boxDownscale(await decodeRgba(kIconMaster), side);
      // The mark's bounding box grown by one gap on each side: 9.39…42.61 dp,
      // which at this ratio is px [19, 85) and stays inside the tile's
      // rounded corners.
      meanDiff = meanAbsDiff(
        rendered,
        master,
        channels: const [0, 1, 2],
        left: 19,
        top: 19,
        right: 85,
        bottom: 85,
      );
    });

    expect(renderedSide, side);
    // Recorded in tasks.md under "Recorded measurements" (T030).
    debugPrint('6.4 rendered logo vs master, RGB mean |Δ| = $meanDiff');
    expect(meanDiff, lessThanOrEqualTo(3.0));
  });

  test('6.5 mutedTeal is white at 107/255 over primary (FR-020)', () {
    const alpha = 107 / 255;
    int over(double white, double teal) =>
        channel8(white * alpha + teal * (1 - alpha));
    expect(
      [
        over(AppColors.onPrimary.r, AppColors.primary.r),
        over(AppColors.onPrimary.g, AppColors.primary.g),
        over(AppColors.onPrimary.b, AppColors.primary.b),
      ],
      [
        channel8(AppColors.mutedTeal.r),
        channel8(AppColors.mutedTeal.g),
        channel8(AppColors.mutedTeal.b),
      ],
      reason: 'the composite, then AppColors.mutedTeal',
    );
    expect(
      [
        channel8(AppColors.mutedTeal.r),
        channel8(AppColors.mutedTeal.g),
        channel8(AppColors.mutedTeal.b),
      ],
      [107, 178, 182],
      reason: 'data-model §2, and the pixel T005 measures in the master',
    );
  });
}
