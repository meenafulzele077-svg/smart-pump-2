class TankModel {
  final String id;
  final String name;
  final double capacityLitres;
  final double currentLitres;
  final bool overflowAlarm;
  final bool lowLevelAlarm;

  const TankModel({
    required this.id,
    required this.name,
    required this.capacityLitres,
    required this.currentLitres,
    this.overflowAlarm = false,
    this.lowLevelAlarm = false,
  });

  double get percentFull =>
      capacityLitres <= 0 ? 0 : (currentLitres / capacityLitres).clamp(0, 1) * 100;

  bool get isCritical => percentFull < 15;
  bool get isNearFull => percentFull > 90;

  TankModel copyWith({
    double? currentLitres,
    bool? overflowAlarm,
    bool? lowLevelAlarm,
  }) {
    return TankModel(
      id: id,
      name: name,
      capacityLitres: capacityLitres,
      currentLitres: currentLitres ?? this.currentLitres,
      overflowAlarm: overflowAlarm ?? this.overflowAlarm,
      lowLevelAlarm: lowLevelAlarm ?? this.lowLevelAlarm,
    );
  }
}
