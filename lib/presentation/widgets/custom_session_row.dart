import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "Custom session" entry that opens the CATEGORIES section of Practice
/// (practice.png, FR-015): a `surfaceMuted` circle with the checklist glyph,
/// the title over "Pick the categories to include", and a trailing chevron.
///
/// Unlike the other white cards its outline is dashed in the mockup, so it
/// paints its own border instead of using `AppCard`. It is at least
/// `customSessionRowHeight` tall and grows with its text, like the category
/// cards next to it.
class CustomSessionRow extends StatelessWidget {
  const CustomSessionRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: const _DashedBorderPainter(),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.customSessionRowHeight,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdAll,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Center(
              child: Row(
                children: [
                  Container(
                    width: AppSizes.customIconCircle,
                    height: AppSizes.customIconCircle,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom session',
                          style: AppTextStyles.optionTitleCompact,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Pick the categories to include',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.chevron_right,
                    size: AppSizes.iconNav,
                    color: AppColors.navInactive,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 1 dp `border`-coloured dashed rounded rectangle (`dashLength` on,
/// `dashGap` off) drawn just inside the widget's bounds.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.cardBorderWidth;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadius.md),
        ).deflate(AppSizes.cardBorderWidth / 2),
      );
    for (final metric in outline.computeMetrics()) {
      var start = 0.0;
      while (start < metric.length) {
        final end = math.min(start + AppSizes.dashLength, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + AppSizes.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
