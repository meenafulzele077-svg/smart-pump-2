import '../models/pump_model.dart';
import '../models/tank_model.dart';
import '../models/schedule_model.dart';

/// Abstract contract for controlling & reading pump/tank hardware state.
///
/// A real implementation (e.g. `ApiPumpService`) should call the existing
/// controller vendor's REST/MQTT backend. Swap the provider binding in
/// `service_providers.dart` from [MockPumpService] to the real one — no UI
/// or state-management code needs to change.
abstract class PumpService {
  /// Returns the latest known status for [pumpId].
  Future<PumpModel> getPumpStatus(String pumpId);

  /// Returns all pumps registered to the current account.
  Future<List<PumpModel>> getAllPumps();

  /// Sends a "turn on" command to the controller.
  Future<PumpModel> turnPumpOn(String pumpId);

  /// Sends a "turn off" command to the controller.
  Future<PumpModel> turnPumpOff(String pumpId);

  /// Sends an immediate emergency-stop command (bypasses queued commands).
  Future<PumpModel> emergencyStop(String pumpId);

  /// Returns the tank(s) associated with [pumpId].
  Future<List<TankModel>> getTanksForPump(String pumpId);

  /// Persists a weekly schedule slot for [pumpId].
  Future<void> schedulePump(String pumpId, ScheduleSlot slot);

  /// Removes a previously created schedule slot.
  Future<void> removeSchedule(String pumpId, String slotId);

  /// Returns all schedule slots configured for [pumpId].
  Future<List<ScheduleSlot>> getSchedules(String pumpId);

  /// Streams live pump status updates (e.g. via websocket/MQTT in a real
  /// implementation). The mock emits synthetic ticks for demo purposes.
  Stream<PumpModel> watchPumpStatus(String pumpId);
}
