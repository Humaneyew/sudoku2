import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'battle/flag_picker.dart';
import 'championship/championship_model.dart';
import 'language_settings_page.dart';
import 'models.dart';
import 'widgets/how_to_play_dialog.dart';
import 'widgets/privacy_policy_dialog.dart';
import 'widgets/theme_menu.dart';
import 'layout/layout_scale.dart';

const _appVersion = '1.0.4';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final championship = context.watch<ChampionshipModel>();
    final l10n = AppLocalizations.of(context)!;
    final scale = context.layoutScale;
    final iconSize = 24 * scale;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: IconTheme.merge(
        data: IconThemeData(size: iconSize),
        child: ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            _sectionTitle(context, l10n.themeSectionTitle),
          ListTile(
            key: const ValueKey('settings-theme'),
            leading: Icon(Icons.palette_outlined, size: iconSize),
            title: Text(app.resolvedThemeName(l10n)),
            trailing: Icon(Icons.chevron_right, size: iconSize),
            onTap: () => showThemeMenu(context),
          ),
          ListTile(
            key: const ValueKey('settings-player-flag'),
            leading: Icon(Icons.flag_outlined, size: iconSize),
            title: Text(l10n.playerFlagSettingTitle),
            trailing: Text(
              app.playerFlag ?? '🏳️',
              style: TextStyle(fontSize: 24 * scale),
            ),
            onTap: () async {
              final selected = await showFlagPicker(
                context,
                selectedFlag: app.playerFlag,
              );
              if (!context.mounted || selected == null || selected.isEmpty) {
                return;
              }
              app.setPlayerFlag(selected);
            },
          ),
          Divider(height: 32 * scale),

          _sectionTitle(context, l10n.languageSectionTitle),
          ListTile(
            key: const ValueKey('settings-language'),
            leading: Icon(Icons.language_outlined, size: iconSize),
            title: Text(l10n.languageSectionTitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(app.lang.displayName(l10n)),
                SizedBox(width: 8 * scale),
                Icon(Icons.chevron_right, size: iconSize),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsPage(),
                ),
              );
            },
          ),
          Divider(height: 32 * scale),

          _sectionTitle(context, l10n.audioSectionTitle),
          SwitchListTile(
            key: const ValueKey('settings-sounds'),
            title: Text(l10n.soundsEffectsLabel),
            value: app.soundsEnabled,
            onChanged: (v) => app.toggleSounds(v),
            secondary: Icon(Icons.volume_up, size: iconSize),
          ),
          SwitchListTile(
            key: const ValueKey('settings-vibration'),
            title: Text(l10n.vibrationLabel),
            value: app.vibrationEnabled,
            onChanged: (v) => app.toggleVibration(v),
            secondary: Icon(Icons.vibration, size: iconSize),
          ),
          SwitchListTile(
            key: const ValueKey('settings-combo-badges'),
            title: Text(l10n.comboBadgesLabel),
            value: app.comboBadgesEnabled,
            onChanged: (v) => app.toggleComboBadges(v),
            secondary: Icon(Icons.stars_outlined, size: iconSize),
          ),
          SwitchListTile(
            key: const ValueKey('settings-combo-haptics'),
            title: Text(l10n.comboHapticsLabel),
            value: app.comboHapticsEnabled,
            onChanged:
                app.comboBadgesEnabled ? (v) => app.toggleComboHaptics(v) : null,
            secondary: Icon(Icons.touch_app_outlined, size: iconSize),
          ),
          SwitchListTile(
            key: const ValueKey('settings-champ-auto-scroll'),
            title: Text(l10n.championshipAutoScroll),
            value: championship.autoScrollEnabled,
            onChanged: (v) => championship.setAutoScrollEnabled(v),
            secondary: Icon(Icons.my_location, size: iconSize),
          ),
          Divider(height: 32 * scale),

          _sectionTitle(context, l10n.championshipLocalSection),
          ListTile(
            leading: Icon(Icons.restart_alt_rounded, size: iconSize),
            title: Text(l10n.resetMyScore),
            onTap: () => _resetChampionshipScore(context, championship),
          ),
          Divider(height: 32 * scale),

          _sectionTitle(context, l10n.miscSectionTitle),
          ListTile(
            key: const ValueKey('settings-how-to-play'),
            leading: Icon(Icons.help_outline, size: iconSize),
            title: Text(l10n.howToPlayTitle),
            onTap: () async {
              final acknowledged = await showHowToPlayDialog(context);
              if (!context.mounted) {
                return;
              }
              if (acknowledged) {
                app.markTutorialSeen();
              }
            },
          ),
          ListTile(
            key: const ValueKey('settings-test-alert'),
            leading: Icon(Icons.notification_add_outlined, size: iconSize),
            title: const Text('Test notification'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Test notification'),
                  content: const Text('Это тестовое оповещение.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            key: const ValueKey('settings-about'),
            leading: Icon(Icons.info_outline, size: iconSize),
            title: Text(l10n.aboutApp),
            subtitle: Text(l10n.versionLabel(_appVersion)),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: _appVersion,
                applicationLegalese: l10n.aboutLegalese,
              );
            },
          ),
          ListTile(
            key: const ValueKey('settings-privacy-policy'),
            leading: Icon(Icons.privacy_tip_outlined, size: iconSize),
            title: Text(l10n.privacyPolicyTitle),
            onTap: () {
              showPrivacyPolicyContent(context);
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final scale = context.layoutScale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _resetChampionshipScore(
    BuildContext context,
    ChampionshipModel championship,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.resetMyScore),
          content: Text(l10n.resetMyScoreConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.resetAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await championship.resetMyScore();
      if (!context.mounted) return;
      _showSnack(context, l10n.done);
    } catch (_) {
      if (!context.mounted) return;
      _showSnack(context, l10n.failed);
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
