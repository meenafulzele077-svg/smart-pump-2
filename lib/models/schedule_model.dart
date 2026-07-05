import 'package:flutter/material.dart';

enum SeasonalMode { summer, monsoon, winter }

class ScheduleSlot {
  final String id;
  final int weekday; // 1 = Monday .. 7 = Sunday (DateTime convention)
  final TimeOfDay start;
  final TimeOfDay end;
  final bool enabled;

  const ScheduleSlot({
    required this.id,
    required this.weekday,
    required this.start,
    required this.end,
    this.enabled = true,
  });

  ScheduleSlot copyWith({bool? enabled}) => ScheduleSlot(
        id: id,
        weekday: weekday,
        start: start,
        end: end,
        enabled: enabled ?? this.enabled,
      );

  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get weekdayLabel => weekdayNames[weekday - 1];
}

class AutomationSettings {
  final bool autoFillEnabled;
  final double lowThresholdPercent;
  final double highThresholdPercent;
  final bool rainModeEnabled;
  final SeasonalMode seasonalMode;

  const AutomationSettings({
    this.autoFillEnabled = true,
    this.lowThresholdPercent = 20,
    this.highThresholdPercent = 95,
    this.rainModeEnabled = false,
    this.seasonalMode = SeasonalMode.summer,
  });

  AutomationSettings copyWith({
    bool? autoFillEnabled,
    double? lowThresholdPercent,
    double? highThresholdPercent,
    bool? rainModeEnabled,
    SeasonalMode? seasonalMode,
  }) {
    return AutomationSettings(
      autoFillEnabled: autoFillEnabled ?? this.autoFillEnabled,
      lowThresholdPercent: lowThresholdPercent ?? this.lowThresholdPercent,
      highThresholdPercent: highThresholdPercent ?? this.highThresholdPercent,
      rainModeEnabled: rainModeEnabled ?? this.rainModeEnabled,
      seasonalMode: seasonalMode ?? this.seasonalMode,
    );
  }
}

class AiSuggestion {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isWarning;

  const AiSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isWarning = false,
  });
}
