import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/automation/automation_screen.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/maintenance/maintenance_screen.dart';
import '../../features/disease_library/disease_library_screen.dart';
import '../../features/disease_library/disease_detail_screen.dart';
import '../../features/disease_library/disease_scan_screen.dart';
import '../../features/irrigation_advisor/irrigation_advisor_screen.dart';
import '../../providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null; // splash decides its own navigation
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/maintenance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/disease-library',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DiseaseLibraryScreen(),
        routes: [
          GoRoute(
            path: 'scan',
            builder: (context, state) => const DiseaseScanScreen(),
          ),
          GoRoute(
            path: ':diseaseId',
            builder: (context, state) =>
                DiseaseDetailScreen(diseaseId: state.pathParameters['diseaseId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/irrigation-advisor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IrrigationAdvisorScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/automation', builder: (context, state) => const AutomationScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
