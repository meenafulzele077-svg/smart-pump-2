import '../models/user_model.dart';
import '../models/farm_model.dart';
import '../models/maintenance_model.dart';
import '../models/device_model.dart';

/// Abstract contract for auth, profile, farm & maintenance-record data.
abstract class UserService {
  /// Requests an OTP for [mobileNumber]. Returns a request id used to verify.
  Future<String> requestOtp(String mobileNumber);

  Future<UserModel> verifyOtp(String requestId, String otp);

  Future<UserModel> loginWithMpin(String mobileNumber, String mpin);

  Future<UserModel> getCurrentUser();

  Future<FarmModel> getFarm(String farmId);

  Future<void> updateProfile(UserModel user);

  Future<void> logout();

  // Maintenance module
  Future<List<ServiceRecord>> getServiceHistory(String pumpId);

  Future<List<WarrantyInfo>> getWarrantyDetails(String pumpId);

  Future<List<TechnicianContact>> getTechnicianContacts();

  Future<List<MaintenanceReminder>> getMaintenanceReminders(String pumpId);

  Future<List<SparePartRecord>> getSparePartRecords(String pumpId);

  // Device / controller hardware info
  Future<DeviceInfoModel> getDeviceInfo(String pumpId);
}
