import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/schedule_model.dart';
import '../../../providers/automation_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/empty_state.dart';

class SchedulerCard extends ConsumerWidget {
  const SchedulerCard({super.key});

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {ScheduleSlot? existing}) async {
    int weekday = existing?.weekday ?? DateTime.monday;
    TimeOfDay start = existing?.start ?? const TimeOfDay(hour: 6, minute: 0);
    TimeOfDay end = existing?.end ?? const TimeOfDay(hour: 8, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Text(existing == null ? 'Add Schedule' : 'Edit Schedule',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Day of week', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      return ChoiceChip(
                        label: Text(ScheduleSlot.weekdayNames[i].substring(0, 3)),
                        selected: weekday == day,
                        onSelected: (_) => setSheetState(() => weekday = day),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _TimePickerTile(
                          label: 'Start time',
                          time: start,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: start);
                            if (picked != null) setSheetState(() => start = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimePickerTile(
                          label: 'End time',
                          time: end,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: end);
                            if (picked != null) setSheetState(() => end = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      final slot = ScheduleSlot(
                        id: existing?.id ?? 's_${DateTime.now().millisecondsSinceEpoch}',
                        weekday: weekday,
                        start: start,
                        end: end,
                      );
                      ref.read(scheduleControllerProvider).addOrUpdate(slot);
                      Navigator.pop(context);
                    },
                    child: const Text('Save Schedule'),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final schedulesAsync = ref.watch(schedulesProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Weekly Scheduler', style: theme.textTheme.titleMedium)),
              IconButton(
                onPressed: () => _openEditor(context, ref),
                icon: const Icon(Icons.add_circle_rounded),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          schedulesAsync.when(
            data: (slots) {
              if (slots.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'No schedules yet',
                  message: 'Tap + to add your first weekly irrigation slot.',
                );
              }
              return Column(
                children: slots
                    .map((slot) => _ScheduleTile(
                          slot: slot,
                          onTap: () => _openEditor(context, ref, existing: slot),
                          onDelete: () => ref.read(scheduleControllerProvider).remove(slot.id),
                        ))
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, __) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerTile({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(time.format(context), style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final ScheduleSlot slot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ScheduleTile({required this.slot, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    slot.weekdayLabel.substring(0, 3).toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${slot.start.format(context)} – ${slot.end.format(context)}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Switch(value: slot.enabled, onChanged: (_) {}),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
