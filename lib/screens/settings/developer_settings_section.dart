import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../state/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/localization_service.dart';
import '../../services/meds_notifications_service.dart';
import '../initial_screen.dart';

/// Developer settings section with toggle, notifications status,
/// and data reset functionality.
class DeveloperSettingsSection extends StatelessWidget {
  final AppState appState;
  final Settings settings;
  final AppLocalizations l10n;

  const DeveloperSettingsSection({
    super.key,
    required this.appState,
    required this.settings,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.developerModeLabel),
          subtitle: Text(l10n.developerModeHelp),
          value: settings.developerModeEnabled,
          onChanged: (value) {
            if (value == null) return;
            appState.updateSettings((s) {
              s.developerModeEnabled = value;
            });
          },
        ),
        if (settings.developerModeEnabled) ...[
          const SizedBox(height: 12),
          FutureBuilder<void>(
            future: MedsNotificationsService.instance.ensureInitialized(),
            builder: (context, snapshot) => ValueListenableBuilder<String>(
              valueListenable:
                  MedsNotificationsService.instance.statusListenable,
              builder: (context, statusCode, child) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.developerNotificationsServiceLabel),
                  subtitle: Text(
                    _notificationsStatusLabel(l10n, statusCode),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.developerResetAllDataLabel),
                  content: Text(l10n.developerResetAllDataHelp),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.dialogCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(l10n.dialogReset),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;

              appState.resetAllData();
              final localizationService =
                  Provider.of<LocalizationService>(context, listen: false);
              await localizationService.setLanguage('en');
              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const InitialScreen(),
                ),
                (route) => false,
              );
            },
            child: Text(l10n.developerResetAllDataLabel),
          ),
        ],
      ],
    );
  }

  String _notificationsStatusLabel(AppLocalizations l10n, String statusCode) {
    switch (statusCode) {
      case 'active':
        return l10n.developerNotificationsStatusActive;
      case 'disabled':
        return l10n.developerNotificationsStatusDisabled;
      case 'unsupported_platform':
        return l10n.developerNotificationsStatusUnsupportedPlatform;
      case 'plugin_missing':
        return l10n.developerNotificationsStatusPluginMissing;
      case 'permission_denied':
        return l10n.developerNotificationsStatusPermissionDenied;
      case 'platform_error':
      case 'error':
        return l10n.developerNotificationsStatusError;
      case 'ready':
        return l10n.developerNotificationsStatusReady;
      case 'not_initialized':
      default:
        return l10n.developerNotificationsStatusNotInitialized;
    }
  }
}
