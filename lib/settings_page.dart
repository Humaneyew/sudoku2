import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'championship/championship_model.dart';
import 'championship/championship_backup.dart';
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
          ...AppLanguage.values.map(
                (lang) => RadioListTile<AppLanguage>(
              key: ValueKey('lang-${lang.name}'),
              title: Text(lang.displayName(l10n)),
              value: lang,
              groupValue: app.lang,
              onChanged: (v) {
                if (v != null) {
                  unawaited(app.setLang(v));
                }
              },
            ),
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
            secondary: const Icon(Icons.my_location_alt),
          ),
          const Divider(height: 32),

          _sectionTitle(l10n.championshipLocalSection),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: Text(l10n.export),
            onTap: () => _exportChampionship(context, championship),
          ),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: Text(l10n.import),
            onTap: () => _importChampionship(context, championship),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(l10n.resetMyScore),
            onTap: () => _resetChampionshipScore(context, championship),
          ),
          ListTile(
            leading: const Icon(Icons.groups_rounded),
            title: Text(l10n.regenerateOpponents),
            onTap: () => _regenerateOpponents(context, championship),
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

  Future<void> _exportChampionship(
    BuildContext context,
    ChampionshipModel championship,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final snapshot = championship.createBackupData(DateTime.now());
      await ChampionshipBackupManager.saveBackup(snapshot);
      if (!context.mounted) return;
      _showSnack(context, l10n.done);
    } catch (_) {
      if (!context.mounted) return;
      _showSnack(context, l10n.failed);
    }
  }

  Future<void> _importChampionship(
    BuildContext context,
    ChampionshipModel championship,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final filePath = result.files.single.path;
      if (filePath == null) {
        _showSnack(context, l10n.failed);
        return;
      }
      final file = File(filePath);
      final data = await ChampionshipBackupManager.loadFromFile(file);
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.import),
            content: Text(l10n.confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
      await championship.restoreFromBackup(data);
      if (!context.mounted) return;
      _showSnack(context, l10n.done);
    } catch (_) {
      if (!context.mounted) return;
      _showSnack(context, l10n.failed);
    }
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
          content: Text(l10n.confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
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

  Future<void> _regenerateOpponents(
    BuildContext context,
    ChampionshipModel championship,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.regenerateOpponents),
          content: Text(l10n.confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await championship.regenerateOpponents();
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
