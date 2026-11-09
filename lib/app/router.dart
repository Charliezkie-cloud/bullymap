import 'package:bullymap/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:bullymap/features/settings/presentation/screens/settings_screen.dart';
import 'package:bullymap/features/intro/presentation/screens/intro_screen.dart';
import 'package:bullymap/features/home/presentation/screens/home_screen.dart';
import 'package:bullymap/app/routes.dart';
import 'package:bullymap/widgets/main_navigation_scaffold.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.intro,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainNavigationScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(title: "Home")
            ),
          ]
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.navigation,
              name: 'navigation',
              builder: (context, state) => const NavigationScreen(title: "Navigation")
            ),
          ]
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              name: 'settings',
              builder: (context, state) => const SettingsScreen(title: "Settings")
            ),
          ]
        ),
      ]
    ),

    GoRoute(
      path: Routes.intro,
      name: 'intro',
      builder: (context, state) => const IntroScreen(title: "Intro")
    ),
  ],
  // errorBuilder: (context, state) => NotFoundScreen(error: state.error),
);