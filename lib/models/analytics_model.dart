enum AnalyticsMetric { water, energy, runtime, motor, solar }

enum AnalyticsPeriod { daily, weekly, monthly, yearly }

/// A single point on a time-series chart.
class ChartPoint {
  final DateTime date;
  final double value;
  const ChartPoint(this.date, this.value);
}

/// Aggregated summary shown above a chart (totals + efficiency score).
class AnalyticsSummary {
  final AnalyticsMetric metric;
  final AnalyticsPeriod period;
  final double total;
  final double average;
  final double changePercent; // vs previous period, +/-
  final double efficiencyScore; // 0-100
  final List<ChartPoint> points;
  final String unit;

  const AnalyticsSummary({
    required this.metric,
    required this.period,
    required this.total,
    required this.average,
    required this.changePercent,
    required this.efficiencyScore,
    required this.points,
    required this.unit,
  });
}
