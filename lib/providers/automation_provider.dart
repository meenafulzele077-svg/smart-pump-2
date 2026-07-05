import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/schedule_model.dart';
import 'pump_provider.dart';
import 'service_providers.dart';

class AutomationSettingsNotifier extends Notifier<AutomationSettings> {
  @override
  AutomationSettings build() => const AutomationSettings();

  void setAutoFillEnabled(bool value) {
    state = state.copyWith(autoFillEnabled: value);
  }

  void setThresholds(double low, double high) {
    state = state.copyWith(lowThresholdPercent: low, highThresholdPercent: high);
  }

  void setRainMode(bool value) {
    state = state.copyWith(rainModeEnabled: value);
  }

  void setSeasonalMode(SeasonalMode mode) {
    state = state.copyWith(seasonalMode: mode);
  }
}

final automationSettingsProvider =
    NotifierProvider<AutomationSettingsNotifier, AutomationSettings>(
  AutomationSettingsNotifier.new,
);

final schedulesProvider = FutureProvider.autoDispose<List<ScheduleSlot>>((ref) async {
  final service = ref.watch(pumpServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  final slots = await service.getSchedules(pumpId);
  slots.sort((a, b) => a.weekday.compareTo(b.weekday));
  return slots;
});

class ScheduleController {
  ScheduleController(this.ref);
  final Ref ref;

  Future<void> addOrUpdate(ScheduleSlot slot) async {
    final service = ref.read(pumpServiceProvider);
    final pumpId = ref.read(activePumpIdProvider);
    await service.schedulePump(pumpId, slot);
    ref.invalidate(schedulesProvider);
  }

  Future<void> remove(String slotId) async {
    final service = ref.read(pumpServiceProvider);
    final pumpId = ref.read(activePumpIdProvider);
    await service.removeSchedule(pumpId, slotId);
    ref.invalidate(schedulesProvider);
  }
}

final scheduleControllerProvider = Provider((ref) => ScheduleController(ref));

/// Static (mock) AI suggestions — a real implementation would derive these
/// from anomaly-detection over historical analytics data server-side.
final aiSuggestionsProvider = Provider<List<AiSuggestion>>((ref) {
  return const [
    AiSuggestion(
      id: 'sg1',
      title: 'Efficiency dropped by 12%',
      description:
          'Farm Pump water output per kWh fell over the last 2 weeks — check for pipe leaks or a clogged filter.',
      icon: Icons.trending_down_rounded,
      isWarning: true,
    ),
    AiSuggestion(
      id: 'sg2',
      title: 'Motor maintenance recommended in 10 days',
      description:
          'Based on running hours and temperature trends, schedule a routine motor service soon to avoid downtime.',
      icon: Icons.build_circle_outlined,
      isWarning: true,
    ),
    AiSuggestion(
      id: 'sg3',
      title: 'Great solar utilisation this week',
      description:
          'You used solar power for 68% of total pump runtime — up 9% from last week. Keep irrigating mid-day when possible.',
      icon: Icons.wb_sunny_rounded,
      isWarning: false,
    ),
  ];
});
