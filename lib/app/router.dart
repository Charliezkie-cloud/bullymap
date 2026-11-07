import 'package:bullymap/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:bullymap/features/settings/presentation/screens/settings_screen.dart';
import 'package:bullymap/features/intro/presentation/screens/intro_screen.dart';
import 'package:bullymap/features/home/presentation/screens/home_screen.dart';
import 'package:bullymap/app/routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.intro,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.intro,
      name: 'intro',
      builder: (context, state) => const IntroScreen(title: "Intro")
    ),
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(title: "Home")
    ),
    GoRoute(
      path: Routes.navigation,
      name: 'navigation',
      builder: (context, state) => const NavigationScreen(title: "Navigation")
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(title: "Settings")
    ),
  ],
  // errorBuilder: (context, state) => NotFoundScreen(error: state.error),
);