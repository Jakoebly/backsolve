/// Shared helper for the brand checks (not a test file): PNG headers, pixel
/// decoding through `dart:ui`, an exact reference downscale and the
/// measurements the tests assert on
/// (specs/002-app-icon-launch-screen/contracts/brand-checks.md §0). It
/// deliberately avoids `package:image`, the library that wrote the files
/// under test (research R-10).
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

// Paths are relative to the package root, the working directory under
// `flutter test`.
const kIconMaster = 'assets/brand/backsolve_icon_1024.png';
const kGlyphMaster = 'assets/brand/backsolve_glyph_1024.png';
const kAndroidRes = 'android/app/src/main/res';
const kIosRunner = 'ios/Runner';

/// "Derived from a master": the largest mean |Δ| per channel against
/// [boxDownscale] of the master. Calibrated in research R-10: the generated
/// files measured 0.12–0.20, the Flutter defaults ≈ 140.
const kDerivedMeanTolerance = 2.0;

/// The launch background, #034A4A, chosen in the spec's Clarifications
/// (2026-09-25). It has no theme token because no Dart code draws it
/// (data-model §2).
const kLaunchBackground = ui.Color(0xFF034A4A);

/// The IHDR facts of a PNG, plus whether it carries a `tRNS` chunk.
class PngHeader {
  const PngHeader({
    required this.width,
    required this.height,
    required this.bitDepth,
    required this.colorType,
    required this.hasTrns,
  });

  final int width;
  final int height;
  final int bitDepth;

  /// 0 grey, 2 RGB, 3 palette, 4 grey + alpha, 6 RGBA.
  final int colorType;
  final bool hasTrns;
}

const _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

/// Reads the signature and IHDR of the PNG at [path], then walks its chunks
/// (length + type + data + CRC) looking for `tRNS`. Throws a
/// [FormatException] naming [path] if the file is not a PNG.
PngHeader readPngHeader(String path) {
  final bytes = File(path).readAsBytesSync();
  if (bytes.length < 33 ||
      !Iterable.generate(8).every((i) => bytes[i] == _pngSignature[i]) ||
      String.fromCharCodes(bytes, 12, 16) != 'IHDR') {
    throw FormatException('not a PNG: $path');
  }
  final data = ByteData.sublistView(bytes);
  var hasTrns = false;
  var offset = 8;
  while (offset + 8 <= bytes.length) {
    final type = String.fromCharCodes(bytes, offset + 4, offset + 8);
    if (type == 'tRNS') hasTrns = true;
    if (type == 'IEND') break;
    offset += 12 + data.getUint32(offset);
  }
  return PngHeader(
    width: data.getUint32(16),
    height: data.getUint32(20),
    bitDepth: bytes[24],
    colorType: bytes[25],
    hasTrns: hasTrns,
  );
}

/// Straight (not premultiplied), row-major RGBA pixels.
class Rgba {
  const Rgba(this.width, this.height, this.bytes);

  final int width;
  final int height;
  final Uint8List bytes;

  /// Channel 0 red, 1 green, 2 blue, 3 alpha of pixel ([x], [y]).
  int at(int x, int y, int channel) => bytes[(y * width + x) * 4 + channel];
}

/// The pixels of [image], unpremultiplied.
Future<Rgba> rgbaFromImage(ui.Image image) async {
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  if (data == null) throw StateError('toByteData returned null');
  return Rgba(
    image.width,
    image.height,
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}

/// Decodes the image file at [path] with the engine's codecs. Works in a
/// plain `test()`; inside `testWidgets`, call it within `tester.runAsync`.
Future<Rgba> decodeRgba(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final frame = await codec.getNextFrame();
  codec.dispose();
  try {
    return await rgbaFromImage(frame.image);
  } finally {
    frame.image.dispose();
  }
}

/// The source pixels output pixel `i` of a [size]-wide box downscale
/// covers, [i·s, (i+1)·s) with `s = srcLength / size`, each with its
/// overlap as the weight. The `min` keeps a rounding error in `(i+1)·s`
/// from reaching one pixel past the edge.
List<List<(int, double)>> _boxWeights(int srcLength, int size) {
  final s = srcLength / size;
  return [
    for (var i = 0; i < size; i++)
      [
        for (
          var j = (i * s).floor();
          j < min(((i + 1) * s).ceil(), srcLength);
          j++
        )
          (j, min((i + 1) * s, j + 1.0) - max(i * s, j.toDouble())),
      ],
  ];
}

/// An exact area average of [src] onto `size × size`: each source pixel
/// weighs its overlap area with the output pixel's box. Per channel on
/// straight RGBA, rounded to int.
Rgba boxDownscale(Rgba src, int size) {
  final columns = _boxWeights(src.width, size);
  final rows = _boxWeights(src.height, size);
  // Horizontal pass: every source row, reduced to `size` columns.
  final horizontal = Float64List(src.height * size * 4);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < size; x++) {
      final out = (y * size + x) * 4;
      for (final (j, w) in columns[x]) {
        final inp = (y * src.width + j) * 4;
        for (var c = 0; c < 4; c++) {
          horizontal[out + c] += src.bytes[inp + c] * w;
        }
      }
    }
  }
  // Vertical pass, then normalise by the box area.
  final area = (src.width / size) * (src.height / size);
  final bytes = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      for (var c = 0; c < 4; c++) {
        var sum = 0.0;
        for (final (j, w) in rows[y]) {
          sum += horizontal[(j * size + x) * 4 + c] * w;
        }
        bytes[(y * size + x) * 4 + c] = (sum / area).round().clamp(0, 255);
      }
    }
  }
  return Rgba(size, size, bytes);
}

/// The mean absolute difference of [a] and [b] over [channels] (0–3),
/// within the half-open region [left, right) × [top, bottom), which
/// defaults to the whole image. Throws if the sizes differ.
double meanAbsDiff(
  Rgba a,
  Rgba b, {
  required List<int> channels,
  int left = 0,
  int top = 0,
  int? right,
  int? bottom,
}) {
  if (a.width != b.width || a.height != b.height) {
    throw ArgumentError(
      'size mismatch: ${a.width}×${a.height} vs ${b.width}×${b.height}',
    );
  }
  final xEnd = right ?? a.width;
  final yEnd = bottom ?? a.height;
  var sum = 0;
  var count = 0;
  for (var y = top; y < yEnd; y++) {
    for (var x = left; x < xEnd; x++) {
      for (final c in channels) {
        sum += (a.at(x, y, c) - b.at(x, y, c)).abs();
        count++;
      }
    }
  }
  return sum / count;
}

/// Places every pixel of [img] with alpha > 0 at (originX + x, originY + y)
/// in a canvas of side [canvas] and returns the largest distance from the
/// canvas centre to that pixel's farthest corner.
double farthestOpaqueRadius(
  Rgba img, {
  required double canvas,
  required double originX,
  required double originY,
}) {
  final centre = canvas / 2;
  var farthest = 0.0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (img.at(x, y, 3) == 0) continue;
      final dx = max(
        (originX + x - centre).abs(),
        (originX + x + 1 - centre).abs(),
      );
      final dy = max(
        (originY + y - centre).abs(),
        (originY + y + 1 - centre).abs(),
      );
      farthest = max(farthest, sqrt(dx * dx + dy * dy));
    }
  }
  return farthest;
}

/// The half-open bounding box of the pixels with alpha ≥ [threshold], or
/// null if there are none.
({int left, int top, int right, int bottom})? _opaqueBounds(
  Rgba img, {
  int threshold = 128,
}) {
  var left = img.width, top = img.height, right = 0, bottom = 0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (img.at(x, y, 3) < threshold) continue;
      if (x < left) left = x;
      if (y < top) top = y;
      if (x >= right) right = x + 1;
      if (y >= bottom) bottom = y + 1;
    }
  }
  if (right == 0) return null;
  return (left: left, top: top, right: right, bottom: bottom);
}

/// The width of the bounding box of the pixels with alpha ≥ [threshold]
/// (0 if there are none).
int opaqueSpan(Rgba img, {int threshold = 128}) {
  final box = _opaqueBounds(img, threshold: threshold);
  return box == null ? 0 : box.right - box.left;
}

/// The [size] × [size] square of [img] whose top-left pixel is
/// ([left], [top]).
Rgba _crop(Rgba img, int left, int top, int size) {
  final bytes = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    final from = ((top + y) * img.width + left) * 4;
    bytes.setRange(y * size * 4, (y + 1) * size * 4, img.bytes, from);
  }
  return Rgba(size, size, bytes);
}

/// A colour component (0–1, as in [ui.Color.r]) as an 8-bit value.
int channel8(double v) => (v * 255).round();

/// Expects pixel ([x], [y]) of [img] to match [expected] within
/// [tolerance] in each of R, G and B.
void expectPixelNear(
  Rgba img,
  int x,
  int y,
  ui.Color expected, {
  int tolerance = 2,
  String? reason,
}) {
  final want = [
    channel8(expected.r),
    channel8(expected.g),
    channel8(expected.b),
  ];
  final found = [img.at(x, y, 0), img.at(x, y, 1), img.at(x, y, 2)];
  for (var c = 0; c < 3; c++) {
    expect(
      (found[c] - want[c]).abs(),
      lessThanOrEqualTo(tolerance),
      reason:
          '${reason ?? 'pixel'} at ($x, $y): found RGB $found, '
          'expected $want ± $tolerance',
    );
  }
}

/// Expects [img], a launch image, to be derived from the launch tile
/// (data-model §3.1 and §4 "Derived from tile"): the icon master scaled to a
/// third of the canvas, its corners rounded like the Home logo tile, centred
/// on transparency and inside Android 12's circular mask. Failure messages
/// name [path].
void expectLaunchTile(Rgba img, Rgba iconMaster, {required String path}) {
  final c = img.width;
  final t = c ~/ 3;
  expect([img.height, t * 3], [c, c], reason: '$path: a square of 3 tiles');
  final r = t * AppSizes.appIconRadius / AppSizes.appIcon;

  // 1. Nothing is visible outside the centred t × t square.
  var outside = 0;
  for (var y = 0; y < c; y++) {
    for (var x = 0; x < c; x++) {
      final inTile = x >= t && x < 2 * t && y >= t && y < 2 * t;
      if (!inTile && img.at(x, y, 3) != 0) outside++;
    }
  }
  expect(outside, 0, reason: '$path: visible pixels outside [$t, ${2 * t})²');

  // 2. The tile is t ± 1 px wide and high, centred within ± 1 px.
  final box = _opaqueBounds(img);
  if (box == null) fail('$path has no pixel with alpha ≥ 128');
  for (final (axis, from, to) in [
    ('x', box.left, box.right),
    ('y', box.top, box.bottom),
  ]) {
    expect(
      to - from,
      inInclusiveRange(t - 1, t + 1),
      reason: '$path: tile spans [$from, $to) in $axis, expected $t ± 1 px',
    );
    expect(
      ((from + to) / 2 - c / 2).abs(),
      lessThanOrEqualTo(1),
      reason: '$path: tile centre ${(from + to) / 2} in $axis, not ${c / 2}',
    );
  }

  // 3. Between the corner arcs the tile is opaque and is the icon master.
  final lo = (t + r).ceil();
  final hi = (2 * t - r).floor();
  var translucent = 0;
  for (var y = lo; y < hi; y++) {
    for (var x = lo; x < hi; x++) {
      if (img.at(x, y, 3) != 255) translucent++;
    }
  }
  expect(translucent, 0, reason: '$path: translucent pixels in [$lo, $hi)²');
  final diff = meanAbsDiff(
    _crop(img, t, t, t),
    boxDownscale(iconMaster, t),
    channels: const [0, 1, 2],
    left: lo - t,
    top: lo - t,
    right: hi - t,
    bottom: hi - t,
  );
  expect(
    diff,
    lessThanOrEqualTo(kDerivedMeanTolerance),
    reason:
        '$path: RGB mean |Δ| ${diff.toStringAsFixed(2)} against the '
        'downscaled icon master in [$lo, $hi)²',
  );

  // 4. Each corner has the Home logo's radius: the transparent area of the
  // ⌈r⌉ × ⌈r⌉ square at a corner is r²(1 − π/4); the pixels beyond r in
  // that square are opaque and add nothing.
  final n = r.ceil();
  for (final (corner, x0, y0) in [
    ('top-left', t, t),
    ('top-right', 2 * t - n, t),
    ('bottom-left', t, 2 * t - n),
    ('bottom-right', 2 * t - n, 2 * t - n),
  ]) {
    var clear = 0.0;
    for (var y = y0; y < y0 + n; y++) {
      for (var x = x0; x < x0 + n; x++) {
        clear += 1 - img.at(x, y, 3) / 255;
      }
    }
    final radius = sqrt(clear / (1 - pi / 4));
    expect(
      (radius - r).abs(),
      lessThanOrEqualTo(c / 288),
      reason:
          '$path: $corner corner radius ${radius.toStringAsFixed(2)} px, '
          'expected ${r.toStringAsFixed(2)} ± ${c / 288}',
    );
  }

  // 5. Inside Android 12's circular mask, a radius of a third of the canvas.
  final farthest = farthestOpaqueRadius(
    img,
    canvas: c.toDouble(),
    originX: 0,
    originY: 0,
  );
  expect(
    farthest,
    lessThanOrEqualTo(c / 3),
    reason:
        '$path: farthest visible pixel ${farthest.toStringAsFixed(1)} px '
        'from the centre, mask radius ${c / 3} px',
  );
}

/// Every PNG below [dir], as `folder/name.png` paths relative to [dir]
/// (forward slashes on every OS), for the inventory checks.
Set<String> pngPathsUnder(String dir) {
  final root = Directory(dir);
  return {
    for (final entity in root.listSync(recursive: true))
      if (entity is File && entity.path.toLowerCase().endsWith('.png'))
        entity.path
            .substring(root.path.length)
            .replaceAll(r'\', '/')
            .replaceFirst(RegExp('^/'), ''),
  };
}
