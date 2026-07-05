import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AlertSeverity { info, warning, danger, success }

enum AlertType {
  pumpStarted,
  pumpStopped,
  dryRun,
  lowVoltage,
  highTemperature,
  unauthorizedAccess,
  tankLow,
  tankFull,
  scheduleExecuted,
  maintenanceDue,
  connectivityLost,
}

class AlertModel {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;
  final String pumpId;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.pumpId,
    this.isRead = false,
  });

  Color color() {
    switch (severity) {
      case AlertSeverity.info:
        return AppColors.info;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.danger:
        return AppColors.danger;
      case AlertSeverity.success:
        return AppColors.success;
    }
  }

  IconData icon() {
    switch (type) {
      case AlertType.pumpStarted:
        return Icons.play_circle_rounded;
      case AlertType.pumpStopped:
        return Icons.stop_circle_rounded;
      case AlertType.dryRun:
        return Icons.warning_amber_rounded;
      case AlertType.lowVoltage:
        return Icons.bolt_rounded;
      case AlertType.highTemperature:
        return Icons.thermostat_rounded;
      case AlertType.unauthorizedAccess:
        return Icons.gpp_bad_rounded;
      case AlertType.tankLow:
        return Icons.water_drop_outlined;
      case AlertType.tankFull:
        return Icons.water_drop_rounded;
      case AlertType.scheduleExecuted:
        return Icons.schedule_rounded;
      case AlertType.maintenanceDue:
        return Icons.build_rounded;
      case AlertType.connectivityLost:
        return Icons.wifi_off_rounded;
    }
  }

  AlertModel copyWith({bool? isRead}) => AlertModel(
        id: id,
        type: type,
        severity: severity,
        title: title,
        message: message,
        timestamp: timestamp,
        pumpId: pumpId,
        isRead: isRead ?? this.isRead,
      );
}
