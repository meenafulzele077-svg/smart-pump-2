import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/irrigation_advisor_provider.dart';
import '../../../widgets/app_card.dart';

/// Compact entry point shown near the pump controls (Home quick actions &
/// top of Automation) that surfaces the AI watering recommendation, or a
/// call-to-action to set up the farmer's location/soil/crop profile.
class IrrigationAdvisorBanner extends ConsumerWidget {
  final VoidCallback onTap;

  const IrrigationAdvisorBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(savedFarmProfileProvider);
    final recommendationAsync = ref.watch(irrigationRecommendationProvider);

    return AppCard(
      onTap: onTap,
      gradient: AppColors.tealGreenGradient,
      child: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Irrigation Advisor',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text('Set your location & soil to get today\'s watering advice',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            );
          }

          return recommendationAsync.when(
            data: (rec) {
              if (rec == null) return const SizedBox.shrink();
              return Row(
                children: [
                  Icon(
                    rec.shouldSkipToday ? Icons.umbrella_rounded : Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.shouldSkipToday
                              ? 'Skip irrigation today'
                              : '${(rec.totalLitres / 1000).toStringAsFixed(1)}k L recommended today',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${rec.currentTemperatureC.toStringAsFixed(0)}°C · Rain chance ${rec.forecastRainChancePercent.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 28,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
            error: (e, __) => Text('Could not load recommendation',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
          );
        },
        loading: () => const SizedBox(
          height: 28,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
        ),
        error: (e, __) =>
            Text('Could not load advisor', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
      ),
    );
  }
}
