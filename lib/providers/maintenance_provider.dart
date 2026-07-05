import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/maintenance_model.dart';
import '../models/device_model.dart';
import 'pump_provider.dart';
import 'service_providers.dart';

final serviceHistoryProvider = FutureProvider.autoDispose<List<ServiceRecord>>((ref) async {
  final service = ref.watch(userServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getServiceHistory(pumpId);
});

final warrantyDetailsProvider = FutureProvider.autoDispose<List<WarrantyInfo>>((ref) async {
  final service = ref.watch(userServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getWarrantyDetails(pumpId);
});

final technicianContactsProvider = FutureProvider.autoDispose<List<TechnicianContact>>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getTechnicianContacts();
});

final maintenanceRemindersProvider =
    FutureProvider.autoDispose<List<MaintenanceReminder>>((ref) async {
  final service = ref.watch(userServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getMaintenanceReminders(pumpId);
});

final sparePartRecordsProvider = FutureProvider.autoDispose<List<SparePartRecord>>((ref) async {
  final service = ref.watch(userServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getSparePartRecords(pumpId);
});

final deviceInfoProvider = FutureProvider.autoDispose<DeviceInfoModel>((ref) async {
  final service = ref.watch(userServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getDeviceInfo(pumpId);
});
