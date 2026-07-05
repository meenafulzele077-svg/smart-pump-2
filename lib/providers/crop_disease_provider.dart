import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/disease_model.dart';
import 'service_providers.dart';

final cropsProvider = FutureProvider<List<CropModel>>((ref) async {
  final service = ref.watch(cropDiseaseServiceProvider);
  return service.getCrops();
});

final diseaseSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedCropFilterProvider = StateProvider<String?>((ref) => null); // null = all crops

final filteredDiseasesProvider = FutureProvider.autoDispose<List<DiseaseModel>>((ref) async {
  final service = ref.watch(cropDiseaseServiceProvider);
  final query = ref.watch(diseaseSearchQueryProvider);
  final cropFilter = ref.watch(selectedCropFilterProvider);

  List<DiseaseModel> results = query.isEmpty
      ? await service.getAllDiseases()
      : await service.search(query);

  if (cropFilter != null) {
    results = results.where((d) => d.cropId == cropFilter).toList();
  }
  return results;
});

/// Holds the result of the last "scan a photo" identification.
class DiseaseScanController extends AsyncNotifier<List<DiseaseMatch>?> {
  @override
  List<DiseaseMatch>? build() => null;

  Future<void> identify(Uint8List imageBytes) async {
    final service = ref.read(cropDiseaseServiceProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => service.identifyFromImage(imageBytes));
  }

  void reset() => state = const AsyncData(null);
}

final diseaseScanControllerProvider =
    AsyncNotifierProvider<DiseaseScanController, List<DiseaseMatch>?>(
  DiseaseScanController.new,
);
