import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';

/// TODO: replace with a real weather API integration (e.g. OpenWeatherMap,
/// IMD) — kept as a simple provider so the Home dashboard has live-feeling
/// weather data without a network dependency during development.
final weatherProvider = FutureProvider.autoDispose<WeatherModel>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return const WeatherModel(
    condition: WeatherCondition.partlyCloudy,
    temperatureC: 32,
    humidityPercent: 58,
    rainChancePercent: 20,
    irrigationRecommendation:
        'Low rain chance today — safe to run your scheduled irrigation as planned.',
  );
});
