import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/tank_model.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_pill.dart';

class TankLevelCard extends StatelessWidget {
  final TankModel tank;

  const TankLevelCard({super.key, required this.tank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = tank.percentFull;
    final color = tank.isCritical
        ? AppColors.danger
        : tank.isNearFull
            ? AppColors.warning
            : AppColors.info;

    return AppCard(
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularPercentIndicator(
                radius: 42,
                lineWidth: 10,
                percent: value.clamp(0, 1),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                progressColor: color,
                center: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(tank.name, style: theme.textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${FormatUtils.litres(tank.currentLitres)} of ${FormatUtils.litres(tank.capacityLitres)}',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (tank.isNearFull)
                  const StatusPill(
                    label: 'Overflow risk',
                    color: AppColors.warning,
                    icon: Icons.warning_amber_rounded,
                  )
                else if (tank.isCritical)
                  const StatusPill(
                    label: 'Critically low',
                    color: AppColors.danger,
                    icon: Icons.error_outline_rounded,
                  )
                else
                  const StatusPill(
                    label: 'Healthy level',
                    color: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
