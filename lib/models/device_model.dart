/// Represents the physical controller/RMU (Remote Monitoring Unit) box
/// mounted at the pump — the data a farmer would read off its nameplate.
/// Field names mirror a real Crompton solar pump controller label so the
/// "Device Management" screen feels grounded in actual hardware.
class DeviceInfoModel {
  final String modelNo; // e.g. CSCMDC-5.0-S
  final String motorPumpSpec; // e.g. "5 HP / 30 M"
  final String serialNo;
  final String imeiNo;
  final String rmuNo; // Remote Monitoring Unit / Device ID
  final String registeredMobile;
  final String enclosureModel;
  final double arrayPowerWp; // solar array size, Watts-peak
  final double maxInputVoltageDc;
  final double maxInputCurrentA;
  final double outputVoltage;
  final int outputPhases;
  final double ratedPowerKwp;
  final double mpptEfficiencyPercent;
  final String manufacturer;
  final String supportPhone;
  final String supportEmail;
  final bool has4g;
  final bool hasGps;
  final bool hasBluetooth;
  final String ipRating;

  const DeviceInfoModel({
    required this.modelNo,
    required this.motorPumpSpec,
    required this.serialNo,
    required this.imeiNo,
    required this.rmuNo,
    required this.registeredMobile,
    required this.enclosureModel,
    required this.arrayPowerWp,
    required this.maxInputVoltageDc,
    required this.maxInputCurrentA,
    required this.outputVoltage,
    required this.outputPhases,
    required this.ratedPowerKwp,
    required this.mpptEfficiencyPercent,
    required this.manufacturer,
    required this.supportPhone,
    required this.supportEmail,
    this.has4g = true,
    this.hasGps = true,
    this.hasBluetooth = true,
    this.ipRating = 'IP65',
  });
}
