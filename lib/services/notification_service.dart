import '../models/alert_model.dart';

enum NotificationChannel { push, sms, whatsapp }

/// Abstract contract for alerts + multi-channel delivery preferences.
/// A production implementation wires this to Firebase Cloud Messaging for
/// push, an SMS gateway (e.g. MSG91/Twilio) for SMS, and the WhatsApp
/// Business API once that channel is enabled.
abstract class NotificationService {
  Future<List<AlertModel>> getAlerts(String pumpId, {int limit = 50});

  Future<void> markAsRead(String alertId);

  Future<void> markAllAsRead(String pumpId);

  /// Registers this device's FCM token with the backend so push
  /// notifications can be targeted to it.
  Future<void> registerDeviceToken(String token);

  /// Subscribes/unsubscribes from a delivery [channel] for the given pump.
  Future<void> setChannelEnabled(String pumpId, NotificationChannel channel, bool enabled);

  Future<Map<NotificationChannel, bool>> getChannelPreferences(String pumpId);

  /// Streams newly arriving alerts (foreground push / socket messages).
  Stream<AlertModel> watchIncomingAlerts(String pumpId);
}
