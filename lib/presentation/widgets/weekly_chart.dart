import 'dart:math' as math;

import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'section_label.dart';

/// The LAST 8 WEEKS card of home.png (FR-007, research.md R-09): fl_chart
/// draws the accuracy bars, grid and W1–W8 labels; a sibling [CustomPaint]
/// draws the speed markers with the same column math. A week without a
/// completed session shows no bar and no marker, only its label.
///
/// With [fillHeight] the plot takes the height the card is offered, between
/// `chartPlotMinHeight` and `chartPlotMaxHeight` (Home lets the chart absorb
/// the screen height so nothing scrolls), and reports the minimum as its
/// intrinsic height so an [IntrinsicHeight] ancestor can size the screen;
/// otherwise the plot is the mockup's fixed `chartPlotHeight`.
class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.weeks, this.fillHeight = false});

  /// W1 → W8; the last entry is the current week and is emphasised.
  final List<WeeklySummary> weeks;

  /// Whether the plot expands to the height available to the card (the
  /// card must then receive a bounded height).
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final plot = Stack(
      fit: StackFit.expand,
      children: [
        BarChart(_barData(), duration: Duration.zero),
        IgnorePointer(
          child: CustomPaint(
            painter: _SpeedMarkerPainter(
              weeks: weeks,
              labelReserve: AppSizes.chartLabelReserve,
            ),
          ),
        ),
      ],
    );
    return AppCard(
      radius: AppRadius.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The mockup keeps the legend in the header row, to the right of
          // the section label, with the 100 % grid line ≈ lg below the row.
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(child: SectionLabel('Last 8 weeks', spacing: 0)),
                SizedBox(width: AppSpacing.sm),
                _Legend(),
              ],
            ),
          ),
          if (fillHeight)
            // Loose: the plot takes the offered height up to its cap, and
            // the card shrink-wraps whatever the plot ends up with.
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight:
                      AppSizes.chartPlotMaxHeight + AppSizes.chartLabelReserve,
                ),
                child: _FixedIntrinsicHeight(
                  height:
                      AppSizes.chartPlotMinHeight + AppSizes.chartLabelReserve,
                  child: plot,
                ),
              ),
            )
          else
            SizedBox(
              height: AppSizes.chartPlotHeight + AppSizes.chartLabelReserve,
              width: double.infinity,
              child: plot,
            ),
        ],
      ),
    );
  }

  BarChartData _barData() {
    const gridLine = FlLine(
      color: AppColors.border,
      strokeWidth: AppSizes.cardBorderWidth,
    );
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      minY: 0,
      maxY: 100,
      barGroups: [
        for (final (index, week) in weeks.indexed)
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: week.accuracy ?? 0,
                width: AppSizes.chartBarWidth,
                color: index == weeks.length - 1
                    ? AppColors.primary
                    : AppColors.barMuted,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xs),
                ),
              ),
            ],
          ),
      ],
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (_) => gridLine,
      ),
      // fl_chart never draws grid lines at minY/maxY; the mockup shows the
      // 100 % line, so it is added explicitly.
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 100,
            color: AppColors.border,
            strokeWidth: AppSizes.cardBorderWidth,
          ),
        ],
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: AppSizes.chartLabelReserve,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              space: AppSpacing.xs,
              child: Text(
                'W${value.toInt() + 1}',
                style: AppTextStyles.caption,
              ),
            ),
          ),
        ),
      ),
      barTouchData: const BarTouchData(enabled: false),
    );
  }
}

/// Reports a constant intrinsic height for the plot. fl_chart lays itself
/// out with a `LayoutBuilder`, which cannot answer intrinsic-size queries,
/// so this proxy answers them instead (with the plot's minimum); the actual
/// height still comes from the incoming constraints.
class _FixedIntrinsicHeight extends SingleChildRenderObjectWidget {
  const _FixedIntrinsicHeight({required this.height, required super.child});

  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFixedIntrinsicHeight(height);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFixedIntrinsicHeight renderObject,
  ) {
    renderObject.height = height;
  }
}

class _RenderFixedIntrinsicHeight extends RenderProxyBox {
  _RenderFixedIntrinsicHeight(this._height);

  double _height;
  set height(double value) {
    if (value == _height) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height;

  @override
  double computeMaxIntrinsicHeight(double width) => _height;

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}

/// "■ Accuracy  ● Speed" in `caption`.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.legendSwatch,
          height: AppSizes.legendSwatch,
          decoration: BoxDecoration(
            color: AppColors.primary,
            // theme-tokens.md §4: the legend square's radius is half of xs.
            borderRadius: BorderRadius.circular(AppRadius.xs / 2),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        const Text('Accuracy', style: AppTextStyles.caption),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: AppSizes.legendSwatch,
          height: AppSizes.legendSwatch,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        const Text('Speed', style: AppTextStyles.caption),
      ],
    );
  }
}

/// Draws one `ink` dot with a `surface` ring per week that has data, at the
/// bar's column centre — `x = (i + 0.5) × plotWidth / n`, the same math
/// fl_chart uses for `BarChartAlignment.spaceAround` — and at a height that
/// maps the week's average seconds onto the plot: faster = higher, scaled
/// over the min/max of the weeks with data with 10 % padding at both ends.
/// A single distinct value sits mid-height.
class _SpeedMarkerPainter extends CustomPainter {
  const _SpeedMarkerPainter({required this.weeks, required this.labelReserve});

  final List<WeeklySummary> weeks;

  /// Height fl_chart reserves for the W1–W8 labels below the plot.
  final double labelReserve;

  /// Fraction of [plotHeight] kept clear above the fastest and below the
  /// slowest marker.
  static const double _padding = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    final speeds = [for (final week in weeks) ?week.avgAnswerSeconds];
    if (speeds.isEmpty || weeks.isEmpty) return;

    final plotHeight = size.height - labelReserve;
    if (plotHeight <= 0) return;
    final fastest = speeds.reduce(math.min);
    final slowest = speeds.reduce(math.max);
    final columnWidth = size.width / weeks.length;
    final ringPaint = Paint()..color = AppColors.speedDotRing;
    final dotPaint = Paint()..color = AppColors.ink;
    final dotRadius = AppSizes.speedDot / 2;

    for (final (index, week) in weeks.indexed) {
      final seconds = week.avgAnswerSeconds;
      if (seconds == null) continue;
      // 0 = fastest (top), 1 = slowest (bottom).
      final position = slowest == fastest
          ? 0.5
          : (seconds - fastest) / (slowest - fastest);
      final y = plotHeight * (_padding + (1 - 2 * _padding) * position);
      final centre = Offset((index + 0.5) * columnWidth, y);
      canvas.drawCircle(centre, dotRadius + AppSizes.speedDotRing, ringPaint);
      canvas.drawCircle(centre, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SpeedMarkerPainter oldDelegate) {
    if (oldDelegate.labelReserve != labelReserve) return true;
    if (oldDelegate.weeks.length != weeks.length) return true;
    for (var i = 0; i < weeks.length; i++) {
      if (oldDelegate.weeks[i] != weeks[i]) return true;
    }
    return false;
  }
}
