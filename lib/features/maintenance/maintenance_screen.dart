import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/maintenance_model.dart';
import '../../providers/maintenance_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_view.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Reminders'),
            Tab(text: 'Service History'),
            Tab(text: 'Warranty'),
            Tab(text: 'Technicians'),
            Tab(text: 'Spare Parts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RemindersTab(),
          _ServiceHistoryTab(),
          _WarrantyTab(),
          _TechniciansTab(),
          _SparePartsTab(),
        ],
      ),
    );
  }
}

class _RemindersTab extends ConsumerWidget {
  const _RemindersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(maintenanceRemindersProvider);
    final theme = Theme.of(context);

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.event_available_rounded,
              title: 'Nothing due',
              message: 'No upcoming maintenance reminders.',
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final r = reminders[index];
            final urgent = r.daysUntilDue <= 7;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                radius: 16,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (urgent ? AppColors.warning : AppColors.info).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.build_rounded,
                          color: urgent ? AppColors.warning : AppColors.info),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text('Due in ${r.daysUntilDue} days · ${FormatUtils.dayMonthYear(r.dueDate)}',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardShimmer(height: 72),
        ),
      ),
      error: (e, __) => ErrorView(message: e.toString()),
    );
  }
}

class _ServiceHistoryTab extends ConsumerWidget {
  const _ServiceHistoryTab();

  IconData _iconFor(ServiceRecordType type) {
    switch (type) {
      case ServiceRecordType.routineService:
        return Icons.build_circle_rounded;
      case ServiceRecordType.motorReplacement:
        return Icons.settings_backup_restore_rounded;
      case ServiceRecordType.repair:
        return Icons.handyman_rounded;
      case ServiceRecordType.inspection:
        return Icons.search_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(serviceHistoryProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      data: (records) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconFor(r.type), color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.description, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text('${r.technicianName} · ${FormatUtils.dayMonthYear(r.date)}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('₹${r.cost.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardShimmer(height: 72),
        ),
      ),
      error: (e, __) => ErrorView(message: e.toString()),
    );
  }
}

class _WarrantyTab extends ConsumerWidget {
  const _WarrantyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warrantyAsync = ref.watch(warrantyDetailsProvider);
    final theme = Theme.of(context);

    return warrantyAsync.when(
      data: (items) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final w = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(w.componentName, style: theme.textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (w.isActive ? AppColors.success : AppColors.danger).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          w.isActive ? 'Active' : 'Expired',
                          style: TextStyle(
                            color: w.isActive ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${w.provider} · Purchased ${FormatUtils.dayMonthYear(w.purchaseDate)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    w.isActive
                        ? '${w.daysRemaining} days remaining · expires ${FormatUtils.dayMonthYear(w.expiryDate)}'
                        : 'Expired on ${FormatUtils.dayMonthYear(w.expiryDate)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardShimmer(height: 100),
        ),
      ),
      error: (e, __) => ErrorView(message: e.toString()),
    );
  }
}

class _TechniciansTab extends ConsumerWidget {
  const _TechniciansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techAsync = ref.watch(technicianContactsProvider);
    final theme = Theme.of(context);

    return techAsync.when(
      data: (techs) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: techs.length,
        itemBuilder: (context, index) {
          final t = techs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.14),
                    child: Text(t.name.isNotEmpty ? t.name[0] : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: theme.textTheme.titleSmall),
                        Text(t.specialization,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(t.rating.toStringAsFixed(1), style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.call_rounded),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardShimmer(height: 76),
        ),
      ),
      error: (e, __) => ErrorView(message: e.toString()),
    );
  }
}

class _SparePartsTab extends ConsumerWidget {
  const _SparePartsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(sparePartRecordsProvider);
    final theme = Theme.of(context);

    return partsAsync.when(
      data: (parts) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parts.length,
        itemBuilder: (context, index) {
          final p = parts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings_rounded, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.partName, style: theme.textTheme.titleSmall),
                        Text(
                          'Replaced ${FormatUtils.dayMonthYear(p.replacedOn)} · Life ${p.expectedLifespanMonths}mo',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text('₹${p.cost.toStringAsFixed(0)}', style: theme.textTheme.titleSmall),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardShimmer(height: 72),
        ),
      ),
      error: (e, __) => ErrorView(message: e.toString()),
    );
  }
}
