import 'package:flutter/material.dart';

import 'presentation/navigation/app_router.dart';
import 'presentation/theme/app_theme.dart';

/// The root widget: one theme, one route table.
class BacksolveApp extends StatelessWidget {
  const BacksolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Backsolve',
      theme: buildAppTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
