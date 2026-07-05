import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../models/pump_model.dart';
import '../providers/pump_provider.dart';

Future<void> showPumpSwitcherSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _PumpSwitcherSheet(),
  );
}

class _PumpSwitcherSheet extends ConsumerWidget {
  const _PumpSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pumpsAsync = ref.watch(allPumpsProvider);
    final activeId = ref.watch(activePumpIdProvider);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Switch Pump', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Select which pump you want to control & monitor',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            pumpsAsync.when(
              data: (pumps) => Column(
                children: pumps
                    .map((p) => _PumpTile(
                          pump: p,
                          selected: p.id == activeId,
                          onTap: () {
                            ref.read(activePumpIdProvider.notifier).select(p.id);
                            Navigator.of(context).pop();
                          },
                        ))
                    .toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Could not load pumps: $e'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PumpTile extends StatelessWidget {
  final PumpModel pump;
  final bool selected;
  final VoidCallback onTap;

  const _PumpTile({required this.pump, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = pump.state == PumpState.running;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: (isRunning ? AppColors.success : theme.colorScheme.outline)
                        .withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.water_pump_rounded,
                    color: isRunning ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pump.name, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        pump.location,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!pump.isOnline)
                  const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.grey)
                else if (selected)
                  Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
