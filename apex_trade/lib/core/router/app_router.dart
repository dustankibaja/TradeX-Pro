import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/engine_status/engine_status_screen.dart';
import '../../features/signals/signals_screen.dart';
import '../../features/chart/chart_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/main_shell.dart';

// Route names — we use these like labels so we never mistype a path
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const home = '/home';
  static const signals = '/signals';
  static const chart = '/chart';
  static const analytics = '/analytics';
  static const history = '/history';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const subscription = '/subscription';
  static const settings = '/settings';
  static const engineStatus = '/engine-status';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // Splash, onboarding and auth are full screen — no bottom nav
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadePage(
          state, const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _fadePage(
          state, const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => _fadePage(
          state, const AuthScreen(),
        ),
      ),

      // Engine pairing is independent of the demo bottom navigation.
      GoRoute(
        path: AppRoutes.engineStatus,
        pageBuilder: (context, state) => _fadePage(
          state, const EngineStatusScreen(),
        ),
      ),

      // Main app shell — has the bottom navigation bar
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _fadePage(
              state, const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.signals,
            pageBuilder: (context, state) => _fadePage(
              state, const SignalsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.chart,
            pageBuilder: (context, state) => _fadePage(
              state, const ChartScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (context, state) => _fadePage(
              state, const AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (context, state) => _fadePage(
              state, const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (context, state) => _fadePage(
              state, const NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _fadePage(
              state, const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.subscription,
            pageBuilder: (context, state) => _fadePage(
              state, const SubscriptionScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => _fadePage(
              state, const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// Smooth fade transition between every screen
CustomTransitionPage _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOut).animate(animation),
        child: child,
      );
    },
  );
}