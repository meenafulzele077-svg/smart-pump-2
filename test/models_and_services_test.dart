import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pump_2/models/tank_model.dart';
import 'package:smart_pump_2/models/pump_model.dart';
import 'package:smart_pump_2/services/mock/mock_pump_service.dart';

void main() {
  group('TankModel', () {
    test('percentFull computes correctly', () {
      const tank = TankModel(
        id: 't1',
        name: 'Test Tank',
        capacityLitres: 1000,
        currentLitres: 250,
      );
      expect(tank.percentFull, 25);
      expect(tank.isCritical, isFalse);
    });

    test('isCritical is true below 15%', () {
      const tank = TankModel(
        id: 't1',
        name: 'Test Tank',
        capacityLitres: 1000,
        currentLitres: 100,
      );
      expect(tank.isCritical, isTrue);
    });

    test('isNearFull is true above 90%', () {
      const tank = TankModel(
        id: 't1',
        name: 'Test Tank',
        capacityLitres: 1000,
        currentLitres: 950,
      );
      expect(tank.isNearFull, isTrue);
    });
  });

  group('PumpModel', () {
    test('currentRuntime is zero when stopped', () {
      const pump = PumpModel(
        id: 'p1',
        name: 'Test Pump',
        location: 'Test Farm',
        state: PumpState.stopped,
        powerSource: PumpPowerSource.grid,
        motorTemperatureC: 30,
        voltage: 230,
        currentAmps: 0,
        isOnline: true,
        horsePower: 5,
      );
      expect(pump.currentRuntime, Duration.zero);
    });

    test('copyWith updates only provided fields', () {
      const pump = PumpModel(
        id: 'p1',
        name: 'Test Pump',
        location: 'Test Farm',
        state: PumpState.stopped,
        powerSource: PumpPowerSource.grid,
        motorTemperatureC: 30,
        voltage: 230,
        currentAmps: 0,
        isOnline: true,
        horsePower: 5,
      );
      final updated = pump.copyWith(state: PumpState.running);
      expect(updated.state, PumpState.running);
      expect(updated.name, pump.name);
    });
  });

  group('MockPumpService', () {
    late MockPumpService service;

    setUp(() => service = MockPumpService());

    test('getAllPumps returns non-empty list', () async {
      final pumps = await service.getAllPumps();
      expect(pumps, isNotEmpty);
    });

    test('turnPumpOn sets state to running', () async {
      final pump = await service.turnPumpOn('pump_home');
      expect(pump.state, PumpState.running);
      expect(pump.startedAt, isNotNull);
    });

    test('turnPumpOff sets state to stopped', () async {
      await service.turnPumpOn('pump_home');
      final pump = await service.turnPumpOff('pump_home');
      expect(pump.state, PumpState.stopped);
      expect(pump.currentAmps, 0);
    });

    test('emergencyStop immediately stops the pump', () async {
      await service.turnPumpOn('pump_farm');
      final pump = await service.emergencyStop('pump_farm');
      expect(pump.state, PumpState.stopped);
    });
  });
}
