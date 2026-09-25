import 'dart:io';

import 'package:backsolve/presentation/theme/app_theme.dart';
import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Difficulty helper must render on exactly **one line** whichever
/// difficulty is selected, so nothing below it moves as the user switches
/// (user request 2026-09-22). Both variants are written to fit that budget;
/// `packages/backsolve_domain/test/format/formatters_test.dart` guards
/// their length, and this test checks the rendered width.
///
/// It measures with the real Roboto, the font Android actually uses: the
/// font `flutter test` falls back to is far wider than Roboto (it wraps
/// text the device keeps on one line), so a widget test would report
/// line counts no device ever sees.
void main() {
  /// Roboto ships inside the Flutter SDK cache that holds the binary
  /// running this test (…/bin/cache/artifacts/material_fonts). The binary
  /// sits at a different depth per platform, so walk up looking for it.
  File? robotoFile() {
    var dir = File(Platform.resolvedExecutable).parent;
    for (var level = 0; level < 8; level++) {
      for (final candidate in [
        File('${dir.path}/artifacts/material_fonts/roboto-regular.ttf'),
        File('${dir.path}/material_fonts/roboto-regular.ttf'),
      ]) {
        if (candidate.existsSync()) return candidate;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  late bool fontLoaded;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final font = robotoFile();
    fontLoaded = font != null;
    if (font == null) return;
    final bytes = ByteData.view(font.readAsBytesSync().buffer);
    await (FontLoader('Roboto')..addFont(Future.value(bytes))).load();
  });

  /// The number of lines [text] needs in [width] dp of the helper style.
  int lines(String text, double width) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.helper.copyWith(fontFamily: 'Roboto'),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    return painter.computeLineMetrics().length;
  }

  // Narrowest common phone the wording targets, the reference 360 dp frame
  // of the mockups, and a large phone. Content width is the screen minus
  // the two screen paddings.
  for (final screen in [345.0, 360.0, 411.0]) {
    test('both Difficulty helper lines fit one line at $screen dp', () {
      if (!fontLoaded) {
        markTestSkipped('Roboto not found next to ${Platform.resolvedExecutable}');
        return;
      }
      final width = screen - 2 * AppSpacing.lg;
      for (final level in DifficultyLevel.values) {
        for (final line in [
          difficultyHelper(AdaptiveDifficultySetting(level)),
          difficultyHelper(FixedDifficultySetting(level)),
        ]) {
          expect(lines(line, width), 1, reason: '"$line" at $width dp');
        }
      }
    });
  }
}
