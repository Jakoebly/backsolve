import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:test/test.dart';

void main() {
  const minus = '−';

  SessionConfig defaults({DifficultyLevel startLevel = DifficultyLevel.l4}) =>
      SessionConfig.defaultsFor(
        categoryIds: const ['percentages'],
        startLevel: startLevel,
        presetKind: PresetKind.all,
      );

  group('formatAccuracy', () {
    test('"82%"', () => expect(formatAccuracy(82), '82%'));
  });

  group('formatSeconds', () {
    test('"5.8s"', () => expect(formatSeconds(5.8), '5.8s'));

    test('rounds to one decimal', () {
      expect(formatSeconds(5.849), '5.8s');
      expect(formatSeconds(5.86), '5.9s');
      expect(formatSeconds(6), '6.0s');
    });
  });

  group('formatAccuracyDelta', () {
    test('"+5 this week"', () {
      expect(formatAccuracyDelta(5), '+5 this week');
    });

    test('uses U+2212 for negatives: "−3 this week"', () {
      expect(formatAccuracyDelta(-3), '${minus}3 this week');
      expect(formatAccuracyDelta(-3), '−3 this week');
      expect(formatAccuracyDelta(-3).codeUnitAt(0), 0x2212);
    });

    test('zero is "+0 this week"', () {
      expect(formatAccuracyDelta(0), '+0 this week');
    });
  });

  group('formatSpeedDelta', () {
    test('"−0.6s this week"', () {
      expect(formatSpeedDelta(-0.6), '${minus}0.6s this week');
      expect(formatSpeedDelta(-0.6), '−0.6s this week');
      expect(formatSpeedDelta(-0.6).codeUnitAt(0), 0x2212);
    });

    test('"+0.4s this week"', () {
      expect(formatSpeedDelta(0.4), '+0.4s this week');
    });

    test('rounds to one decimal with the sign decided after rounding', () {
      expect(formatSpeedDelta(-0.04), '+0.0s this week');
      expect(formatSpeedDelta(0.0), '+0.0s this week');
      expect(formatSpeedDelta(-0.56), '${minus}0.6s this week');
      expect(formatSpeedDelta(1.24), '+1.2s this week');
    });
  });

  group('formatLevel', () {
    test('"L4"', () => expect(formatLevel(DifficultyLevel.l4), 'L4'));

    test('L1..L5', () {
      for (var n = 1; n <= 5; n++) {
        expect(formatLevel(DifficultyLevel.fromNumber(n)), 'L$n');
      }
    });
  });

  group('quickStartSummary', () {
    test('"60 seconds · adaptive · L4" for the default config', () {
      expect(quickStartSummary(defaults()), '60 seconds · adaptive · L4');
    });

    test('takes the level from the adaptive start level', () {
      expect(
        quickStartSummary(defaults(startLevel: DifficultyLevel.l3)),
        '60 seconds · adaptive · L3',
      );
    });

    test('takes the level from a fixed difficulty', () {
      final config = defaults().copyWith(
        difficulty: const FixedDifficultySetting(DifficultyLevel.l2),
      );
      expect(quickStartSummary(config), '60 seconds · L2 · L2');
    });
  });

  group('settingsChip', () {
    test('"60s · adaptive · exact" for the default config', () {
      expect(settingsChip(defaults()), '60s · adaptive · exact');
    });

    test('reflects a changed answer mode', () {
      final config = defaults().copyWith(answerMode: AnswerMode.estimation);
      expect(settingsChip(config), '60s · adaptive · estimation');
    });
  });

  group('difficultyHelper', () {
    test('adaptive line (FR-022)', () {
      expect(
        difficultyHelper(const AdaptiveDifficultySetting(DifficultyLevel.l3)),
        'Starts at L3. Fast and right moves up, wrong moves down.',
      );
    });

    test('fixed line', () {
      expect(
        difficultyHelper(const FixedDifficultySetting(DifficultyLevel.l2)),
        'Every question is at L2.',
      );
    });
  });

  group('answerModeHelper', () {
    test('exact', () {
      expect(answerModeHelper(AnswerMode.exact), 'Answers must match exactly.');
    });

    test('estimation (FR-023)', () {
      expect(
        answerModeHelper(AnswerMode.estimation),
        'Same session, but anything within ±2% counts. Round the inputs first.',
      );
    });
  });
}
