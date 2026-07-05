enum CropSeason { kharif, rabi, zaid, perennial }

/// A single named crop grown by the target farmers, used to group and
/// filter the disease library (e.g. cotton, soybean, wheat, tur/arhar).
class CropModel {
  final String id;
  final String name;
  final String localNameHi;
  final String localNameMr;
  final CropSeason season;

  const CropModel({
    required this.id,
    required this.name,
    required this.localNameHi,
    required this.localNameMr,
    required this.season,
  });
}

enum DiseaseSeverity { low, moderate, high }

/// A single disease/pest entry in the plant-health library.
class DiseaseModel {
  final String id;
  final String cropId;
  final String name;
  final String localNameHi;
  final String scientificName;
  final DiseaseSeverity severity;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;
  final String imageAsset; // placeholder asset path / network URL

  const DiseaseModel({
    required this.id,
    required this.cropId,
    required this.name,
    required this.localNameHi,
    required this.scientificName,
    required this.severity,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
    required this.imageAsset,
  });
}

/// Result of an image-based ("Google Lens"-style) disease identification —
/// a ranked list of likely matches with a confidence score each.
class DiseaseMatch {
  final DiseaseModel disease;
  final double confidencePercent;

  const DiseaseMatch({required this.disease, required this.confidencePercent});
}
