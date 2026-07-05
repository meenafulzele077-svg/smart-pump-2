import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/disease_model.dart';
import '../../providers/crop_disease_provider.dart';
import '../../widgets/app_card.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  final String diseaseId;
  const DiseaseDetailScreen({super.key, required this.diseaseId});

  Color _severityColor(DiseaseSeverity s) {
    switch (s) {
      case DiseaseSeverity.low:
        return AppColors.success;
      case DiseaseSeverity.moderate:
        return AppColors.warning;
      case DiseaseSeverity.high:
        return AppColors.danger;
    }
  }

  String _severityLabel(DiseaseSeverity s) {
    switch (s) {
      case DiseaseSeverity.low:
        return 'Low Risk';
      case DiseaseSeverity.moderate:
        return 'Moderate Risk';
      case DiseaseSeverity.high:
        return 'High Risk';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allDiseasesAsync = ref.watch(filteredDiseasesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Details')),
      body: allDiseasesAsync.when(
        data: (diseases) {
          // Fall back to searching all diseases if not present in the
          // currently filtered subset (e.g. deep link from scan results).
          final disease = diseases.where((d) => d.id == diseaseId).isNotEmpty
              ? diseases.firstWhere((d) => d.id == diseaseId)
              : null;
          if (disease == null) {
            return const Center(child: Text('Disease not found'));
          }
          return _DiseaseDetailBody(disease: disease, severityColor: _severityColor, severityLabel: _severityLabel);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DiseaseDetailBody extends StatelessWidget {
  final DiseaseModel disease;
  final Color Function(DiseaseSeverity) severityColor;
  final String Function(DiseaseSeverity) severityLabel;

  const _DiseaseDetailBody({
    required this.disease,
    required this.severityColor,
    required this.severityLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = severityColor(disease.severity);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          gradient: LinearGradient(colors: [color.withOpacity(0.85), color]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco_rounded, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(disease.name,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(disease.localNameHi,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(severityLabel(disease.severity),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(height: 6),
              Text('Scientific name: ${disease.scientificName}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoSection(title: 'Symptoms', icon: Icons.visibility_rounded, items: disease.symptoms, color: AppColors.info),
        const SizedBox(height: 12),
        _InfoSection(title: 'Causes', icon: Icons.bug_report_rounded, items: disease.causes, color: AppColors.warning),
        const SizedBox(height: 12),
        _InfoSection(title: 'Treatment', icon: Icons.medical_services_rounded, items: disease.treatment, color: AppColors.danger),
        const SizedBox(height: 12),
        _InfoSection(title: 'Prevention', icon: Icons.shield_rounded, items: disease.prevention, color: AppColors.success),
        const SizedBox(height: 16),
        Text(
          'This information is for general guidance only. For confirmed diagnosis and '
          'pesticide dosage, please consult your local Krishi Vigyan Kendra or agricultural officer.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  const _InfoSection({required this.title, required this.icon, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
