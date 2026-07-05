import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/section_header.dart';
import 'widgets/auto_fill_card.dart';
import 'widgets/scheduler_card.dart';
import 'widgets/seasonal_mode_card.dart';
import 'widgets/ai_suggestions_card.dart';
import '../irrigation_advisor/widgets/irrigation_advisor_banner.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          IrrigationAdvisorBanner(
            onTap: () => context.push('/irrigation-advisor'),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Tank Auto Fill', icon: Icons.water_drop_rounded),
          const AutoFillCard(),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Weekly Scheduler', icon: Icons.schedule_rounded),
          const SchedulerCard(),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Seasonal & Rain Modes', icon: Icons.eco_rounded),
          const SeasonalModeCard(),
          const SizedBox(height: 16),
          const SectionHeader(title: 'AI Insights', icon: Icons.auto_awesome_rounded),
          const AiSuggestionsCard(),
        ],
      ),
    );
  }
}
