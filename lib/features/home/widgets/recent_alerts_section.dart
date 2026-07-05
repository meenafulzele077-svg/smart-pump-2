import 'package:flutter/material.dart';

import '../../../core/utils/format_utils.dart';
import '../../../models/alert_model.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/empty_state.dart';

class RecentAlertsSection extends StatelessWidget {
  final List<AlertModel> alerts;

  const RecentAlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const AppCard(
        child: EmptyState(
          icon: Icons.notifications_off_outlined,
          title: 'All quiet',
          message: 'No recent alerts for this pump.',
        ),
      );
    }

    return Column(
      children: alerts
          .map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  radius: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: alert.color().withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(alert.icon(), color: alert.color(), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.title, style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              alert.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FormatUtils.relativeTime(alert.timestamp),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
