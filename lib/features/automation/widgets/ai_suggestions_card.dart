import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/automation_provider.dart';
import '../../../widgets/app_card.dart';

class AiSuggestionsCard extends ConsumerWidget {
  const AiSuggestionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final suggestions = ref.watch(aiSuggestionsProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.tealGreenGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Smart AI Suggestions', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          for (final suggestion in suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: (suggestion.isWarning ? AppColors.warning : AppColors.success)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      suggestion.icon,
                      size: 18,
                      color: suggestion.isWarning ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(suggestion.title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          suggestion.description,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
