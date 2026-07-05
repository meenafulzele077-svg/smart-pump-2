import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analytics_model.dart';
import 'pump_provider.dart';
import 'service_providers.dart';

final selectedMetricProvider = StateProvider<AnalyticsMetric>((ref) => AnalyticsMetric.water);

final selectedPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.weekly);

final analyticsSummaryProvider = FutureProvider.autoDispose<AnalyticsSummary>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final pumpId = ref.watch(activePumpIdProvider);
  final metric = ref.watch(selectedMetricProvider);
  final period = ref.watch(selectedPeriodProvider);
  return service.getStatistics(pumpId, metric, period);
});
