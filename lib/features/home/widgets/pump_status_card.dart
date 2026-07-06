import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/pump_model.dart';
import '../../../providers/pump_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_pill.dart';

class PumpStatusCard extends ConsumerStatefulWidget {
  final PumpModel pump;

  const PumpStatusCard({super.key, required this.pump});

  @override
  ConsumerState<PumpStatusCard> createState() => _PumpStatusCardState();
}

class _PumpStatusCardState extends ConsumerState<PumpStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  Timer? _tickTimer;
  Duration _liveRuntime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _syncAnimation();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _liveRuntime = widget.pump.currentRuntime);
    });
  }

  @override
  void didUpdateWidget(covariant PumpStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.pump.state == PumpState.running) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _tickTimer?.cancel();
    super.dispose();
  }

  Future<void> _confirmEmergencyStop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_rounded, color: AppColors.danger, size: 36),
        title: const Text('Emergency Stop?'),
        content: const Text(
            'This immediately cuts power to the pump, bypassing any queued commands. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop Now'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(pumpControlControllerProvider.notifier).emergencyStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pump = widget.pump;
    final isRunning = pump.state == PumpState.running;
    final controlState = ref.watch(pumpControlControllerProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RotationTransition(
                turns: _spinController,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isRunning ? AppColors.tealGreenGradient : null,
                    color: isRunning ? null : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.plumbing_rounded,
                    color: isRunning ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pump.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    StatusPill(
                      label: isRunning ? 'Running' : 'Stopped',
                      color: isRunning ? AppColors.success : theme.colorScheme.outline,
                      icon: isRunning ? Icons.play_circle_fill_rounded : Icons.stop_circle_rounded,
                    ),
                  ],
                ),
              ),
              if (isRunning)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(FormatUtils.duration(_liveRuntime),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text('runtime', style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: controlState.isLoading
                      ? null
                      : () {
                          if (isRunning) {
                            ref.read(pumpControlControllerProvider.notifier).stop();
                          } else {
                            ref.read(pumpControlControllerProvider.notifier).start();
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: isRunning ? AppColors.danger : AppColors.secondary,
                  ),
                  icon: Icon(isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  label: Text(isRunning ? 'Stop Pump' : 'Start Pump'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: controlState.isLoading ? null : _confirmEmergencyStop,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Icon(Icons.power_settings_new_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
