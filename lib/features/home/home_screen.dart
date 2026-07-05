import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pump_provider.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_view.dart';
import '../../widgets/pump_switcher_sheet.dart';
import 'widgets/tank_level_card.dart';
import 'widgets/pump_status_card.dart';
import 'widgets/quick_stats_grid.dart';
import 'widgets/weather_card.dart';
import 'widgets/recent_alerts_section.dart';
import 'widgets/quick_actions_row.dart';
import '../irrigation_advisor/widgets/irrigation_advisor_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greetingKey() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 17) return 'good_afternoon';
    return 'good_evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final userAsync = ref.watch(currentUserProvider);
    final pumpAsync = ref.watch(activePumpStatusProvider);
    final tanksAsync = ref.watch(tanksForActivePumpProvider);
    final alertsAsync = ref.watch(recentAlertsProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activePumpStatusProvider);
            ref.invalidate(tanksForActivePumpProvider);
            ref.invalidate(recentAlertsProvider);
            ref.invalidate(weatherProvider);
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: userAsync.when(
                      data: (user) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.t(_greetingKey())}, ${user.name.split(' ').first} 👋',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.farmName,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      loading: () => const LoadingShimmer(height: 40, width: 200),
                      error: (e, __) => Text('Welcome 👋', style: theme.textTheme.headlineSmall),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => showPumpSwitcherSheet(context),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: 'Switch pump',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              pumpAsync.when(
                data: (pump) => tanksAsync.when(
                  data: (tanks) => tanks.isEmpty
                      ? const SizedBox.shrink()
                      : TankLevelCard(tank: tanks.first),
                  loading: () => const CardShimmer(height: 110),
                  error: (e, __) => ErrorView(message: e.toString()),
                ),
                loading: () => const CardShimmer(height: 110),
                error: (e, __) => ErrorView(message: e.toString()),
              ),
              const SizedBox(height: 14),
              pumpAsync.when(
                data: (pump) => PumpStatusCard(pump: pump),
                loading: () => const CardShimmer(height: 190),
                error: (e, __) => ErrorView(message: e.toString()),
              ),
              const SizedBox(height: 14),
              IrrigationAdvisorBanner(onTap: () => context.push('/irrigation-advisor')),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Today at a Glance'),
              pumpAsync.when(
                data: (pump) => QuickStatsGrid(
                  pump: pump,
                  waterToday: 2140,
                  energyToday: 12.4,
                  solarToday: 8.1,
                ),
                loading: () => const CardShimmer(height: 210),
                error: (e, __) => ErrorView(message: e.toString()),
              ),
              const SizedBox(height: 20),
              SectionHeader(title: l10n.t('weather')),
              weatherAsync.when(
                data: (weather) => WeatherCard(weather: weather),
                loading: () => const CardShimmer(height: 130),
                error: (e, __) => ErrorView(message: e.toString()),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: l10n.t('quick_actions'),
              ),
              const QuickActionsRow(),
              const SizedBox(height: 20),
              SectionHeader(
                title: l10n.t('recent_alerts'),
                actionLabel: l10n.t('see_all'),
                onAction: () => context.go('/alerts'),
              ),
              alertsAsync.when(
                data: (alerts) => RecentAlertsSection(alerts: alerts),
                loading: () => const CardShimmer(height: 200),
                error: (e, __) => ErrorView(message: e.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
