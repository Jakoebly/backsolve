import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The DIFFICULTY and ANSWERS controls of session_setup.png (FR-022,
/// FR-023; theme-tokens.md §6 "Segmented control"): a `segmentTrack` track
/// with the selected option on a white thumb.
///
/// The options share the width equally; with [firstIntrinsic] the first one
/// takes its own width plus `md` and the rest share the remainder — the
/// "Adaptive | L1 … L5" layout.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.firstIntrinsic = false,
  });

  /// Each option's value and label, in display order.
  final List<(T value, String label)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool firstIntrinsic;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.segmentHeight,
      padding: const EdgeInsets.all(AppSizes.segmentInnerPadding),
      decoration: const BoxDecoration(
        color: AppColors.segmentTrack,
        borderRadius: AppRadius.trackAll,
      ),
      child: Row(
        children: [
          for (final (index, (value, label)) in options.indexed)
            if (firstIntrinsic && index == 0)
              _Segment(
                label: label,
                selected: value == selected,
                onTap: () => onChanged(value),
                // Intrinsic width + md (xs on either side).
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              )
            else
              Expanded(
                child: _Segment(
                  label: label,
                  selected: value == selected,
                  onTap: () => onChanged(value),
                ),
              ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: DecoratedBox(
        // The white thumb; unselected segments paint nothing.
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : null,
          borderRadius: AppRadius.smAll,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.smAll,
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Center(
                child: Text(
                  label,
                  style: selected
                      ? AppTextStyles.segmentSelected
                      : AppTextStyles.segmentUnselected,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
