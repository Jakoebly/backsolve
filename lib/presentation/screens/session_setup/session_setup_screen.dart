import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/category_providers.dart';
import '../../providers/session_preset_provider.dart';
import '../../providers/session_setup_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_picker.dart';
import '../../widgets/coming_soon_sheet.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_label.dart';
import '../../widgets/segmented_control.dart';
import '../../widgets/session_type_card.dart';
import '../../widgets/setup_back_button.dart';
import 'unknown_preset_screen.dart';

/// Session Setup (`docs/mockups_screens/session_setup.png`, FR-019–FR-023,
/// FR-025): the back control and the preset's title, then — for a custom
/// session only — the CATEGORIES picker, the SESSION TYPE cards, the
/// DIFFICULTY and ANSWERS controls with their helper lines, and the Start
/// button pinned below the scrolling body. [kind] and
/// [categoryId] come from the route's query parameters; a preset that
/// cannot be built (unknown category id) shows [UnknownPresetScreen].
///
/// The selections live in [sessionSetupControllerProvider], which is only
/// created once the preset has loaded (its defaults come from the preset)
/// and is disposed when the route pops (FR-026).
class SessionSetupScreen extends ConsumerWidget {
  const SessionSetupScreen({super.key, required this.kind, this.categoryId});

  final PresetKind kind;
  final String? categoryId;

  PresetKey get presetKey => (kind: kind, categoryId: categoryId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(sessionPresetProvider(presetKey));
    if (preset.hasError) return const UnknownPresetScreen();
    final loaded = preset.value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(preset: loaded),
                    if (loaded != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _Sections(presetKey: presetKey),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: loaded == null
                  ? const PrimaryButton(label: 'Start Session', onPressed: null)
                  : _StartButton(presetKey: presetKey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back control and title, then the line listing the categories the
/// session covers (FR-019). Blank while the preset is loading.
class _Header extends ConsumerWidget {
  const _Header({required this.preset});

  final SessionPreset? preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = this.preset;
    final names = preset == null ? null : _namesLine(ref, preset);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SetupBackButton(onTap: () => context.pop()),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(preset?.title ?? '', style: AppTextStyles.pageTitle),
            ),
          ],
        ),
        if (names != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(names, style: AppTextStyles.subtitle),
        ],
      ],
    );
  }

  /// The categories the session covers, or `null` to hide the line.
  ///
  /// A custom session never shows it (user request, 2026-09-24): the picker
  /// right below already shows what is selected, and a line that grew with
  /// the selection pushed the whole grid down a row as the user tapped.
  /// Every other preset lists its fixed set, and hides the line when it
  /// covers a single category — the title already is that category's name.
  String? _namesLine(WidgetRef ref, SessionPreset preset) {
    if (preset.kind == PresetKind.custom) return null;
    if (preset.categoryIds.length < 2) return null;
    return _categoryNames(ref, preset.categoryIds);
  }

  /// The stored names of [ids] in display order, joined by " · ".
  static String _categoryNames(WidgetRef ref, List<String> ids) {
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    return [
      for (final category in categories)
        if (ids.contains(category.id)) category.name,
    ].join(' · ');
  }
}

/// CATEGORIES (custom only), SESSION TYPE, DIFFICULTY and ANSWERS
/// (FR-020–FR-023), bound to the preset's controller.
class _Sections extends ConsumerWidget {
  const _Sections({required this.presetKey});

  final PresetKey presetKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionSetupControllerProvider(presetKey));
    final controller = ref.watch(
      sessionSetupControllerProvider(presetKey).notifier,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A custom session picks its categories here, above everything
        // else; every other preset arrives with its set fixed (FR-020).
        if (presetKey.kind == PresetKind.custom) ...[
          const SectionLabel('Categories'),
          CategoryPicker(
            categories:
                ref.watch(categoriesProvider).value ?? const <Category>[],
            selectedIds: state.selectedCategoryIds.toSet(),
            onToggle: controller.toggleCategory,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        const SectionLabel('Session type'),
        SessionTypeCard(
          title: 'Timed Session',
          subtitle: '${SessionType.timed.durationSeconds} seconds',
          selected: state.type == SessionType.timed,
          onTap: () => controller.setType(SessionType.timed),
        ),
        const SizedBox(height: AppSpacing.xs),
        SessionTypeCard(
          title: 'Fixed Set',
          subtitle: '${SessionType.fixedSet.questionCount} questions, no clock',
          selected: state.type == SessionType.fixedSet,
          onTap: () => controller.setType(SessionType.fixedSet),
        ),
        const SizedBox(height: AppSpacing.xs),
        SessionTypeCard(
          title: 'Open',
          subtitle: 'Practice until you stop',
          selected: state.type == SessionType.open,
          onTap: () => controller.setType(SessionType.open),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Difficulty'),
        SegmentedControl<DifficultyLevel?>(
          options: [
            (null, 'Adaptive'),
            for (final level in DifficultyLevel.values)
              (level, formatLevel(level)),
          ],
          selected: state.fixedLevel,
          onChanged: controller.setDifficulty,
          firstIntrinsic: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Both variants of this line are the same length by construction
        // (see `difficultyHelper`), so the block keeps its height — and its
        // last line stays full — whichever difficulty is selected.
        Text(
          difficultyHelper(controller.difficultySetting),
          style: AppTextStyles.helper,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Answers'),
        SegmentedControl<AnswerMode>(
          options: const [
            (AnswerMode.exact, 'Exact'),
            (AnswerMode.estimation, 'Estimation'),
          ],
          selected: state.answerMode,
          onChanged: controller.setAnswerMode,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(answerModeHelper(state.answerMode), style: AppTextStyles.helper),
      ],
    );
  }
}

/// "Start Session": persists the session, then shows the placeholder;
/// dismissing it leaves the user here with the selections intact (FR-025,
/// US3 scenario 6). Disabled without a category or while a start is in
/// flight (FR-020).
class _StartButton extends ConsumerWidget {
  const _StartButton({required this.presetKey});

  final PresetKey presetKey;

  Future<void> _start(
    BuildContext context,
    SessionSetupController controller,
  ) async {
    await controller.start();
    if (context.mounted) await showComingSoon(context, 'Question answering');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild whenever a selection (or the in-flight flag) changes.
    ref.watch(sessionSetupControllerProvider(presetKey));
    final controller = ref.watch(
      sessionSetupControllerProvider(presetKey).notifier,
    );
    return PrimaryButton(
      label: 'Start Session',
      onPressed: controller.canStart ? () => _start(context, controller) : null,
    );
  }
}
