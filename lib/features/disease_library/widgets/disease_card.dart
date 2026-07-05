import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/disease_model.dart';
import '../../../widgets/app_card.dart';

class DiseaseCard extends StatelessWidget {
  final DiseaseModel disease;
  final VoidCallback onTap;
  final double? confidencePercent;

  const DiseaseCard({super.key, required this.disease, required this.onTap, this.confidencePercent});

  Color _severityColor() {
    switch (disease.severity) {
      case DiseaseSeverity.low:
        return AppColors.success;
      case DiseaseSeverity.moderate:
        return AppColors.warning;
      case DiseaseSeverity.high:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _severityColor().withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(disease.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(disease.localNameHi,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (confidencePercent != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${confidencePercent!.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 12)),
            )
          else
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
