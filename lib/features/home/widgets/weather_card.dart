import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/weather_model.dart';
import '../../../widgets/app_card.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  IconData get _icon {
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCondition.rainy:
        return Icons.umbrella_rounded;
      case WeatherCondition.stormy:
        return Icons.thunderstorm_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      gradient: AppColors.waterGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${weather.temperatureC.toStringAsFixed(0)}°C',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('Humidity ${weather.humidityPercent.toStringAsFixed(0)}% · Rain ${weather.rainChancePercent.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9))),
                ],
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.irrigationRecommendation,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
