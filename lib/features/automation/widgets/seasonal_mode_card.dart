import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/schedule_model.dart';
import '../../../providers/automation_provider.dart';
import '../../../widgets/app_card.dart';

class SeasonalModeCard extends ConsumerWidget {
  const SeasonalModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(automationSettingsProvider);
    final notifier = ref.read(automationSettingsProvider.notifier);

    final modes = [
      (SeasonalMode.summer, 'Summer', Icons.wb_sunny_rounded, AppColors.warning),
      (SeasonalMode.monsoon, 'Monsoon', Icons.beach_access_rounded, AppColors.info),
      (SeasonalMode.winter, 'Winter', Icons.ac_unit_rounded, AppColors.primary),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Seasonal Mode', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Adjusts irrigation duration & frequency automatically for the season',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Row(
            children: modes.map((m) {
              final selected = settings.seasonalMode == m.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => notifier.setSeasonalMode(m.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? m.$4.withOpacity(0.14) : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: selected ? Border.all(color: m.$4, width: 1.4) : null,
                      ),
                      child: Column(
                        children: [
                          Icon(m.$3, color: selected ? m.$4 : theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 6),
                          Text(m.$2,
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: selected ? m.$4 : theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_queue_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rain Mode', style: theme.textTheme.titleSmall),
                    Text('Disable irrigation during heavy rainfall',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(value: settings.rainModeEnabled, onChanged: notifier.setRainMode),
            ],
          ),
        ],
      ),
    );
  }
}
