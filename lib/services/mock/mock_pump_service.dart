import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../models/pump_model.dart';
import '../../models/tank_model.dart';
import '../../models/schedule_model.dart';
import '../pump_service.dart';

/// In-memory mock implementation of [PumpService] used until the real
/// hardware/controller API is plugged in. Simulates network latency and
/// gradually drifting sensor values so the UI feels alive during demos.
class MockPumpService implements PumpService {
  final _random = Random();

  final Map<String, PumpModel> _pumps = {
    'pump_farm': PumpModel(
      id: 'pump_farm',
      name: 'Farm Pump',
      location: 'Fulzele Farm, Plot 3',
      state: PumpState.running,
      powerSource: PumpPowerSource.hybrid,
      startedAt: DateTime.now().subtract(const Duration(minutes: 47)),
      motorTemperatureC: 58,
      voltage: 231,
      currentAmps: 6.2,
      isOnline: true,
      horsePower: 5,
      lastSyncedAt: DateTime.now(),
    ),
    'pump_home': PumpModel(
      id: 'pump_home',
      name: 'Home Pump',
      location: 'Residence Borewell',
      state: PumpState.stopped,
      powerSource: PumpPowerSource.grid,
      motorTemperatureC: 32,
      voltage: 228,
      currentAmps: 0,
      isOnline: true,
      horsePower: 1,
      lastSyncedAt: DateTime.now(),
    ),
    'pump_village': PumpModel(
      id: 'pump_village',
      name: 'Village Tank Pump',
      location: 'Gram Panchayat Overhead Tank',
      state: PumpState.stopped,
      powerSource: PumpPowerSource.solar,
      motorTemperatureC: 29,
      voltage: 0,
      currentAmps: 0,
      isOnline: false,
      horsePower: 7.5,
      lastSyncedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  };

  final Map<String, List<TankModel>> _tanks = {
    'pump_farm': [
      const TankModel(
        id: 'tank_farm_1',
        name: 'Main Storage Tank',
        capacityLitres: 10000,
        currentLitres: 6400,
      ),
    ],
    'pump_home': [
      const TankModel(
        id: 'tank_home_1',
        name: 'Rooftop Tank',
        capacityLitres: 2000,
        currentLitres: 1840,
      ),
    ],
    'pump_village': [
      const TankModel(
        id: 'tank_village_1',
        name: 'Overhead Tank',
        capacityLitres: 50000,
        currentLitres: 9200,
        lowLevelAlarm: true,
      ),
    ],
  };

  final Map<String, List<ScheduleSlot>> _schedules = {
    'pump_farm': [
      const ScheduleSlot(
        id: 's1',
        weekday: DateTime.monday,
        start: TimeOfDay(hour: 6, minute: 0),
        end: TimeOfDay(hour: 8, minute: 0),
      ),
      const ScheduleSlot(
        id: 's2',
        weekday: DateTime.wednesday,
        start: TimeOfDay(hour: 17, minute: 0),
        end: TimeOfDay(hour: 19, minute: 0),
      ),
      const ScheduleSlot(
        id: 's3',
        weekday: DateTime.friday,
        start: TimeOfDay(hour: 6, minute: 30),
        end: TimeOfDay(hour: 8, minute: 30),
        enabled: false,
      ),
    ],
  };

  Future<void> _delay() => Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

  @override
  Future<List<PumpModel>> getAllPumps() async {
    await _delay();
    return _pumps.values.toList();
  }

  @override
  Future<PumpModel> getPumpStatus(String pumpId) async {
    await _delay();
    final pump = _pumps[pumpId];
    if (pump == null) throw Exception('Pump not found: $pumpId');
    return pump;
  }

  @override
  Future<PumpModel> turnPumpOn(String pumpId) async {
    await _delay();
    final pump = _pumps[pumpId]!;
    final updated = pump.copyWith(
      state: PumpState.running,
      startedAt: DateTime.now(),
      currentAmps: 5 + _random.nextDouble() * 2,
      lastSyncedAt: DateTime.now(),
    );
    _pumps[pumpId] = updated;
    return updated;
  }

  @override
  Future<PumpModel> turnPumpOff(String pumpId) async {
    await _delay();
    final pump = _pumps[pumpId]!;
    final updated = pump.copyWith(
      state: PumpState.stopped,
      clearStartedAt: true,
      currentAmps: 0,
      lastSyncedAt: DateTime.now(),
    );
    _pumps[pumpId] = updated;
    return updated;
  }

  @override
  Future<PumpModel> emergencyStop(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final pump = _pumps[pumpId]!;
    final updated = pump.copyWith(
      state: PumpState.stopped,
      clearStartedAt: true,
      currentAmps: 0,
      lastSyncedAt: DateTime.now(),
    );
    _pumps[pumpId] = updated;
    return updated;
  }

  @override
  Future<List<TankModel>> getTanksForPump(String pumpId) async {
    await _delay();
    return _tanks[pumpId] ?? [];
  }

  @override
  Future<void> schedulePump(String pumpId, ScheduleSlot slot) async {
    await _delay();
    _schedules.putIfAbsent(pumpId, () => []);
    _schedules[pumpId]!.removeWhere((s) => s.id == slot.id);
    _schedules[pumpId]!.add(slot);
  }

  @override
  Future<void> removeSchedule(String pumpId, String slotId) async {
    await _delay();
    _schedules[pumpId]?.removeWhere((s) => s.id == slotId);
  }

  @override
  Future<List<ScheduleSlot>> getSchedules(String pumpId) async {
    await _delay();
    return _schedules[pumpId] ?? [];
  }

  @override
  Stream<PumpModel> watchPumpStatus(String pumpId) {
    return Stream.periodic(const Duration(seconds: 5), (tick) {
      final pump = _pumps[pumpId];
      if (pump == null) return null;
      if (pump.state == PumpState.running) {
        final drifted = pump.copyWith(
          motorTemperatureC: (pump.motorTemperatureC + (_random.nextDouble() - 0.4))
              .clamp(28, 85)
              .toDouble(),
          voltage: (pump.voltage + (_random.nextDouble() - 0.5) * 2).clamp(190, 245).toDouble(),
          currentAmps:
              (pump.currentAmps + (_random.nextDouble() - 0.5) * 0.3).clamp(0, 12).toDouble(),
          lastSyncedAt: DateTime.now(),
        );
        _pumps[pumpId] = drifted;
        return drifted;
      }
      return pump;
    }).where((p) => p != null).cast<PumpModel>();
  }
}
