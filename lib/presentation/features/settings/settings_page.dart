import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/user.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
        body: ListView(
          children: [
            // Profile section
            _SectionHeader(title: l10n.settingsProfileSection),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(l10n.settingsDisplayName),
              subtitle: Text(user?.displayName ?? l10n.emptyStateMessage),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(l10n.settingsEmail),
              subtitle: Text(user?.email ?? l10n.emptyStateMessage),
            ),

            const Divider(),

            // Appearance section
            _SectionHeader(title: l10n.settingsAppearanceSection),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.settingsLanguage),
              subtitle: Text(
                user?.locale == 'ar'
                    ? l10n.settingsLanguageArabic
                    : l10n.settingsLanguageEnglish,
              ),
              onTap: () => _showLanguageDialog(context, ref, user),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(l10n.settingsTheme),
              subtitle: Text(_getThemeLabel(user?.theme, l10n)),
              onTap: () => _showThemeDialog(context, ref, user),
            ),

            const Divider(),

            // Notifications section
            _SectionHeader(title: l10n.settingsNotificationsSection),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: Text(l10n.settingsNotificationsEnabled),
              subtitle: Text(l10n.settingsNotificationsEnabled),
              value: false,
              onChanged: (value) {},
            ),

            const Divider(),

            // Privacy & Legal section
            _SectionHeader(title: l10n.settingsPrivacySection),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text(l10n.settingsPrivacyPolicy),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push(AppRoutes.privacy),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(l10n.settingsTermsOfUse),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push(AppRoutes.terms),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(l10n.settingsAbout),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push(AppRoutes.about),
            ),

            const Divider(),

            // Support section
            _SectionHeader(title: l10n.settingsSupportSection),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: Text(l10n.settingsFeedback),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n.settingsReportIssue),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            const Divider(),

            // Version info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  l10n.settingsVersion(AppConstants.appVersion),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: Text(l10n.authLogoutButton),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeModePreference? theme, AppLocalizations l10n) {
    switch (theme) {
      case ThemeModePreference.light:
        return l10n.settingsThemeLight;
      case ThemeModePreference.dark:
        return l10n.settingsThemeDark;
      case ThemeModePreference.system:
      case null:
        return l10n.settingsThemeSystem;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, User? user) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.settingsLanguageEnglish),
              leading: Radio<String>(
                value: 'en',
                groupValue: user?.locale,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(authControllerProvider.notifier)
                        .updateProfile(locale: value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            ListTile(
              title: Text(l10n.settingsLanguageArabic),
              leading: Radio<String>(
                value: 'ar',
                groupValue: user?.locale,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(authControllerProvider.notifier)
                        .updateProfile(locale: value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, User? user) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.settingsThemeSystem),
              leading: Radio<ThemeModePreference>(
                value: ThemeModePreference.system,
                groupValue: user?.theme,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(authControllerProvider.notifier)
                        .updateProfile(theme: value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            ListTile(
              title: Text(l10n.settingsThemeLight),
              leading: Radio<ThemeModePreference>(
                value: ThemeModePreference.light,
                groupValue: user?.theme,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(authControllerProvider.notifier)
                        .updateProfile(theme: value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            ListTile(
              title: Text(l10n.settingsThemeDark),
              leading: Radio<ThemeModePreference>(
                value: ThemeModePreference.dark,
                groupValue: user?.theme,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(authControllerProvider.notifier)
                        .updateProfile(theme: value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
