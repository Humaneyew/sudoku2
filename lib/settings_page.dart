import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'championship/championship_model.dart';
import 'language_settings_page.dart';
import 'models.dart';
import 'widgets/theme_menu.dart';

const _appVersion = '1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final championship = context.watch<ChampionshipModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(l10n.themeSectionTitle),
          ListTile(
            key: const ValueKey('settings-theme'),
            leading: const Icon(Icons.palette_outlined),
            title: Text(app.resolvedThemeName(l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showThemeMenu(context),
          ),
          const Divider(height: 32),

          _sectionTitle(l10n.languageSectionTitle),
          ListTile(
            key: const ValueKey('settings-language'),
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.languageSectionTitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(app.lang.displayName(l10n)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
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
          const Divider(height: 32),

          _sectionTitle(l10n.audioSectionTitle),
          SwitchListTile(
            key: const ValueKey('settings-sounds'),
            title: Text(l10n.soundsEffectsLabel),
            value: app.soundsEnabled,
            onChanged: (v) => app.toggleSounds(v),
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            key: const ValueKey('settings-vibration'),
            title: Text(l10n.vibrationLabel),
            value: app.vibrationEnabled,
            onChanged: (v) => app.toggleVibration(v),
            secondary: const Icon(Icons.vibration),
          ),
          SwitchListTile(
            key: const ValueKey('settings-music'),
            title: Text(l10n.musicLabel),
            value: app.musicEnabled,
            onChanged: (v) => app.toggleMusic(v),
            secondary: const Icon(Icons.music_note),
          ),
          SwitchListTile(
            key: const ValueKey('settings-champ-auto-scroll'),
            title: Text(l10n.championshipAutoScroll),
            value: championship.autoScrollEnabled,
            onChanged: (v) => championship.setAutoScrollEnabled(v),
            secondary: const Icon(Icons.my_location),
          ),
          const Divider(height: 32),

          _sectionTitle(l10n.championshipLocalSection),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(l10n.resetMyScore),
            onTap: () => _resetChampionshipScore(context, championship),
          ),
          const Divider(height: 32),

          _sectionTitle(l10n.miscSectionTitle),
          ListTile(
            key: const ValueKey('settings-about'),
            leading: const Icon(Icons.info_outline),
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
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
