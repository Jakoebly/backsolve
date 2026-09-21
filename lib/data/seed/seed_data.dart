import 'package:backsolve_domain/backsolve_domain.dart';

/// First-launch seed values (research.md R-06, data-model.md §3). Everything
/// here is relative to the install moment so the FR-030 invariants hold on
/// any date; `Seeder` turns these rows into timestamps.

/// One dated entry of a seeded level history, [daysAgo] days before install.
final class SeedLevelChange {
  const SeedLevelChange(this.daysAgo, this.level)
    : assert(daysAgo >= 1, 'history entries must lie in the past'),
      assert(level >= 1 && level <= 5);

  final int daysAgo;
  final int level;
}

/// Seeded statistics for one registry category.
final class SeedCategory {
  const SeedCategory({
    required this.level,
    required this.accuracy,
    required this.avgAnswerSeconds,
    required this.levelHistory,
  }) : assert(level >= 1 && level <= 5),
       assert(accuracy >= 0 && accuracy <= 100),
       assert(avgAnswerSeconds >= 3.0 && avgAnswerSeconds <= 10.0, 'SC-005');

  final int level;
  final double accuracy;
  final double avgAnswerSeconds;

  /// Oldest first and non-empty; the last entry's level equals [level]
  /// (a list's length is not constant-evaluable, so the seeder test checks
  /// this rather than a `const` assert).
  final List<SeedLevelChange> levelHistory;
}

/// Per-category stats keyed by registry id, in spec order. Mean level 3.5
/// → L4 on Home (FR-035); the three lowest accuracies are Growth & CAGR,
/// Margins & Breakeven and Estimation (FR-024).
const seedCategories = <String, SeedCategory>{
  'percentages': SeedCategory(
    level: 5,
    accuracy: 91,
    avgAnswerSeconds: 3.8,
    levelHistory: [
      SeedLevelChange(45, 3),
      SeedLevelChange(24, 4),
      SeedLevelChange(8, 5),
    ],
  ),
  'multiplication': SeedCategory(
    level: 4,
    accuracy: 84,
    avgAnswerSeconds: 4.9,
    levelHistory: [
      SeedLevelChange(50, 2),
      SeedLevelChange(30, 3),
      SeedLevelChange(11, 4),
    ],
  ),
  'division_ratios': SeedCategory(
    level: 3,
    accuracy: 72,
    avgAnswerSeconds: 6.2,
    levelHistory: [
      SeedLevelChange(48, 1),
      SeedLevelChange(27, 2),
      SeedLevelChange(13, 3),
    ],
  ),
  'fractions_percent': SeedCategory(
    level: 4,
    accuracy: 80,
    avgAnswerSeconds: 5.5,
    levelHistory: [
      SeedLevelChange(46, 2),
      SeedLevelChange(22, 3),
      SeedLevelChange(9, 4),
    ],
  ),
  'growth_cagr': SeedCategory(
    level: 2,
    accuracy: 61,
    avgAnswerSeconds: 9.1,
    levelHistory: [
      SeedLevelChange(40, 1),
      SeedLevelChange(19, 2),
      SeedLevelChange(6, 2),
    ],
  ),
  'margins_breakeven': SeedCategory(
    level: 3,
    accuracy: 68,
    avgAnswerSeconds: 6.8,
    levelHistory: [
      SeedLevelChange(44, 1),
      SeedLevelChange(25, 2),
      SeedLevelChange(10, 3),
    ],
  ),
  'big_numbers': SeedCategory(
    level: 4,
    accuracy: 83,
    avgAnswerSeconds: 4.4,
    levelHistory: [
      SeedLevelChange(42, 2),
      SeedLevelChange(20, 3),
      SeedLevelChange(7, 4),
    ],
  ),
  'estimation': SeedCategory(
    level: 3,
    accuracy: 70,
    avgAnswerSeconds: 7.4,
    levelHistory: [
      SeedLevelChange(49, 1),
      SeedLevelChange(28, 2),
      SeedLevelChange(12, 3),
    ],
  ),
};

/// Stats for a registry entry without a row in [seedCategories], so adding a
/// category never requires a seed change (Constitution III).
const defaultSeedCategory = SeedCategory(
  level: 3,
  accuracy: 70,
  avgAnswerSeconds: 6.0,
  levelHistory: [
    SeedLevelChange(45, 1),
    SeedLevelChange(24, 2),
    SeedLevelChange(8, 3),
  ],
);

/// One seeded, completed, timed / adaptive / exact session, positioned
/// relative to the install moment.
final class SeedSession {
  /// A streak row: [daysAgo] calendar days before today at [hour]:[minute].
  /// The `daysAgo == 0` row is clamped by the seeder to `now − 2 min`.
  const SeedSession.daysAgo(
    int daysAgo, {
    required this.hour,
    required this.minute,
    this.categoryIds,
    this.presetKind = PresetKind.all,
    required this.accuracy,
    required this.avgAnswerSeconds,
    required this.questionCount,
  }) : assert(daysAgo >= 0 && daysAgo <= 6),
       _daysAgo = daysAgo,
       weekOffset = null,
       weekday = null,
       assert(hour >= 7 && hour <= 22, 'no session may straddle midnight'),
       assert(minute >= 0 && minute <= 59),
       assert(questionCount >= 6 && questionCount <= 12),
       assert(accuracy >= 0 && accuracy <= 100),
       assert(avgAnswerSeconds > 0),
       assert(
         (categoryIds == null) == (presetKind == PresetKind.all),
         'null categoryIds means every registered category (preset all)',
       );

  /// A baseline row in the week [weekOffset] weeks before the current one
  /// (1 = last week … 7 = W1) on ISO [weekday] (1 = Monday … 7 = Sunday).
  const SeedSession.week(
    this.weekOffset,
    this.weekday, {
    required this.hour,
    required this.minute,
    this.categoryIds,
    this.presetKind = PresetKind.all,
    required this.accuracy,
    required this.avgAnswerSeconds,
    required this.questionCount,
  }) : assert(weekOffset != null && weekOffset >= 1 && weekOffset <= 7),
       assert(weekday != null && weekday >= 1 && weekday <= 7),
       _daysAgo = null,
       assert(hour >= 7 && hour <= 22, 'no session may straddle midnight'),
       assert(minute >= 0 && minute <= 59),
       assert(questionCount >= 6 && questionCount <= 12),
       assert(accuracy >= 0 && accuracy <= 100),
       assert(avgAnswerSeconds > 0),
       assert(
         (categoryIds == null) == (presetKind == PresetKind.all),
         'null categoryIds means every registered category (preset all)',
       );

  final int? _daysAgo;

  /// Weeks before the current week for a baseline row; `null` for a streak row.
  final int? weekOffset;

  /// ISO weekday (1 = Monday) for a baseline row; `null` for a streak row.
  final int? weekday;
  final int hour;
  final int minute;

  /// `null` = every registered category, resolved by the seeder.
  final List<String>? categoryIds;
  final PresetKind presetKind;
  final double accuracy;
  final double avgAnswerSeconds;
  final int questionCount;

  bool get isStreakRow => _daysAgo != null;

  /// Days before today for a streak row; `null` for a baseline row.
  int? get daysAgo => _daysAgo;

  int get correctCount => (accuracy * questionCount / 100).round();

  /// A 60-second timed session plus the answer in flight: 60–90 s.
  int get durationSeconds => 60 + (avgAnswerSeconds * 2).round().clamp(0, 30);
}

const _weakest = ['growth_cagr', 'margins_breakeven', 'estimation'];

/// 7 streak rows + 35 baseline rows = 42 sessions. Every streak row is
/// better (higher accuracy, lower seconds) than every baseline row, and the
/// baseline weekly means improve W1 → W7, so per-week accuracy is
/// non-decreasing and speed non-increasing on any install weekday.
const seedSessions = <SeedSession>[
  // Streak: accuracy 80 → 86 %, speed 5.9 → 5.3 s toward today.
  SeedSession.daysAgo(
    6,
    hour: 19,
    minute: 10,
    accuracy: 80,
    avgAnswerSeconds: 5.9,
    questionCount: 10,
  ),
  SeedSession.daysAgo(
    5,
    hour: 8,
    minute: 5,
    categoryIds: ['percentages'],
    presetKind: PresetKind.category,
    accuracy: 81,
    avgAnswerSeconds: 5.8,
    questionCount: 11,
  ),
  SeedSession.daysAgo(
    4,
    hour: 12,
    minute: 40,
    accuracy: 82,
    avgAnswerSeconds: 5.7,
    questionCount: 10,
  ),
  SeedSession.daysAgo(
    3,
    hour: 18,
    minute: 30,
    categoryIds: _weakest,
    presetKind: PresetKind.weakest,
    accuracy: 83,
    avgAnswerSeconds: 5.6,
    questionCount: 9,
  ),
  SeedSession.daysAgo(
    2,
    hour: 21,
    minute: 15,
    accuracy: 84,
    avgAnswerSeconds: 5.5,
    questionCount: 10,
  ),
  SeedSession.daysAgo(
    1,
    hour: 7,
    minute: 50,
    categoryIds: ['multiplication'],
    presetKind: PresetKind.category,
    accuracy: 85,
    avgAnswerSeconds: 5.4,
    questionCount: 11,
  ),
  SeedSession.daysAgo(
    0,
    hour: 18,
    minute: 20,
    accuracy: 86,
    avgAnswerSeconds: 5.3,
    questionCount: 11,
  ),

  // W1 (weekOffset 7): mean 62 % / 8.2 s
  SeedSession.week(
    7,
    1,
    hour: 8,
    minute: 15,
    accuracy: 58,
    avgAnswerSeconds: 8.6,
    questionCount: 7,
  ),
  SeedSession.week(
    7,
    2,
    hour: 19,
    minute: 30,
    categoryIds: ['percentages'],
    presetKind: PresetKind.category,
    accuracy: 60,
    avgAnswerSeconds: 8.4,
    questionCount: 7,
  ),
  SeedSession.week(
    7,
    4,
    hour: 12,
    minute: 5,
    categoryIds: ['multiplication'],
    presetKind: PresetKind.category,
    accuracy: 62,
    avgAnswerSeconds: 8.2,
    questionCount: 7,
  ),
  SeedSession.week(
    7,
    5,
    hour: 18,
    minute: 45,
    accuracy: 64,
    avgAnswerSeconds: 8.0,
    questionCount: 8,
  ),
  SeedSession.week(
    7,
    7,
    hour: 10,
    minute: 20,
    categoryIds: ['division_ratios'],
    presetKind: PresetKind.category,
    accuracy: 66,
    avgAnswerSeconds: 7.8,
    questionCount: 8,
  ),

  // W2 (weekOffset 6): mean 65 % / 7.9 s
  SeedSession.week(
    6,
    1,
    hour: 7,
    minute: 40,
    accuracy: 61,
    avgAnswerSeconds: 8.3,
    questionCount: 7,
  ),
  SeedSession.week(
    6,
    3,
    hour: 20,
    minute: 10,
    categoryIds: ['fractions_percent'],
    presetKind: PresetKind.category,
    accuracy: 63,
    avgAnswerSeconds: 8.1,
    questionCount: 7,
  ),
  SeedSession.week(
    6,
    4,
    hour: 8,
    minute: 30,
    categoryIds: _weakest,
    presetKind: PresetKind.weakest,
    accuracy: 65,
    avgAnswerSeconds: 7.9,
    questionCount: 8,
  ),
  SeedSession.week(
    6,
    6,
    hour: 11,
    minute: 15,
    accuracy: 67,
    avgAnswerSeconds: 7.7,
    questionCount: 8,
  ),
  SeedSession.week(
    6,
    7,
    hour: 17,
    minute: 50,
    categoryIds: ['growth_cagr'],
    presetKind: PresetKind.category,
    accuracy: 69,
    avgAnswerSeconds: 7.5,
    questionCount: 8,
  ),

  // W3 (weekOffset 5): mean 67 % / 7.5 s
  SeedSession.week(
    5,
    2,
    hour: 9,
    minute: 0,
    accuracy: 64,
    avgAnswerSeconds: 7.9,
    questionCount: 8,
  ),
  SeedSession.week(
    5,
    3,
    hour: 18,
    minute: 20,
    categoryIds: ['margins_breakeven'],
    presetKind: PresetKind.category,
    accuracy: 66,
    avgAnswerSeconds: 7.7,
    questionCount: 8,
  ),
  SeedSession.week(
    5,
    5,
    hour: 7,
    minute: 55,
    accuracy: 67,
    avgAnswerSeconds: 7.5,
    questionCount: 8,
  ),
  SeedSession.week(
    5,
    6,
    hour: 15,
    minute: 30,
    categoryIds: ['big_numbers'],
    presetKind: PresetKind.category,
    accuracy: 68,
    avgAnswerSeconds: 7.3,
    questionCount: 9,
  ),
  SeedSession.week(
    5,
    7,
    hour: 21,
    minute: 5,
    accuracy: 70,
    avgAnswerSeconds: 7.1,
    questionCount: 9,
  ),

  // W4 (weekOffset 4): mean 70 % / 7.2 s
  SeedSession.week(
    4,
    1,
    hour: 8,
    minute: 15,
    categoryIds: ['estimation'],
    presetKind: PresetKind.category,
    accuracy: 67,
    avgAnswerSeconds: 7.6,
    questionCount: 8,
  ),
  SeedSession.week(
    4,
    2,
    hour: 19,
    minute: 30,
    accuracy: 69,
    avgAnswerSeconds: 7.4,
    questionCount: 9,
  ),
  SeedSession.week(
    4,
    4,
    hour: 12,
    minute: 5,
    categoryIds: _weakest,
    presetKind: PresetKind.weakest,
    accuracy: 70,
    avgAnswerSeconds: 7.2,
    questionCount: 9,
  ),
  SeedSession.week(
    4,
    5,
    hour: 18,
    minute: 45,
    categoryIds: ['percentages'],
    presetKind: PresetKind.category,
    accuracy: 71,
    avgAnswerSeconds: 7.0,
    questionCount: 9,
  ),
  SeedSession.week(
    4,
    7,
    hour: 10,
    minute: 20,
    accuracy: 73,
    avgAnswerSeconds: 6.8,
    questionCount: 9,
  ),

  // W5 (weekOffset 3): mean 72 % / 6.9 s
  SeedSession.week(
    3,
    1,
    hour: 7,
    minute: 40,
    accuracy: 69,
    avgAnswerSeconds: 7.3,
    questionCount: 9,
  ),
  SeedSession.week(
    3,
    3,
    hour: 20,
    minute: 10,
    categoryIds: ['multiplication'],
    presetKind: PresetKind.category,
    accuracy: 71,
    avgAnswerSeconds: 7.1,
    questionCount: 9,
  ),
  SeedSession.week(
    3,
    4,
    hour: 8,
    minute: 30,
    accuracy: 72,
    avgAnswerSeconds: 6.9,
    questionCount: 9,
  ),
  SeedSession.week(
    3,
    6,
    hour: 11,
    minute: 15,
    categoryIds: ['division_ratios'],
    presetKind: PresetKind.category,
    accuracy: 73,
    avgAnswerSeconds: 6.7,
    questionCount: 10,
  ),
  SeedSession.week(
    3,
    7,
    hour: 17,
    minute: 50,
    accuracy: 75,
    avgAnswerSeconds: 6.5,
    questionCount: 10,
  ),

  // W6 (weekOffset 2): mean 75 % / 6.5 s
  SeedSession.week(
    2,
    2,
    hour: 9,
    minute: 0,
    categoryIds: ['fractions_percent'],
    presetKind: PresetKind.category,
    accuracy: 72,
    avgAnswerSeconds: 6.9,
    questionCount: 9,
  ),
  SeedSession.week(
    2,
    3,
    hour: 18,
    minute: 20,
    accuracy: 74,
    avgAnswerSeconds: 6.7,
    questionCount: 10,
  ),
  SeedSession.week(
    2,
    5,
    hour: 7,
    minute: 55,
    categoryIds: _weakest,
    presetKind: PresetKind.weakest,
    accuracy: 75,
    avgAnswerSeconds: 6.5,
    questionCount: 10,
  ),
  SeedSession.week(
    2,
    6,
    hour: 15,
    minute: 30,
    accuracy: 76,
    avgAnswerSeconds: 6.3,
    questionCount: 10,
  ),
  SeedSession.week(
    2,
    7,
    hour: 21,
    minute: 5,
    categoryIds: ['growth_cagr'],
    presetKind: PresetKind.category,
    accuracy: 78,
    avgAnswerSeconds: 6.1,
    questionCount: 10,
  ),

  // W7 (weekOffset 1): mean 78 % / 6.2 s
  SeedSession.week(
    1,
    1,
    hour: 8,
    minute: 15,
    accuracy: 77,
    avgAnswerSeconds: 6.4,
    questionCount: 10,
  ),
  SeedSession.week(
    1,
    2,
    hour: 19,
    minute: 30,
    categoryIds: ['big_numbers'],
    presetKind: PresetKind.category,
    accuracy: 77,
    avgAnswerSeconds: 6.3,
    questionCount: 10,
  ),
  SeedSession.week(
    1,
    4,
    hour: 12,
    minute: 5,
    accuracy: 78,
    avgAnswerSeconds: 6.2,
    questionCount: 11,
  ),
  SeedSession.week(
    1,
    5,
    hour: 18,
    minute: 45,
    categoryIds: ['estimation'],
    presetKind: PresetKind.category,
    accuracy: 79,
    avgAnswerSeconds: 6.1,
    questionCount: 11,
  ),
  SeedSession.week(
    1,
    7,
    hour: 10,
    minute: 20,
    accuracy: 79,
    avgAnswerSeconds: 6.0,
    questionCount: 11,
  ),
];
