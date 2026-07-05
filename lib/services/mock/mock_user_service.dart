import '../../models/user_model.dart';
import '../../models/farm_model.dart';
import '../../models/pump_model.dart';
import '../../models/tank_model.dart';
import '../../models/maintenance_model.dart';
import '../../models/device_model.dart';
import '../user_service.dart';

class MockUserService implements UserService {
  final _user = const UserModel(
    id: 'u1',
    name: 'Vinod Fulzele',
    mobileNumber: '9876543210',
    farmName: 'Fulzele Farm',
    village: 'Wadgaon',
    district: 'Nagpur',
    state: 'Maharashtra',
    preferredLanguage: 'en',
  );

  @override
  Future<String> requestOtp(String mobileNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'otp_req_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<UserModel> verifyOtp(String requestId, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _user;
  }

  @override
  Future<UserModel> loginWithMpin(String mobileNumber, String mpin) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _user;
  }

  @override
  Future<UserModel> getCurrentUser() async => _user;

  @override
  Future<FarmModel> getFarm(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const FarmModel(
      id: 'farm_1',
      name: 'Fulzele Farm',
      areaAcres: 12.5,
      cropTypes: ['Cotton', 'Soybean', 'Orange orchard'],
      pumps: [
        PumpModel(
          id: 'pump_farm',
          name: 'Farm Pump',
          location: 'Fulzele Farm, Plot 3',
          state: PumpState.running,
          powerSource: PumpPowerSource.hybrid,
          motorTemperatureC: 58,
          voltage: 231,
          currentAmps: 6.2,
          isOnline: true,
          horsePower: 5,
        ),
        PumpModel(
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
        ),
        PumpModel(
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
        ),
      ],
      tanks: [
        TankModel(
          id: 'tank_farm_1',
          name: 'Main Storage Tank',
          capacityLitres: 10000,
          currentLitres: 6400,
        ),
      ],
    );
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<ServiceRecord>> getServiceHistory(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ServiceRecord(
        id: 'sr1',
        type: ServiceRecordType.routineService,
        date: DateTime.now().subtract(const Duration(days: 40)),
        description: 'Routine service — bearing lubrication & filter cleaning',
        technicianName: 'Ramesh Patil',
        cost: 450,
      ),
      ServiceRecord(
        id: 'sr2',
        type: ServiceRecordType.motorReplacement,
        date: DateTime.now().subtract(const Duration(days: 210)),
        description: 'Replaced 5HP motor winding after burnout',
        technicianName: 'Suresh Electricals',
        cost: 6200,
      ),
      ServiceRecord(
        id: 'sr3',
        type: ServiceRecordType.inspection,
        date: DateTime.now().subtract(const Duration(days: 300)),
        description: 'Annual inspection — no issues found',
        technicianName: 'Ramesh Patil',
        cost: 200,
      ),
    ];
  }

  @override
  Future<List<WarrantyInfo>> getWarrantyDetails(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      WarrantyInfo(
        componentName: '5HP Submersible Motor',
        purchaseDate: DateTime.now().subtract(const Duration(days: 400)),
        expiryDate: DateTime.now().add(const Duration(days: 330)),
        provider: 'CRI Pumps',
      ),
      WarrantyInfo(
        componentName: 'Smart Controller Unit',
        purchaseDate: DateTime.now().subtract(const Duration(days: 120)),
        expiryDate: DateTime.now().add(const Duration(days: 610)),
        provider: 'Smart Pump Systems',
      ),
    ];
  }

  @override
  Future<List<TechnicianContact>> getTechnicianContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      TechnicianContact(
        id: 't1',
        name: 'Ramesh Patil',
        specialization: 'Motor & Pump Repair',
        phoneNumber: '9822011223',
        rating: 4.8,
      ),
      TechnicianContact(
        id: 't2',
        name: 'Suresh Electricals',
        specialization: 'Electrical & Wiring',
        phoneNumber: '9765544332',
        rating: 4.6,
      ),
      TechnicianContact(
        id: 't3',
        name: 'Smart Pump Support',
        specialization: 'Controller & App Support',
        phoneNumber: '18001234567',
        rating: 4.9,
      ),
    ];
  }

  @override
  Future<List<MaintenanceReminder>> getMaintenanceReminders(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      MaintenanceReminder(
        id: 'mr1',
        title: 'Routine motor service',
        dueDate: DateTime.now().add(const Duration(days: 10)),
      ),
      MaintenanceReminder(
        id: 'mr2',
        title: 'Replace mechanical seal',
        dueDate: DateTime.now().add(const Duration(days: 45)),
      ),
      MaintenanceReminder(
        id: 'mr3',
        title: 'Clean solar panels',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<List<SparePartRecord>> getSparePartRecords(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      SparePartRecord(
        id: 'sp1',
        partName: 'Mechanical Seal',
        replacedOn: DateTime.now().subtract(const Duration(days: 210)),
        cost: 850,
        expectedLifespanMonths: 18,
      ),
      SparePartRecord(
        id: 'sp2',
        partName: 'Capacitor (Starting)',
        replacedOn: DateTime.now().subtract(const Duration(days: 90)),
        cost: 320,
        expectedLifespanMonths: 24,
      ),
    ];
  }

  @override
  Future<DeviceInfoModel> getDeviceInfo(String pumpId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Modeled on a real Crompton solar-pump controller nameplate so the
    // Device Management screen reflects genuine field hardware.
    return const DeviceInfoModel(
      modelNo: 'CSCMDC-5.0-S',
      motorPumpSpec: '5 HP / 30 M',
      serialNo: 'LSTG1YI014364',
      imeiNo: '860710081343967',
      rmuNo: '117125094015',
      registeredMobile: '9876543210',
      enclosureModel: 'CS-ENCL-02',
      arrayPowerWp: 4800,
      maxInputVoltageDc: 460,
      maxInputCurrentA: 16,
      outputVoltage: 265,
      outputPhases: 3,
      ratedPowerKwp: 4.8,
      mpptEfficiencyPercent: 99,
      manufacturer: 'Crompton',
      supportPhone: '+91 9228880505',
      supportEmail: 'consumer.support@crompton.co.in',
    );
  }
}
