import '../models/irrigation_advisory_model.dart';

/// Abstract contract for the AI Irrigation Advisor.
///
/// A production implementation would combine:
///  1. A weather/soil-moisture API for the farmer's saved coordinates, and
///  2. An LLM or agronomy rules-engine (this can genuinely be a call to the
///     Claude API from your backend — send it the location's weather,
///     soil type & crop stage and ask for a structured watering
///     recommendation) to turn that data into the plain-language
///     `reasoning` string shown to the farmer.
///
/// Never call an LLM API directly from the Flutter app with an embedded
/// key — proxy it through your own backend so the key stays secret and you
/// can cache/rate-limit requests.
abstract class IrrigationAdvisoryService {
  /// Returns the farmer's saved location/soil/crop profile, or null if
  /// they haven't completed onboarding yet.
  Future<FarmProfileModel?> getSavedProfile();

  /// Persists the farmer's profile (called once from the onboarding flow;
  /// "remembers" the location exactly as the user requested).
  Future<void> saveProfile(FarmProfileModel profile);

  /// Produces today's watering recommendation for the saved profile.
  Future<IrrigationRecommendation> getRecommendation(FarmProfileModel profile);
}
