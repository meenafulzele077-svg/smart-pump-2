import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert_model.dart';
import 'pump_provider.dart';
import 'service_providers.dart';

final alertsProvider = FutureProvider.autoDispose<List<AlertModel>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getAlerts(pumpId);
});

/// First 3 alerts, used by the Home dashboard "Recent Alerts" widget.
final recentAlertsProvider = FutureProvider.autoDispose<List<AlertModel>>((ref) async {
  final all = await ref.watch(alertsProvider.future);
  return all.take(3).toList();
});

final unreadAlertsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final all = await ref.watch(alertsProvider.future);
  return all.where((a) => !a.isRead).length;
});
