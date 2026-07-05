import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/alert_model.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/pump_provider.dart';
import '../../providers/service_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_view.dart';

enum _AlertFilter { all, unread, warnings, danger }

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  _AlertFilter _filter = _AlertFilter.all;

  List<AlertModel> _applyFilter(List<AlertModel> alerts) {
    switch (_filter) {
      case _AlertFilter.all:
        return alerts;
      case _AlertFilter.unread:
        return alerts.where((a) => !a.isRead).toList();
      case _AlertFilter.warnings:
        return alerts.where((a) => a.severity == AlertSeverity.warning).toList();
      case _AlertFilter.danger:
        return alerts.where((a) => a.severity == AlertSeverity.danger).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () async {
              final service = ref.read(notificationServiceProvider);
              final pumpId = ref.read(activePumpIdProvider);
              await service.markAllAsRead(pumpId);
              ref.invalidate(alertsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == _AlertFilter.all,
                    onTap: () => setState(() => _filter = _AlertFilter.all),
                  ),
                  _FilterChip(
                    label: 'Unread',
                    selected: _filter == _AlertFilter.unread,
                    onTap: () => setState(() => _filter = _AlertFilter.unread),
                  ),
                  _FilterChip(
                    label: 'Warnings',
                    selected: _filter == _AlertFilter.warnings,
                    onTap: () => setState(() => _filter = _AlertFilter.warnings),
                  ),
                  _FilterChip(
                    label: 'Critical',
                    selected: _filter == _AlertFilter.danger,
                    onTap: () => setState(() => _filter = _AlertFilter.danger),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(alertsProvider),
              child: alertsAsync.when(
                data: (alerts) {
                  final filtered = _applyFilter(alerts);
                  if (filtered.isEmpty) {
                    return ListView(
                      children: const [
                        EmptyState(
                          icon: Icons.notifications_off_outlined,
                          title: 'No alerts here',
                          message: 'You\'re all caught up — nothing to show for this filter.',
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _AlertTimelineTile(
                      alert: filtered[index],
                      isLast: index == filtered.length - 1,
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: CardShimmer(height: 76),
                  ),
                ),
                error: (e, __) =>
                    ErrorView(message: e.toString(), onRetry: () => ref.invalidate(alertsProvider)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _AlertTimelineTile extends StatelessWidget {
  final AlertModel alert;
  final bool isLast;

  const _AlertTimelineTile({required this.alert, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: alert.color()),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: alert.isRead
                      ? theme.colorScheme.surface
                      : alert.color().withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(alert.icon(), size: 18, color: alert.color()),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(alert.title,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.danger, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(alert.message, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      FormatUtils.fullDateTime(alert.timestamp),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
