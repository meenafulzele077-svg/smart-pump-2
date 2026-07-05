import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pump_service.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../services/crop_disease_service.dart';
import '../services/irrigation_advisory_service.dart';
import '../services/mock/mock_pump_service.dart';
import '../services/mock/mock_analytics_service.dart';
import '../services/mock/mock_notification_service.dart';
import '../services/mock/mock_user_service.dart';
import '../services/mock/mock_crop_disease_service.dart';
import '../services/mock/mock_irrigation_advisory_service.dart';

/// -----------------------------------------------------------------------
/// SINGLE SOURCE OF TRUTH FOR DEPENDENCY INJECTION
/// -----------------------------------------------------------------------
/// When the real hardware/controller API is ready, create e.g.
/// `ApiPumpService implements PumpService` and change ONLY the line below.
/// Every screen/provider depends on the abstract interface, never the mock
/// or API class directly, so this is the only edit required to go live.
/// -----------------------------------------------------------------------

final pumpServiceProvider = Provider<PumpService>((ref) => MockPumpService());

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => MockAnalyticsService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => MockNotificationService());

final userServiceProvider = Provider<UserService>((ref) => MockUserService());

final cropDiseaseServiceProvider =
    Provider<CropDiseaseService>((ref) => MockCropDiseaseService());

final irrigationAdvisoryServiceProvider =
    Provider<IrrigationAdvisoryService>((ref) => MockIrrigationAdvisoryService());
