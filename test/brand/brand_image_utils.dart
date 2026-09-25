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

/// The width of the bounding box of the pixels with alpha ≥ [threshold]
/// (0 if there are none).
int opaqueSpan(Rgba img, {int threshold = 128}) {
  var minX = img.width;
  var maxX = -1;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (img.at(x, y, 3) >= threshold) {
        minX = min(minX, x);
        maxX = max(maxX, x);
      }
    }
  }
  return maxX < minX ? 0 : maxX - minX + 1;
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
