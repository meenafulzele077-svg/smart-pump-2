import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../models/pump_model.dart';
import '../models/tank_model.dart';
import 'service_providers.dart';

/// Holds the id of the pump currently selected in the multi-pump switcher.
class ActivePumpIdNotifier extends Notifier<String> {
  @override
  String build() {
    final box = Hive.box(AppConstants.settingsBox);
    return box.get(AppConstants.keyActivePumpId, defaultValue: 'pump_farm') as String;
  }

  void select(String pumpId) {
    state = pumpId;
    Hive.box(AppConstants.settingsBox).put(AppConstants.keyActivePumpId, pumpId);
  }
}

final activePumpIdProvider = NotifierProvider<ActivePumpIdNotifier, String>(
  ActivePumpIdNotifier.new,
);

/// All pumps registered to this account (for the pump switcher).
final allPumpsProvider = FutureProvider<List<PumpModel>>((ref) async {
  final service = ref.watch(pumpServiceProvider);
  return service.getAllPumps();
});

/// Live status for the currently active pump — rebuilt whenever the user
/// switches pumps. Combines an initial fetch with the mock live stream.
final activePumpStatusProvider = StreamProvider.autoDispose<PumpModel>((ref) async* {
  final service = ref.watch(pumpServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  final initial = await service.getPumpStatus(pumpId);
  yield initial;
  yield* service.watchPumpStatus(pumpId);
});

final tanksForActivePumpProvider = FutureProvider.autoDispose<List<TankModel>>((ref) async {
  final service = ref.watch(pumpServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  return service.getTanksForPump(pumpId);
});

/// Exposes imperative pump control actions (start/stop/emergency-stop) as a
/// small controller so widgets don't need direct access to the service.
class PumpControlController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> start() async {
    final service = ref.read(pumpServiceProvider);
    final pumpId = ref.read(activePumpIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => service.turnPumpOn(pumpId));
    ref.invalidate(activePumpStatusProvider);
  }

  Future<void> stop() async {
    final service = ref.read(pumpServiceProvider);
    final pumpId = ref.read(activePumpIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => service.turnPumpOff(pumpId));
    ref.invalidate(activePumpStatusProvider);
  }

  Future<void> emergencyStop() async {
    final service = ref.read(pumpServiceProvider);
    final pumpId = ref.read(activePumpIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => service.emergencyStop(pumpId));
    ref.invalidate(activePumpStatusProvider);
  }
}

final pumpControlControllerProvider =
    AsyncNotifierProvider<PumpControlController, void>(PumpControlController.new);
