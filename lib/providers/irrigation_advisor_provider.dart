import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/irrigation_advisory_model.dart';
import 'service_providers.dart';

final savedFarmProfileProvider = FutureProvider.autoDispose<FarmProfileModel?>((ref) async {
  final service = ref.watch(irrigationAdvisoryServiceProvider);
  return service.getSavedProfile();
});

class FarmProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save(FarmProfileModel profile) async {
    final service = ref.read(irrigationAdvisoryServiceProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => service.saveProfile(profile));
    ref.invalidate(savedFarmProfileProvider);
  }
}

final farmProfileControllerProvider =
    AsyncNotifierProvider<FarmProfileController, void>(FarmProfileController.new);

final irrigationRecommendationProvider =
    FutureProvider.autoDispose<IrrigationRecommendation?>((ref) async {
  final profile = await ref.watch(savedFarmProfileProvider.future);
  if (profile == null) return null;
  final service = ref.watch(irrigationAdvisoryServiceProvider);
  return service.getRecommendation(profile);
});
