import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_providers.dart';
import 'database_providers.dart';
import 'session_preset_provider.dart';

/// What the user has chosen on Session Setup (FR-021–FR-023, FR-020).
final class SessionSetupState {
  const SessionSetupState({
    required this.type,
    required this.fixedLevel,
    required this.answerMode,
    required this.selectedCategoryIds,
    this.isStarting = false,
  });

  final SessionType type;

  /// The fixed level, or `null` for adaptive difficulty.
  final DifficultyLevel? fixedLevel;

  final AnswerMode answerMode;

  /// Ids of the categories the session will cover, in display order.
  final List<String> selectedCategoryIds;

  /// True while `start()` is persisting the session.
  final bool isStarting;

  bool get isAdaptive => fixedLevel == null;

  /// [fixedLevel] is a getter so that `fixedLevel: () => null` can clear
  /// it; omit it to keep the current value.
  SessionSetupState copyWith({
    SessionType? type,
    DifficultyLevel? Function()? fixedLevel,
    AnswerMode? answerMode,
    List<String>? selectedCategoryIds,
    bool? isStarting,
  }) {
    return SessionSetupState(
      type: type ?? this.type,
      fixedLevel: fixedLevel == null ? this.fixedLevel : fixedLevel(),
      answerMode: answerMode ?? this.answerMode,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      isStarting: isStarting ?? this.isStarting,
    );
  }
}

/// The Session Setup selections for one preset, alive while the screen is
/// open: rotation and resume keep the provider (and the selections); popping
/// the route disposes it, so the next open starts from the preset's
/// defaults again (FR-026, research.md R-11).
class SessionSetupController extends Notifier<SessionSetupState> {
  SessionSetupController(this.key);

  final PresetKey key;

  /// Timed / adaptive / exact over the preset's categories (spec
  /// Assumptions "Session Setup defaults"). The preset is read, not
  /// watched, so a later category update never resets the selections.
  @override
  SessionSetupState build() {
    final preset = ref.read(sessionPresetProvider(key)).value;
    return SessionSetupState(
      type: SessionType.timed,
      fixedLevel: null,
      answerMode: AnswerMode.exact,
      selectedCategoryIds: preset?.categoryIds ?? const [],
    );
  }

  void setType(SessionType type) => state = state.copyWith(type: type);

  /// `null` selects adaptive difficulty (FR-022).
  void setDifficulty(DifficultyLevel? fixedLevel) =>
      state = state.copyWith(fixedLevel: () => fixedLevel);

  void setAnswerMode(AnswerMode answerMode) =>
      state = state.copyWith(answerMode: answerMode);

  /// The adaptive start level: the rounded mean level of the selected
  /// categories, or the overall level while nothing is selected (FR-022,
  /// FR-035; spec edge case "custom session with zero categories").
  DifficultyLevel get startLevel {
    final categories = ref.read(categoriesProvider).value ?? const [];
    final selected = categories.where(
      (category) => state.selectedCategoryIds.contains(category.id),
    );
    if (selected.isNotEmpty) return startLevelFor(selected);
    if (categories.isNotEmpty) return overallLevel(categories);
    // Unreachable through the screen: it only builds this controller once
    // the preset — and therefore the category list — has loaded.
    throw StateError('Session Setup needs the stored categories');
  }

  DifficultySetting get difficultySetting {
    final fixedLevel = state.fixedLevel;
    return fixedLevel == null
        ? AdaptiveDifficultySetting(startLevel)
        : FixedDifficultySetting(fixedLevel);
  }

  /// Start is enabled only with at least one category and no start in
  /// flight (FR-020).
  bool get canStart => state.selectedCategoryIds.isNotEmpty && !state.isStarting;

  /// Persists an unfinished session with the current selections and the
  /// preset's kind (FR-025) and returns it as stored.
  Future<Session> start() async {
    if (!canStart) {
      throw StateError('Session Setup cannot start a session right now');
    }
    final config = SessionConfig(
      type: state.type,
      difficulty: difficultySetting,
      answerMode: state.answerMode,
      categoryIds: state.selectedCategoryIds,
      presetKind: key.kind,
    );
    state = state.copyWith(isStarting: true);
    try {
      return await ref
          .read(sessionRepositoryProvider)
          .start(config, startedAt: ref.read(clockProvider)());
    } finally {
      // The screen may have been popped (and this provider disposed) while
      // the write was in flight.
      if (ref.mounted) state = state.copyWith(isStarting: false);
    }
  }
}

final sessionSetupControllerProvider = NotifierProvider.autoDispose
    .family<SessionSetupController, SessionSetupState, PresetKey>(
      SessionSetupController.new,
    );
