import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';

/// Hosts the 5 primary tabs (Home, Analytics, Automation, Alerts, Profile)
/// inside a single persistent [NavigationBar] using GoRouter's
/// StatefulShellRoute so each tab keeps its own navigation stack & scroll
/// position when switching back and forth.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.insert_chart_outlined_rounded),
            selectedIcon: const Icon(Icons.insert_chart_rounded),
            label: l10n.t('analytics'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_mode_outlined),
            selectedIcon: const Icon(Icons.auto_mode_rounded),
            label: l10n.t('automation'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: l10n.t('alerts'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.t('profile'),
          ),
        ],
      ),
    );
  }
}
