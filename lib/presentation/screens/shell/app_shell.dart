import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/coming_soon_sheet.dart';

/// The tab shell around Home and Practice: the branch body with the floating
/// bottom bar of `home.png` / `practice.png` over it (FR-002). Progress is a
/// placeholder destination (FR-003, contracts/routes.md "Shell").
class AppShell extends StatelessWidget {
  const AppShell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == _NavBar.progressIndex) {
      showComingSoon(context, 'Progress');
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // With `extendBody` the Scaffold would hand the body a MediaQuery whose
    // bottom padding equals the bar's height, so a screen's SafeArea would
    // stop above the bar instead of scrolling under it. Restoring the outer
    // metrics leaves screens the plain system inset; they keep their last
    // item clear of the bar with an explicit `navBarHeight` bottom padding.
    final outerMetrics = MediaQuery.of(context);
    return Scaffold(
      body: MediaQuery(data: outerMetrics, child: navigationShell),
      extendBody: true,
      bottomNavigationBar: _NavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.currentIndex, required this.onTap});

  static const int progressIndex = 2;

  /// Bar 58 dp, pill 48 dp, 1 dp border: the pill sits 4 dp inside the border
  /// (measured 5–6 px in the mockups).
  static const double _inset =
      (AppSizes.navBarHeight - AppSizes.navPillHeight) / 2 -
      AppSizes.cardBorderWidth;

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // The bar floats over the body, so scrolled content would otherwise
    // show through beside and below it. This `background` strip fills the
    // whole slot — full width, from the top edge of the bar down past the
    // system inset to the bottom of the screen — and the Scaffold paints
    // the `bottomNavigationBar` after the body, so content slides under it
    // and disappears at the bar's top edge. The box takes its size from
    // the bar below, so it needs no height of its own.
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          child: Container(
            height: AppSizes.navBarHeight,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: AppColors.border,
                width: AppSizes.cardBorderWidth,
              ),
            ),
            padding: const EdgeInsets.all(_inset),
            child: Row(
              children: [
                _Destination(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _Destination(
                  icon: Icons.calculate_rounded,
                  label: 'Practice',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _Destination(
                  icon: Icons.trending_up_rounded,
                  label: 'Progress',
                  selected: currentIndex == progressIndex,
                  onTap: () => onTap(progressIndex),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.lgAll,
            onTap: onTap,
            child: Center(
              child: Container(
                width: AppSizes.navPillWidth,
                height: AppSizes.navPillHeight,
                decoration: selected
                    ? const BoxDecoration(
                        color: AppColors.navActivePill,
                        borderRadius: AppRadius.lgAll,
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: AppSizes.iconNav,
                      color: selected
                          ? AppColors.navActiveIcon
                          : AppColors.navInactive,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    ExcludeSemantics(
                      child: Text(
                        label,
                        style: selected
                            ? AppTextStyles.navLabelActive
                            : AppTextStyles.navLabelInactive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
