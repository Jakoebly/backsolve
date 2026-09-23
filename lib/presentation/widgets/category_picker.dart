import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// The CATEGORIES picker of a custom session (FR-020, US5 scenario 2): the
/// stored [categories] as a two-column grid, laid out like the Practice
/// grid — rows of two, `sm` apart, each row as tall as its taller card, so
/// a wrapped name grows the row instead of overflowing.
///
/// Tapping a card calls [onToggle] with its id; a selected card carries the
/// 2 dp `primary` border and a filled check circle
/// (theme-tokens.md §6 "Selected session-type card" / "Radio").
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Category> categories;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < categories.length; row += 2) ...[
          if (row > 0) const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, category)
                    in categories.skip(row).take(2).indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _PickerCard(
                      category: category,
                      selected: selectedIds.contains(category.id),
                      onTap: () => onToggle(category.id),
                    ),
                  ),
                ],
                // A lone last card keeps its column width.
                if (categories.length - row == 1) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One cell: the name with the check circle at the trailing edge.
class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: AppCard(
        radius: AppRadius.md,
        selected: selected,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(category.name, style: AppTextStyles.categoryName),
            ),
            const SizedBox(width: AppSpacing.xs),
            _CheckCircle(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// Ø `radio`: a 2 dp `radioRing` ring, or a `primary` disc with a white
/// check when selected.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.radio,
      height: AppSizes.radio,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : null,
        border: selected
            ? null
            : Border.all(color: AppColors.radioRing, width: AppSizes.radioRing),
      ),
      child: selected
          ? const Icon(
              Icons.check,
              size: AppSizes.iconXs,
              color: AppColors.onPrimary,
            )
          : null,
    );
  }
}
