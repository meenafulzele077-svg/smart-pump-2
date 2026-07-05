import '../models/analytics_model.dart';

/// Abstract contract for historical/aggregated data used on the Analytics
/// screen (water, energy, runtime, motor health, solar production).
abstract class AnalyticsService {
  Future<AnalyticsSummary> getWaterStatistics(String pumpId, AnalyticsPeriod period);

  Future<AnalyticsSummary> getEnergyStatistics(String pumpId, AnalyticsPeriod period);

  Future<AnalyticsSummary> getRuntimeStatistics(String pumpId, AnalyticsPeriod period);

  Future<AnalyticsSummary> getMotorHealthStatistics(String pumpId, AnalyticsPeriod period);

  Future<AnalyticsSummary> getSolarStatistics(String pumpId, AnalyticsPeriod period);

  /// Generic entry point used by the tabbed Analytics screen.
  Future<AnalyticsSummary> getStatistics(
    String pumpId,
    AnalyticsMetric metric,
    AnalyticsPeriod period,
  );

  /// Exports the given summary as a PDF file, returning the local file path.
  Future<String> exportToPdf(AnalyticsSummary summary);

  /// Exports the given summary as an Excel (.xlsx/.csv) file, returning the
  /// local file path.
  Future<String> exportToExcel(AnalyticsSummary summary);
}
