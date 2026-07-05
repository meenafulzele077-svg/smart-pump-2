import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';

class EfficiencyScoreBar extends StatelessWidget {
  final double score; // 0-100

  const EfficiencyScoreBar({super.key, required this.score});

  Color get _color {
    if (score >= 85) return AppColors.success;
    if (score >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Efficiency Score', style: theme.textTheme.titleSmall),
            const Spacer(),
            Text('${score.toStringAsFixed(0)}/100',
                style: theme.textTheme.titleSmall?.copyWith(color: _color, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 10),
        LinearPercentIndicator(
          percent: (score / 100).clamp(0, 1),
          lineHeight: 10,
          barRadius: const Radius.circular(8),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          progressColor: _color,
          animation: true,
          animationDuration: 800,
        ),
      ],
    );
  }
}
