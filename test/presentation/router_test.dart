import 'package:backsolve/presentation/navigation/app_router.dart';
import 'package:backsolve/presentation/navigation/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Every [GoRoute] in the table, including those nested in shell branches.
List<GoRoute> collectGoRoutes(Iterable<RouteBase> routes) => [
  for (final route in routes) ...[
    if (route is GoRoute) route,
    ...collectGoRoutes(route.routes),
  ],
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('appRouter (contracts/routes.md "Verification")', () {
    test('declares exactly the three named routes with their paths', () {
      final routes = collectGoRoutes(appRouter.configuration.routes);
      expect(routes, hasLength(3));
      expect(
        {for (final route in routes) route.name: route.path},
        {
          AppRoutes.home: AppRoutes.homePath,
          AppRoutes.practice: AppRoutes.practicePath,
          AppRoutes.sessionSetup: AppRoutes.sessionSetupPath,
        },
      );
      expect(
        {AppRoutes.home, AppRoutes.practice, AppRoutes.sessionSetup},
        {'home', 'practice', 'sessionSetup'},
      );
      expect(
        [
          AppRoutes.homePath,
          AppRoutes.practicePath,
          AppRoutes.sessionSetupPath,
        ],
        ['/', '/practice', '/session-setup'],
      );
    });

    test('home and practice are shell branches; sessionSetup is top-level', () {
      final topLevel = appRouter.configuration.routes;
      expect(topLevel, hasLength(2));
      final shell = topLevel.whereType<StatefulShellRoute>().single;
      expect(shell.branches, hasLength(2));
      expect(
        shell.branches
            .map((b) => b.routes.whereType<GoRoute>().single.name)
            .toList(),
        [AppRoutes.home, AppRoutes.practice],
      );
      final sessionSetup = topLevel.whereType<GoRoute>().single;
      expect(sessionSetup.name, AppRoutes.sessionSetup);
    });

    test('resolves /session-setup?mode=category&category=percentages to the '
        'sessionSetup route', () {
      final uri = Uri.parse(
        '/session-setup?mode=category&category=percentages',
      );
      final match = appRouter.configuration.findMatch(uri);
      expect(match.isError, isFalse);
      final route = match.last.route;
      expect(route, isA<GoRoute>());
      expect(route.name, AppRoutes.sessionSetup);
      expect(match.uri.queryParameters, {
        SessionSetupParams.mode: 'category',
        SessionSetupParams.category: 'percentages',
      });
    });

    test('resolves the two shell branches', () {
      for (final (path, name) in [
        (AppRoutes.homePath, AppRoutes.home),
        (AppRoutes.practicePath, AppRoutes.practice),
      ]) {
        final match = appRouter.configuration.findMatch(Uri.parse(path));
        expect(match.isError, isFalse, reason: path);
        expect(match.last.route.name, name, reason: path);
      }
    });

    test('reports an error match for an unknown path', () {
      final match = appRouter.configuration.findMatch(Uri.parse('/nope'));
      expect(match.isError, isTrue);
    });

    test('the initial location is / (FR-001)', () {
      expect(appRouter.routeInformationProvider.value.uri.path, '/');
      expect(appRouter.routeInformationProvider.value.uri.toString(), '/');
    });
  });
}
