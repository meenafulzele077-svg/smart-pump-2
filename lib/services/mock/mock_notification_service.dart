import 'dart:async';
import '../../models/alert_model.dart';
import '../notification_service.dart';

class MockNotificationService implements NotificationService {
  final List<AlertModel> _alerts = [
    AlertModel(
      id: 'a1',
      type: AlertType.pumpStarted,
      severity: AlertSeverity.success,
      title: 'Pump Started',
      message: 'Farm Pump was started automatically by the weekly schedule.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 47)),
      pumpId: 'pump_farm',
    ),
    AlertModel(
      id: 'a2',
      type: AlertType.tankLow,
      severity: AlertSeverity.warning,
      title: 'Tank Level Low',
      message: 'Village Tank Pump storage dropped below 20%. Auto-fill triggered.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      pumpId: 'pump_village',
      isRead: true,
    ),
    AlertModel(
      id: 'a3',
      type: AlertType.highTemperature,
      severity: AlertSeverity.danger,
      title: 'High Motor Temperature',
      message: 'Farm Pump motor reached 82°C. Consider inspecting cooling & load.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      pumpId: 'pump_farm',
    ),
    AlertModel(
      id: 'a4',
      type: AlertType.dryRun,
      severity: AlertSeverity.danger,
      title: 'Dry Run Detected',
      message: 'Home Pump was stopped automatically to prevent dry-run damage.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      pumpId: 'pump_home',
      isRead: true,
    ),
    AlertModel(
      id: 'a5',
      type: AlertType.lowVoltage,
      severity: AlertSeverity.warning,
      title: 'Low Voltage',
      message: 'Grid voltage dropped to 178V. Pump paused for protection.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      pumpId: 'pump_home',
      isRead: true,
    ),
    AlertModel(
      id: 'a6',
      type: AlertType.unauthorizedAccess,
      severity: AlertSeverity.danger,
      title: 'Unauthorized Access Attempt',
      message: 'A login attempt from an unrecognized device was blocked.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      pumpId: 'pump_farm',
      isRead: true,
    ),
    AlertModel(
      id: 'a7',
      type: AlertType.pumpStopped,
      severity: AlertSeverity.info,
      title: 'Pump Stopped',
      message: 'Farm Pump was stopped manually from the app.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      pumpId: 'pump_farm',
      isRead: true,
    ),
    AlertModel(
      id: 'a8',
      type: AlertType.maintenanceDue,
      severity: AlertSeverity.warning,
      title: 'Maintenance Due Soon',
      message: 'Routine service for Farm Pump is recommended within 10 days.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      pumpId: 'pump_farm',
      isRead: true,
    ),
  ];

  final Map<String, Map<NotificationChannel, bool>> _prefs = {
    'pump_farm': {
      NotificationChannel.push: true,
      NotificationChannel.sms: true,
      NotificationChannel.whatsapp: false,
    },
  };

  final _incomingController = StreamController<AlertModel>.broadcast();

  @override
  Future<List<AlertModel>> getAlerts(String pumpId, {int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _alerts.where((a) => a.pumpId == pumpId).take(limit).toList();
  }

  @override
  Future<void> markAsRead(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead(String pumpId) async {
    for (int i = 0; i < _alerts.length; i++) {
      if (_alerts[i].pumpId == pumpId) {
        _alerts[i] = _alerts[i].copyWith(isRead: true);
      }
    }
  }

  @override
  Future<void> registerDeviceToken(String token) async {
    // TODO: send [token] to backend to enable targeted push via FCM.
  }

  @override
  Future<void> setChannelEnabled(
      String pumpId, NotificationChannel channel, bool enabled) async {
    _prefs.putIfAbsent(pumpId, () => {});
    _prefs[pumpId]![channel] = enabled;
  }

  @override
  Future<Map<NotificationChannel, bool>> getChannelPreferences(String pumpId) async {
    return _prefs[pumpId] ??
        {
          NotificationChannel.push: true,
          NotificationChannel.sms: false,
          NotificationChannel.whatsapp: false,
        };
  }

  @override
  Stream<AlertModel> watchIncomingAlerts(String pumpId) {
    return _incomingController.stream.where((a) => a.pumpId == pumpId);
  }
}
