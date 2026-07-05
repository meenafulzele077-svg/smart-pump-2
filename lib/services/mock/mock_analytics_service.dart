import 'dart:math';
import '../../models/analytics_model.dart';
import '../analytics_service.dart';

/// Generates believable synthetic time-series data so the Analytics screen
/// has something rich to render before the real telemetry API is wired up.
class MockAnalyticsService implements AnalyticsService {
  final _random = Random(42);

  int _pointCountFor(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return 24; // hourly buckets
      case AnalyticsPeriod.weekly:
        return 7;
      case AnalyticsPeriod.monthly:
        return 30;
      case AnalyticsPeriod.yearly:
        return 12;
    }
  }

  Duration _stepFor(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return const Duration(hours: 1);
      case AnalyticsPeriod.weekly:
        return const Duration(days: 1);
      case AnalyticsPeriod.monthly:
        return const Duration(days: 1);
      case AnalyticsPeriod.yearly:
        return const Duration(days: 30);
    }
  }

  (double base, double variance, String unit) _profileFor(AnalyticsMetric metric) {
    switch (metric) {
      case AnalyticsMetric.water:
        return (2200, 900, 'L');
      case AnalyticsMetric.energy:
        return (14, 6, 'kWh');
      case AnalyticsMetric.runtime:
        return (3.2, 1.4, 'hrs');
      case AnalyticsMetric.motor:
        return (62, 10, '°C');
      case AnalyticsMetric.solar:
        return (9, 4, 'kWh');
    }
  }

  Future<AnalyticsSummary> _generate(AnalyticsMetric metric, AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final count = _pointCountFor(period);
    final step = _stepFor(period);
    final (base, variance, unit) = _profileFor(metric);

    final now = DateTime.now();
    final points = <ChartPoint>[];
    double total = 0;
    for (int i = count - 1; i >= 0; i--) {
      final date = now.subtract(step * i);
      final seasonal = sin(i / count * pi) * variance * 0.4;
      final noise = (_random.nextDouble() - 0.5) * variance;
      final value = (base + seasonal + noise).clamp(0, double.infinity).toDouble();
      points.add(ChartPoint(date, value));
      total += value;
    }

    final average = total / points.length;
    final changePercent = (_random.nextDouble() * 24) - 8;
    final efficiency = (78 + _random.nextDouble() * 18).clamp(0, 100).toDouble();

    return AnalyticsSummary(
      metric: metric,
      period: period,
      total: total,
      average: average,
      changePercent: changePercent,
      efficiencyScore: efficiency,
      points: points,
      unit: unit,
    );
  }

  @override
  Future<AnalyticsSummary> getWaterStatistics(String pumpId, AnalyticsPeriod period) =>
      _generate(AnalyticsMetric.water, period);

  @override
  Future<AnalyticsSummary> getEnergyStatistics(String pumpId, AnalyticsPeriod period) =>
      _generate(AnalyticsMetric.energy, period);

  @override
  Future<AnalyticsSummary> getRuntimeStatistics(String pumpId, AnalyticsPeriod period) =>
      _generate(AnalyticsMetric.runtime, period);

  @override
  Future<AnalyticsSummary> getMotorHealthStatistics(String pumpId, AnalyticsPeriod period) =>
      _generate(AnalyticsMetric.motor, period);

  @override
  Future<AnalyticsSummary> getSolarStatistics(String pumpId, AnalyticsPeriod period) =>
      _generate(AnalyticsMetric.solar, period);

  @override
  Future<AnalyticsSummary> getStatistics(
    String pumpId,
    AnalyticsMetric metric,
    AnalyticsPeriod period,
  ) =>
      _generate(metric, period);

  @override
  Future<String> exportToPdf(AnalyticsSummary summary) async {
    // TODO: integrate the `pdf` + `printing` packages to render a real
    // report. Returning a fake path keeps the UI flow demonstrable.
    await Future.delayed(const Duration(milliseconds: 600));
    return '/storage/emulated/0/Download/smart_pump_${summary.metric.name}_report.pdf';
  }

  @override
  Future<String> exportToExcel(AnalyticsSummary summary) async {
    // TODO: integrate a CSV/XLSX writer for a real spreadsheet export.
    await Future.delayed(const Duration(milliseconds: 600));
    return '/storage/emulated/0/Download/smart_pump_${summary.metric.name}_report.xlsx';
  }
}
