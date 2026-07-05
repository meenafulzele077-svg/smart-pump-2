enum PumpState { running, stopped, fault, dryRun }

enum PumpPowerSource { grid, solar, hybrid }

/// Represents a single controllable pump unit (a physical controller box
/// in the field). A user/farm may own several of these — see
/// [Farm.pumps] and the pump-switcher in the app bar.
class PumpModel {
  final String id;
  final String name; // e.g. "Farm Pump"
  final String location; // e.g. "Fulzele Farm, Plot 3"
  final PumpState state;
  final PumpPowerSource powerSource;
  final DateTime? startedAt;
  final double motorTemperatureC;
  final double voltage;
  final double currentAmps;
  final bool isOnline;
  final double horsePower;
  final DateTime? lastSyncedAt;

  const PumpModel({
    required this.id,
    required this.name,
    required this.location,
    required this.state,
    required this.powerSource,
    this.startedAt,
    required this.motorTemperatureC,
    required this.voltage,
    required this.currentAmps,
    required this.isOnline,
    required this.horsePower,
    this.lastSyncedAt,
  });

  Duration get currentRuntime {
    if (state != PumpState.running || startedAt == null) return Duration.zero;
    return DateTime.now().difference(startedAt!);
  }

  PumpModel copyWith({
    String? id,
    String? name,
    String? location,
    PumpState? state,
    PumpPowerSource? powerSource,
    DateTime? startedAt,
    bool clearStartedAt = false,
    double? motorTemperatureC,
    double? voltage,
    double? currentAmps,
    bool? isOnline,
    double? horsePower,
    DateTime? lastSyncedAt,
  }) {
    return PumpModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      state: state ?? this.state,
      powerSource: powerSource ?? this.powerSource,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      motorTemperatureC: motorTemperatureC ?? this.motorTemperatureC,
      voltage: voltage ?? this.voltage,
      currentAmps: currentAmps ?? this.currentAmps,
      isOnline: isOnline ?? this.isOnline,
      horsePower: horsePower ?? this.horsePower,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
