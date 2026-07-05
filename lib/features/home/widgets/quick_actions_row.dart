import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/pump_provider.dart';

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickAction(this.icon, this.label, this.color, this.onTap);
}

class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(pumpControlControllerProvider.notifier);

    final actions = [
      _QuickAction(Icons.play_arrow_rounded, 'Start Pump', AppColors.secondary, controller.start),
      _QuickAction(Icons.stop_rounded, 'Stop Pump', AppColors.danger, controller.stop),
      _QuickAction(Icons.schedule_rounded, 'Schedule', AppColors.primary,
          () => context.go('/automation')),
      _QuickAction(Icons.water_rounded, 'Auto Fill', AppColors.info,
          () => context.go('/automation')),
      _QuickAction(Icons.local_florist_rounded, 'Disease Library', AppColors.secondary,
          () => context.push('/disease-library')),
      _QuickAction(Icons.auto_awesome_rounded, 'Ask AI', AppColors.primary,
          () => context.push('/irrigation-advisor')),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _QuickActionButton(action: action);
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: action.onTap,
        child: Container(
          width: 84,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
