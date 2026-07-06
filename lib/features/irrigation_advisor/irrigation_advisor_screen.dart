import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/irrigation_advisory_model.dart';
import '../../providers/crop_disease_provider.dart';
import '../../providers/irrigation_advisor_provider.dart';
import '../../providers/pump_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';

class IrrigationAdvisorScreen extends ConsumerWidget {
  const IrrigationAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(savedFarmProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Irrigation Advisor')),
      body: profileAsync.when(
        data: (profile) => profile == null
            ? const _OnboardingForm()
            : _RecommendationView(profile: profile),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [CardShimmer(height: 300)]),
        ),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OnboardingForm extends ConsumerStatefulWidget {
  const _OnboardingForm();

  @override
  ConsumerState<_OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends ConsumerState<_OnboardingForm> {
  final _locationController = TextEditingController(text: 'Wadgaon, Nagpur');
  final _areaController = TextEditingController(text: '12.5');
  SoilType _soilType = SoilType.black;
  String? _cropId;
  bool _rememberLocation = true;
  bool _locating = false;

  @override
  void dispose() {
    _locationController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      // Real implementation: use the `geolocator` package to request
      // permission and fetch GPS coordinates, then reverse-geocode them.
      // Kept as a short simulated delay here to demonstrate the UX flow
      // without requiring live location permissions in this environment.
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _locationController.text = 'Current Location (GPS)');
if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location detected')));    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    if (_cropId == null) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your crop')));      return;
    }
    final area = double.tryParse(_areaController.text) ?? 1;
    final profile = FarmProfileModel(
      locationName: _locationController.text,
      soilType: _soilType,
      cropId: _cropId!,
      areaAcres: area,
    );
    await ref.read(farmProfileControllerProvider.notifier).save(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cropsAsync = ref.watch(cropsProvider);
    final saveState = ref.watch(farmProfileControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          gradient: AppColors.tealGreenGradient,
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Let\'s personalise your watering advice',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    Text(
                      'Answer a few quick questions — we\'ll remember this so you don\'t need to repeat it.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Farm location', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Village, District',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _locating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.my_location_rounded),
                    onPressed: _useCurrentLocation,
                    tooltip: 'Use current location',
                  ),
          ),
        ),
        Row(
          children: [
            Checkbox(value: _rememberLocation, onChanged: (v) => setState(() => _rememberLocation = v ?? true)),
            const Expanded(child: Text('Remember this location for future recommendations')),
          ],
        ),
        const SizedBox(height: 16),
        Text('Soil type', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SoilType.values.map((soil) {
            final selected = _soilType == soil;
            return ChoiceChip(
              label: Text(soil.label),
              selected: selected,
              onSelected: (_) => setState(() => _soilType = soil),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text('Crop', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        cropsAsync.when(
          data: (crops) => DropdownButtonFormField<String>(
            value: _cropId,
            hint: const Text('Select your crop'),
            items: crops
                .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.localNameHi})')))
                .toList(),
            onChanged: (v) => setState(() => _cropId = v),
          ),
          loading: () => const LoadingShimmer(height: 52),
          error: (e, __) => Text('Error loading crops: $e'),
        ),
        const SizedBox(height: 16),
        Text('Farm area (acres)', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _areaController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g. 12.5'),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: saveState.isLoading ? null : _save,
          child: saveState.isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Get My Watering Recommendation'),
        ),
      ],
    );
  }
}

class _RecommendationView extends ConsumerWidget {
  final FarmProfileModel profile;
  const _RecommendationView({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recAsync = ref.watch(irrigationRecommendationProvider);
    final controlState = ref.watch(pumpControlControllerProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(irrigationRecommendationProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.locationName, style: theme.textTheme.titleSmall),
                      Text('${profile.soilType.label} · ${profile.areaAcres} acres',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showEditNotice(context),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          recAsync.when(
            data: (rec) {
              if (rec == null) return const SizedBox.shrink();
              return Column(
                children: [
                  AppCard(
                    gradient: rec.shouldSkipToday ? AppColors.warningGradient : AppColors.waterGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              rec.shouldSkipToday ? Icons.umbrella_rounded : Icons.water_drop_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rec.shouldSkipToday
                                    ? 'Skip irrigation today'
                                    : '${(rec.totalLitres / 1000).toStringAsFixed(1)}k litres today',
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        if (!rec.shouldSkipToday) ...[
                          const SizedBox(height: 6),
                          Text(
                            '≈ ${rec.recommendedDurationMinutes} min pump runtime · '
                            '${rec.litresPerAcre.toStringAsFixed(0)} L/acre',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(rec.reasoning,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          radius: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.thermostat_rounded, color: AppColors.warning),
                              const SizedBox(height: 6),
                              Text('${rec.currentTemperatureC.toStringAsFixed(0)}°C',
                                  style: theme.textTheme.titleMedium),
                              Text('Temperature', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          radius: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.umbrella_rounded, color: AppColors.info),
                              const SizedBox(height: 6),
                              Text('${rec.forecastRainChancePercent.toStringAsFixed(0)}%',
                                  style: theme.textTheme.titleMedium),
                              Text('Rain chance', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!rec.shouldSkipToday)
                    FilledButton.icon(
                      onPressed: controlState.isLoading
                          ? null
                          : () => ref.read(pumpControlControllerProvider.notifier).start(),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start Pump Now'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
                    ),
                ],
              );
            },
            loading: () => const CardShimmer(height: 220),
            error: (e, __) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  void _showEditNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editing your saved profile is coming soon — for now, clear app data to reset.')),
    );
  }
}
