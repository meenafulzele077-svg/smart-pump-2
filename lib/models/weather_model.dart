enum WeatherCondition { sunny, cloudy, rainy, stormy, partlyCloudy }

class WeatherModel {
  final WeatherCondition condition;
  final double temperatureC;
  final double humidityPercent;
  final double rainChancePercent;
  final String irrigationRecommendation;

  const WeatherModel({
    required this.condition,
    required this.temperatureC,
    required this.humidityPercent,
    required this.rainChancePercent,
    required this.irrigationRecommendation,
  });
}
