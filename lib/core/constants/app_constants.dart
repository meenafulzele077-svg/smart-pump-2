/// Static, app-wide constants. Keep magic numbers & strings here.
class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Pump 2.0';
  static const String appTagline = 'Smarter irrigation. Happier farms.';

  // Hive box names
  static const String settingsBox = 'settings_box';
  static const String sessionBox = 'session_box';
  static const String cacheBox = 'cache_box';

  // Settings keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyRememberDevice = 'remember_device';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyLoggedIn = 'logged_in';
  static const String keyMobileNumber = 'mobile_number';
  static const String keyMpin = 'mpin';
  static const String keyActivePumpId = 'active_pump_id';
  static const String keyNotifPush = 'notif_push';
  static const String keyNotifSms = 'notif_sms';
  static const String keyNotifWhatsapp = 'notif_whatsapp';

  // Automation thresholds (defaults)
  static const double defaultAutoFillLowPercent = 20;
  static const double defaultAutoFillHighPercent = 95;

  // Animation durations
  static const Duration splashDuration = Duration(milliseconds: 2200);
  static const Duration shortAnim = Duration(milliseconds: 220);
  static const Duration medAnim = Duration(milliseconds: 400);
  static const Duration longAnim = Duration(milliseconds: 700);
}
