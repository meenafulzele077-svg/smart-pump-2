import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/analytics_model.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/pump_provider.dart';
import '../../providers/service_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_view.dart';
import 'widgets/analytics_chart.dart';
import 'widgets/efficiency_score_bar.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _metrics = [
    AnalyticsMetric.water,
    AnalyticsMetric.energy,
    AnalyticsMetric.runtime,
    AnalyticsMetric.motor,
    AnalyticsMetric.solar,
  ];

  static const _metricLabels = {
    AnalyticsMetric.water: 'Water',
    AnalyticsMetric.energy: 'Energy',
    AnalyticsMetric.runtime: 'Runtime',
    AnalyticsMetric.motor: 'Motor',
    AnalyticsMetric.solar: 'Solar',
  };

  static const _metricIcons = {
    AnalyticsMetric.water: Icons.water_drop_rounded,
    AnalyticsMetric.energy: Icons.bolt_rounded,
    AnalyticsMetric.runtime: Icons.timer_rounded,
    AnalyticsMetric.motor: Icons.settings_rounded,
    AnalyticsMetric.solar: Icons.wb_sunny_rounded,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _metrics.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedMetricProvider.notifier).state = _metrics[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _export(bool asPdf) async {
    final summaryAsync = ref.read(analyticsSummaryProvider);
    final summary = summaryAsync.valueOrNull;
    if (summary == null) return;
    final service = ref.read(analyticsServiceProvider);
    final path = asPdf ? await service.exportToPdf(summary) : await service.exportToExcel(summary);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = ref.watch(selectedPeriodProvider);
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share_rounded),
            onSelected: (v) => _export(v == 'pdf'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
              PopupMenuItem(value: 'excel', child: Text('Export as Excel')),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            for (final m in _metrics)
              Tab(
                icon: Icon(_metricIcons[m], size: 18),
                text: _metricLabels[m],
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<AnalyticsPeriod>(
              segments: const [
                ButtonSegment(value: AnalyticsPeriod.daily, label: Text('Daily')),
                ButtonSegment(value: AnalyticsPeriod.weekly, label: Text('Weekly')),
                ButtonSegment(value: AnalyticsPeriod.monthly, label: Text('Monthly')),
                ButtonSegment(value: AnalyticsPeriod.yearly, label: Text('Yearly')),
              ],
              selected: {period},
              onSelectionChanged: (s) => ref.read(selectedPeriodProvider.notifier).state = s.first,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(analyticsSummaryProvider),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  summaryAsync.when(
                    data: (summary) => _SummaryContent(summary: summary),
                    loading: () => const Column(
                      children: [
                        CardShimmer(height: 90),
                        SizedBox(height: 14),
                        CardShimmer(height: 260),
                      ],
                    ),
                    error: (e, __) => ErrorView(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(analyticsSummaryProvider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CompareMonthsCard(pumpIdWatcher: ref.watch(activePumpIdProvider)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  final AnalyticsSummary summary;
  const _SummaryContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositiveGood = summary.metric != AnalyticsMetric.motor;
    final isUp = summary.changePercent >= 0;
    final goodChange = isPositiveGood ? isUp : !isUp;

    return Column(
      children: [
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total this period', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.total.toStringAsFixed(summary.unit == '°C' ? 1 : 0)} ${summary.unit}',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (goodChange ? AppColors.success : AppColors.danger).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 16,
                      color: goodChange ? AppColors.success : AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.changePercent.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: goodChange ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trend', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              AnalyticsChart(summary: summary),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(child: EfficiencyScoreBar(score: summary.efficiencyScore)),
      ],
    );
  }
}

class _CompareMonthsCard extends StatelessWidget {
  final String pumpIdWatcher;
  const _CompareMonthsCard({required this.pumpIdWatcher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Compare Months', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _monthChip(context, 'This Month', '2,140 L/day', true)),
              const SizedBox(width: 10),
              Expanded(child: _monthChip(context, 'Last Month', '2,410 L/day', false)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Average daily water output is down 11% vs last month — check filters and drip lines.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _monthChip(BuildContext context, String label, String value, bool highlight) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
