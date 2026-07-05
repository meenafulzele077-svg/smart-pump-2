enum SoilType { black, red, alluvial, sandy, clay, loamy }

extension SoilTypeLabel on SoilType {
  String get label {
    switch (this) {
      case SoilType.black:
        return 'Black (Regur) Soil';
      case SoilType.red:
        return 'Red Soil';
      case SoilType.alluvial:
        return 'Alluvial Soil';
      case SoilType.sandy:
        return 'Sandy Soil';
      case SoilType.clay:
        return 'Clay Soil';
      case SoilType.loamy:
        return 'Loamy Soil';
    }
  }

  /// Roughly how well the soil retains water (used by the mock advisor).
  double get retentionFactor {
    switch (this) {
      case SoilType.black:
        return 1.2;
      case SoilType.clay:
        return 1.3;
      case SoilType.alluvial:
        return 1.0;
      case SoilType.loamy:
        return 0.95;
      case SoilType.red:
        return 0.85;
      case SoilType.sandy:
        return 0.65;
    }
  }
}

/// The farmer's saved location + soil + crop profile, remembered on-device
/// so the advisor doesn't need to ask every time.
class FarmProfileModel {
  final String locationName;
  final double? latitude;
  final double? longitude;
  final SoilType soilType;
  final String cropId;
  final double areaAcres;

  const FarmProfileModel({
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.soilType,
    required this.cropId,
    required this.areaAcres,
  });

  FarmProfileModel copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    SoilType? soilType,
    String? cropId,
    double? areaAcres,
  }) {
    return FarmProfileModel(
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      soilType: soilType ?? this.soilType,
      cropId: cropId ?? this.cropId,
      areaAcres: areaAcres ?? this.areaAcres,
    );
  }
}

/// A concrete AI-style irrigation recommendation for today.
class IrrigationRecommendation {
  final double litresPerAcre;
  final double totalLitres;
  final int recommendedDurationMinutes;
  final String reasoning;
  final double currentTemperatureC;
  final double forecastRainChancePercent;
  final bool shouldSkipToday;

  const IrrigationRecommendation({
    required this.litresPerAcre,
    required this.totalLitres,
    required this.recommendedDurationMinutes,
    required this.reasoning,
    required this.currentTemperatureC,
    required this.forecastRainChancePercent,
    required this.shouldSkipToday,
  });
}
