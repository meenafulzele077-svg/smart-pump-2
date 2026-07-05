import 'dart:convert';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../models/irrigation_advisory_model.dart';
import '../irrigation_advisory_service.dart';

class MockIrrigationAdvisoryService implements IrrigationAdvisoryService {
  static const _profileKey = 'irrigation_farm_profile';
  final _random = Random();

  Box get _box => Hive.box(AppConstants.settingsBox);

  @override
  Future<FarmProfileModel?> getSavedProfile() async {
    final raw = _box.get(_profileKey) as String?;
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return FarmProfileModel(
      locationName: map['locationName'] as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      soilType: SoilType.values.firstWhere((s) => s.name == map['soilType']),
      cropId: map['cropId'] as String,
      areaAcres: (map['areaAcres'] as num).toDouble(),
    );
  }

  @override
  Future<void> saveProfile(FarmProfileModel profile) async {
    final map = {
      'locationName': profile.locationName,
      'latitude': profile.latitude,
      'longitude': profile.longitude,
      'soilType': profile.soilType.name,
      'cropId': profile.cropId,
      'areaAcres': profile.areaAcres,
    };
    await _box.put(_profileKey, jsonEncode(map));
  }

  @override
  Future<IrrigationRecommendation> getRecommendation(FarmProfileModel profile) async {
    // MOCK ONLY: blends a synthetic "weather read" with the soil retention
    // factor to produce a plausible litres/acre figure + explanation. A
    // real implementation replaces this whole method body with a weather
    // API lookup + an LLM/agronomy-rules call, keeping the same signature.
    await Future.delayed(const Duration(milliseconds: 900));

    final temperature = 26 + _random.nextDouble() * 12; // 26-38 C
    final rainChance = _random.nextDouble() * 60; // 0-60%
    final baseLitresPerAcre = 22000.0; // typical daily reference for many field crops
    final tempFactor = 1 + ((temperature - 30) / 30).clamp(-0.3, 0.3);
    final adjusted = baseLitresPerAcre * tempFactor / profile.soilType.retentionFactor;

    final shouldSkip = rainChance > 55;
    final litresPerAcre = shouldSkip ? 0.0 : adjusted;
    final totalLitres = litresPerAcre * profile.areaAcres;
    final durationMinutes = shouldSkip ? 0 : (totalLitres / 15000 * 60).clamp(20, 240).toInt();

    final reasoning = shouldSkip
        ? 'Rain chance is high (${rainChance.toStringAsFixed(0)}%) around ${profile.locationName} today — '
            'skip irrigation to avoid waterlogging and save energy.'
        : 'At ${temperature.toStringAsFixed(0)}°C with ${profile.soilType.label.toLowerCase()} '
            '(retains water ${profile.soilType.retentionFactor >= 1 ? 'well' : 'less well'}), your '
            '${profile.areaAcres.toStringAsFixed(1)}-acre plot needs about '
            '${(totalLitres / 1000).toStringAsFixed(1)}k litres today, run over roughly $durationMinutes minutes.';

    return IrrigationRecommendation(
      litresPerAcre: litresPerAcre,
      totalLitres: totalLitres,
      recommendedDurationMinutes: durationMinutes,
      reasoning: reasoning,
      currentTemperatureC: temperature,
      forecastRainChancePercent: rainChance,
      shouldSkipToday: shouldSkip,
    );
  }
}
