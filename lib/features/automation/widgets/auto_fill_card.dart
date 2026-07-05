import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/automation_provider.dart';
import '../../../widgets/app_card.dart';

class AutoFillCard extends ConsumerWidget {
  const AutoFillCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(automationSettingsProvider);
    final notifier = ref.read(automationSettingsProvider.notifier);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tank Auto Fill', style: theme.textTheme.titleMedium),
                    Text('Automatically start/stop based on tank level',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: settings.autoFillEnabled,
                onChanged: notifier.setAutoFillEnabled,
              ),
            ],
          ),
          if (settings.autoFillEnabled) ...[
            const SizedBox(height: 16),
            _ThresholdRow(
              icon: Icons.arrow_downward_rounded,
              color: AppColors.warning,
              label: 'START pump when tank <',
              value: settings.lowThresholdPercent,
              onChanged: (v) => notifier.setThresholds(v, settings.highThresholdPercent),
            ),
            const SizedBox(height: 10),
            _ThresholdRow(
              icon: Icons.arrow_upward_rounded,
              color: AppColors.success,
              label: 'STOP pump when tank >',
              value: settings.highThresholdPercent,
              onChanged: (v) => notifier.setThresholds(settings.lowThresholdPercent, v),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _ThresholdRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        Text('${value.toStringAsFixed(0)}%',
            style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
        SizedBox(
          width: 120,
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
