import 'dart:typed_data';
import '../models/disease_model.dart';

/// Abstract contract for the Crop Disease Library & visual identification
/// ("scan a leaf photo") feature.
///
/// A production implementation would call a vision-capable model — for
/// example Anthropic's Claude API (a `claude-*` model with an image content
/// block) run behind your own backend, or a specialised plant-pathology
/// vision model — to classify [imageBytes] and return ranked matches.
/// Keeping this behind an interface means the UI never needs to change
/// when you swap the mock for a real model call.
abstract class CropDiseaseService {
  Future<List<CropModel>> getCrops();

  Future<List<DiseaseModel>> getAllDiseases();

  Future<List<DiseaseModel>> getDiseasesForCrop(String cropId);

  Future<List<DiseaseModel>> search(String query);

  /// Identifies likely diseases from a photographed leaf/plant, similar in
  /// spirit to a "Google Lens" search. Returns ranked [DiseaseMatch]es.
  Future<List<DiseaseMatch>> identifyFromImage(Uint8List imageBytes);
}
