import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/pump_model.dart';
import '../../../widgets/app_card.dart';

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.icon, this.label, this.value, this.color);
}

class QuickStatsGrid extends StatelessWidget {
  final PumpModel pump;
  final double waterToday;
  final double energyToday;
  final double solarToday;

  const QuickStatsGrid({
    super.key,
    required this.pump,
    required this.waterToday,
    required this.energyToday,
    required this.solarToday,
  });

  @override
  Widget build(BuildContext context) {
    final runtime = pump.currentRuntime;
    final items = [
      _StatItem(Icons.water_drop_rounded, 'Water Pumped', '${waterToday.toStringAsFixed(0)} L',
          AppColors.info),
      _StatItem(Icons.bolt_rounded, 'Energy Used', '${energyToday.toStringAsFixed(1)} kWh',
          AppColors.warning),
      _StatItem(Icons.timer_rounded, 'Runtime',
          '${runtime.inHours}h ${runtime.inMinutes.remainder(60)}m', AppColors.primary),
      _StatItem(Icons.wb_sunny_rounded, 'Solar Output', '${solarToday.toStringAsFixed(1)} kWh',
          AppColors.secondary),
      _StatItem(Icons.thermostat_rounded, 'Motor Temp', '${pump.motorTemperatureC.toStringAsFixed(0)}°C',
          pump.motorTemperatureC > 75 ? AppColors.danger : AppColors.success),
      _StatItem(Icons.electric_bolt_rounded, 'Voltage', '${pump.voltage.toStringAsFixed(0)} V',
          (pump.voltage < 200 || pump.voltage > 240) ? AppColors.danger : AppColors.info),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return AppCard(
          padding: const EdgeInsets.all(14),
          radius: 16,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.value,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
