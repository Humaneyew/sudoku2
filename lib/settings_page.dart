import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';
import 'widgets/theme_menu.dart';

const _appVersion = '1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
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
}
