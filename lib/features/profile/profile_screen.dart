import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/pump_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_shimmer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final userAsync = ref.watch(currentUserProvider);
    final pumpsAsync = ref.watch(allPumpsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('profile'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            child: userAsync.when(
              data: (user) => Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : '?',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text('+91 ${user.mobileNumber}', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text('${user.farmName}, ${user.village}, ${user.district}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              loading: () => const CardShimmer(height: 70),
              error: (e, __) => Text('Failed to load profile: $e'),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'My Pumps',
            icon: Icons.water_pump_rounded,
            children: [
              pumpsAsync.when(
                data: (pumps) => Text('${pumps.length} pumps registered to your account',
                    style: theme.textTheme.bodyMedium),
                loading: () => const LoadingShimmer(height: 16, width: 200),
                error: (e, __) => Text('Error: $e'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Farm Advisor',
            icon: Icons.auto_awesome_rounded,
            children: [
              _NavTile(
                icon: Icons.local_florist_rounded,
                iconColor: AppColors.secondary,
                title: 'Crop Disease Library',
                subtitle: 'Browse & scan for plant diseases',
                onTap: () => context.push('/disease-library'),
              ),
              _NavTile(
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.info,
                title: 'AI Irrigation Advisor',
                subtitle: 'How much water to pour today',
                onTap: () => context.push('/irrigation-advisor'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Preferences',
            icon: Icons.tune_rounded,
            children: [
              _NavTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: 'Language',
                subtitle: AppLocalizations.localeNames[ref.watch(localeProvider).languageCode] ?? 'English',
                onTap: () => _showLanguageSheet(context, ref),
              ),
              _NavTile(
                icon: Icons.dark_mode_outlined,
                iconColor: AppColors.primary,
                title: 'Theme',
                subtitle: _themeModeLabel(ref.watch(themeModeProvider)),
                onTap: () => _showThemeSheet(context, ref),
              ),
              _NavTile(
                icon: Icons.notifications_active_outlined,
                iconColor: AppColors.warning,
                title: 'Notification Preferences',
                subtitle: 'Push, SMS & WhatsApp channels',
                onTap: () => _showNotificationPrefsSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Device & Maintenance',
            icon: Icons.settings_suggest_rounded,
            children: [
              _NavTile(
                icon: Icons.memory_rounded,
                iconColor: AppColors.info,
                title: 'Device Management',
                subtitle: 'Controller, IMEI & hardware info',
                onTap: () => _showDeviceInfoSheet(context, ref),
              ),
              _NavTile(
                icon: Icons.build_rounded,
                iconColor: AppColors.warning,
                title: 'Maintenance & Service History',
                subtitle: 'Warranty, technicians & spare parts',
                onTap: () => context.push('/maintenance'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Support',
            icon: Icons.support_agent_rounded,
            children: [
              _NavTile(
                icon: Icons.headset_mic_rounded,
                iconColor: AppColors.primary,
                title: 'Support Center',
                subtitle: 'Chat with our team, 24x7',
                onTap: () {},
              ),
              _NavTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.primary,
                title: 'FAQ',
                subtitle: 'Frequently asked questions',
                onTap: () {},
              ),
              _NavTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: 'About ${AppConstants.appName}',
                subtitle: 'Version 1.0.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.tealGreenGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: Colors.white),
                  ),
                  children: const [
                    Text('Smarter irrigation for Indian farmers — monitor, automate and '
                        'protect your pumps from anywhere.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocalizations.supportedLocales.map((locale) {
            return ListTile(
              title: Text(AppLocalizations.localeNames[locale.languageCode]!),
              trailing: ref.watch(localeProvider).languageCode == locale.languageCode
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale.languageCode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              ListTile(
                title: Text(_themeModeLabel(mode)),
                trailing: ref.watch(themeModeProvider) == mode
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationPrefsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _NotificationPrefsSheet(),
    );
  }

  void _showDeviceInfoSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _DeviceInfoSheet(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _NotificationPrefsSheet extends ConsumerWidget {
  const _NotificationPrefsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Preferences', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Choose how you want to be alerted for this pump',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.notifications_active_rounded),
              title: const Text('Push Notifications'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.sms_rounded),
              title: const Text('SMS Notifications'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.chat_rounded),
              title: const Text('WhatsApp Notifications'),
              subtitle: const Text('Coming soon'),
              value: false,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoSheet extends ConsumerWidget {
  const _DeviceInfoSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deviceAsync = ref.watch(deviceInfoProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: deviceAsync.when(
          data: (device) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.memory_rounded, color: AppColors.info),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.manufacturer, style: theme.textTheme.titleLarge),
                        Text(device.modelNo, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _infoRow(theme, 'Motor / Pump', device.motorPumpSpec),
              _infoRow(theme, 'RMU / Device ID', device.rmuNo),
              _infoRow(theme, 'Serial No.', device.serialNo),
              _infoRow(theme, 'IMEI No.', device.imeiNo),
              _infoRow(theme, 'Enclosure Model', device.enclosureModel),
              _infoRow(theme, 'Solar Array Size', '${device.arrayPowerWp.toStringAsFixed(0)} Wp'),
              _infoRow(theme, 'Rated Power', '${device.ratedPowerKwp} kWp'),
              _infoRow(theme, 'MPPT Efficiency', '${device.mpptEfficiencyPercent}%'),
              _infoRow(theme, 'Output', '${device.outputVoltage}V, ${device.outputPhases}-phase'),
              _infoRow(theme, 'Protection Rating', device.ipRating),
              const Divider(height: 28),
              Row(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(device.supportPhone, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ],
          ),
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, __) => Text('Could not load device info: $e'),
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(
              flex: 3,
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
