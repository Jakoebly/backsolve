import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/practice/practice_screen.dart';
import '../screens/session_setup/session_setup_screen.dart';
import '../screens/session_setup/unknown_preset_screen.dart';
import '../screens/shell/app_shell.dart';
import 'app_routes.dart';

/// The single declared route table (Constitution V, contracts/routes.md,
/// research.md R-10): a stateful shell with the Home and Practice branches
/// plus the top-level Session Setup route. Exactly three named routes.
///
/// Planned additions (`session`, `progress`) are appended; the rows here do
/// not change.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.homePath,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRoutes.home,
              path: AppRoutes.homePath,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRoutes.practice,
              path: AppRoutes.practicePath,
              builder: (context, state) => const PracticeScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: AppRoutes.sessionSetup,
      path: AppRoutes.sessionSetupPath,
      builder: (context, state) =>
          _buildSessionSetup(state.uri.queryParameters),
    ),
  ],
  errorBuilder: (context, state) => const UnknownPresetScreen(),
);

/// `mode` must name a [PresetKind]; `category` is required for `category`
/// mode and must be a registered id. Anything else shows the plain
/// "Unknown session preset" page (contracts/routes.md) — never a crash.
Widget _buildSessionSetup(Map<String, String> query) {
  final mode = query[SessionSetupParams.mode];
  final kind = mode == null ? null : PresetKind.values.asNameMap()[mode];
  if (kind == null) return const UnknownPresetScreen();

  if (kind == PresetKind.category) {
    final categoryId = query[SessionSetupParams.category];
    if (categoryId == null || findCategoryDefinition(categoryId) == null) {
      return const UnknownPresetScreen();
    }
    return SessionSetupScreen(kind: kind, categoryId: categoryId);
  }
  return SessionSetupScreen(kind: kind);
}
